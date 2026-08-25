import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bluetooth_transport.dart';
import 'device_identity.dart';
import 'sync_targets.dart';
import 'sync_engine.dart';
import '../db/db_provider.dart';

enum SyncPhase { off, starting, listening, connecting, syncing }

class SyncState {
  final SyncPhase phase;
  final String status;
  final String? lastPeerName;
  final DateTime? lastSyncAt;
  final String? lastError;

  const SyncState({
    this.phase = SyncPhase.off,
    this.status = '',
    this.lastPeerName,
    this.lastSyncAt,
    this.lastError,
  });

  SyncState copyWith({
    SyncPhase? phase,
    String? status,
    String? lastPeerName,
    DateTime? lastSyncAt,
    String? lastError,
  }) {
    return SyncState(
      phase: phase ?? this.phase,
      status: status ?? this.status,
      lastPeerName: lastPeerName ?? this.lastPeerName,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError,
    );
  }
}

/// 同步编排：应用启动自动进入"同步准备"（服务端监听），
/// 同时尝试连接已知对端；会话结束后回到准备态。设置页可手动触发。
class SyncManager extends Notifier<SyncState> {
  StreamSubscription<BtEvent>? _eventSub;
  StreamSubscription<Set<TableUpdate>>? _dbSub;
  Timer? _debounce;
  DateTime _nextRoundAllowed = DateTime.fromMillisecondsSinceEpoch(0);
  bool _busy = false; // 正在跑会话
  bool _started = false;

  @override
  SyncState build() {
    ref.onDispose(_teardown);
    return const SyncState();
  }

  Future<void> _teardown() async {
    await _eventSub?.cancel();
    await _dbSub?.cancel();
    _debounce?.cancel();
    try {
      await PriniaBluetooth.stopServer();
    } catch (_) {}
  }

  /// 监听本地写入：任何编辑 → 防抖后自动推送到在线对端。
  void _hookLocalWrites() {
    final db = ref.read(databaseProvider);
    _dbSub ??= db
        .tableUpdates(TableUpdateQuery.onAllTables([
      db.accounts,
      db.focusSessions,
      db.courses,
      db.customCategories,
      db.appMeta,
    ]))
        .listen((_) {
      if (_busy) return; // 会话内写入（应用对端数据）不触发
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 3), _maybeSync);
    });
  }

  /// 有对端且本地存在比其游标新的变更才发起连接。
  Future<void> _maybeSync() async {
    if (_busy) return;
    final db = ref.read(databaseProvider);
    final peers = await db.select(db.syncPeers).get();
    if (peers.isEmpty) return; // 从未同步过：等手动触发
    final maxTs = await db.maxUpdatedAt();
    final pending = peers.any((p) => maxTs > p.lastSyncAt);
    if (!pending) return;
    if (DateTime.now().isBefore(_nextRoundAllowed)) return; // 冷却中
    await _begin(manual: true);
  }

  // ── 启动 ───────────────────────────────────────────────────

  /// 应用启动调用一次：权限/蓝牙 → 连接已知对端 → 进入监听。
  Future<void> autoStart() async {
    if (_started) return;
    _started = true;
    await _begin();
  }

  /// 手动触发一次同步（设置页按钮）。
  Future<void> syncNow() async {
    await _begin(manual: true);
  }

  Future<void> _begin({bool manual = false}) async {
    if (_busy) return;
    state = state.copyWith(
        phase: SyncPhase.starting, status: '正在启动蓝牙…', lastError: null);

    if (!await PriniaBluetooth.requestConnectPermission()) {
      state = state.copyWith(
          phase: SyncPhase.off,
          status: '缺少蓝牙权限',
          lastError: 'BLUETOOTH_CONNECT 被拒绝');
      return;
    }
    if (!await PriniaBluetooth.isOn()) {
      final granted = await PriniaBluetooth.requestEnable();
      if (!granted) {
        state = state.copyWith(
            phase: SyncPhase.off,
            status: '蓝牙未开启',
            lastError: '用户拒绝开启蓝牙');
        return;
      }
    }

    _ensureEventRouting();
    _hookLocalWrites();

    // 常驻服务端监听（同步完成后仍保持准备态）
    await PriniaBluetooth.startServer();
    if (!_busy) {
      state = state.copyWith(
          phase: SyncPhase.listening,
          status: manual ? '等待对端连接…' : '同步准备就绪');
    }

    // 尝试主动连接已知对端（对端应用已打开即会命中）
    await _connectKnownPeers(force: manual);
  }

  // ── 事件路由 ────────────────────────────────────────────────

  void _ensureEventRouting() {
    _eventSub ??= PriniaBluetooth.events.listen(_onEvent);
  }

  Future<void> _onEvent(BtEvent e) async {
    if (e.type == 'opened' && e.incoming) {
      if (_busy) {
        // 已有会话在跑：立即关闭，让对端快速失败后重试
        await PriniaBluetooth.closeConn(e.id);
        return;
      }
      // 对端主动连入 → 直接开跑会话
      _busy = true;
      state = state.copyWith(
          phase: SyncPhase.syncing, status: '已连接 ${e.name}，正在同步…');
      final channel = BtSyncChannel.forConnection(e.id);
      try {
        final engine = SyncEngine(
          db: ref.read(databaseProvider),
          myDeviceId: DeviceIdentity.current,
          myDeviceName: DeviceIdentity.name,
          onStatus: (s) => state = state.copyWith(status: s),
        );
        final result = await engine.run(channel);
        state = state.copyWith(
          phase: SyncPhase.listening,
          status: result.toString(),
          lastPeerName: result.peerName,
          lastSyncAt: DateTime.now(),
        );
      } catch (err) {
        state = state.copyWith(
          phase: SyncPhase.listening,
          status: '同步失败',
          lastError: err.toString(),
        );
      } finally {
        await channel.close();
        _busy = false;
        _debounce = Timer(const Duration(seconds: 2), _maybeSync);
      }
    } else if (e.type == 'closed' && _busy) {
      // 会话通道被对端关闭：engine 的流会自然出错/结束
    }
  }

  // ── 主动连接 ────────────────────────────────────────────────

  /// 一轮遍历所有已配对对端，逐个同步（每对独立游标）。
  /// [force] 跳过冷却（手动触发）。
  Future<void> _connectKnownPeers({bool force = false}) async {
    if (_busy) return;
    final db = ref.read(databaseProvider);
    final maxTs = await db.maxUpdatedAt();
    final peerRows = await db.select(db.syncPeers).get();
    final allUpToDate =
        peerRows.isNotEmpty && peerRows.every((p) => p.lastSyncAt >= maxTs);
    // 冷却期内且无新编辑：不空转（对端离线时的防循环）
    if (!force &&
        (allUpToDate || DateTime.now().isBefore(_nextRoundAllowed))) {
      return;
    }

    final allBonded = await PriniaBluetooth.bondedDevices();
    final selection = ref.read(syncTargetsProvider);
    // 只轮询用户勾选的设备；未配置时全部参与
    final peers = selection.isEmpty
        ? allBonded
        : allBonded.where((d) => selection.contains(d.address)).toList();
    if (peers.isEmpty) {
      state = state.copyWith(
          phase: SyncPhase.listening,
          status: '未选择同步设备，请在设置中勾选');
      return;
    }

    var anyConnectFailed = false;
    var anySessionFailed = false;

    // 双方同时发起会互相击杀（忙时互关），随机抖动+重试让一方先赢
    for (var attempt = 1; attempt <= 3; attempt++) {
      if (_busy) return;
      if (attempt > 1) {
        final delay =
            Duration(milliseconds: 1500 + Random().nextInt(2000));
        state = state.copyWith(
            phase: SyncPhase.listening,
            status: '对端忙碌，${delay.inSeconds}s 后重试（$attempt/3）');
        await Future<void>.delayed(delay);
      }
      for (final peer in peers) {
        if (_busy) return;
        state = state.copyWith(
            phase: SyncPhase.connecting,
            status: '正在连接 ${peer.name}…');
        int? connId;
        try {
          connId = await PriniaBluetooth.connect(peer.address)
              .timeout(const Duration(seconds: 8));
        } catch (_) {
          anyConnectFailed = true;
          continue; // 对端不在线/未开应用，试下一个
        }

        // 等待期间对端已连入并开跑会话：放弃本次出站，避免双会话
        if (_busy) {
          await PriniaBluetooth.closeConn(connId);
          return;
        }
        _busy = true;
        state = state.copyWith(
            phase: SyncPhase.syncing,
            status: '已连接 ${peer.name}，正在同步…');
        final channel = BtSyncChannel.forConnection(connId);
        try {
          final engine = SyncEngine(
            db: ref.read(databaseProvider),
            myDeviceId: DeviceIdentity.current,
            myDeviceName: DeviceIdentity.name,
            onStatus: (s) => state = state.copyWith(status: s),
          );
          final result = await engine.run(channel);
          state = state.copyWith(
            phase: SyncPhase.listening,
            status: result.toString(),
            lastPeerName: result.peerName,
            lastSyncAt: DateTime.now(),
          );
        } catch (err) {
          anySessionFailed = true;
          state = state.copyWith(
            phase: SyncPhase.listening,
            status: '同步失败',
            lastError: err.toString(),
          );
        } finally {
          await channel.close();
          _busy = false;
        }
        // 不 return：继续本轮剩余对端（多设备接力）
      }
      // 全部会话成功则不必重试；有失败（互连击杀等）才抖动重扫
      if (!anySessionFailed) break;
    }

    // 有对端没连上（离线）：设置冷却，防止空会话循环
    if (anyConnectFailed) {
      _nextRoundAllowed = DateTime.now().add(const Duration(seconds: 30));
    }
    // 轮次结束后补检一次（会话期间的新编辑）
    _debounce = Timer(const Duration(seconds: 2), () => _maybeSync());
  }
}

final syncManagerProvider =
    NotifierProvider<SyncManager, SyncState>(SyncManager.new);
