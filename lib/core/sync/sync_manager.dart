import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bluetooth_transport.dart';
import 'device_identity.dart';
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
  bool _busy = false; // 正在跑会话
  bool _started = false;

  @override
  SyncState build() {
    ref.onDispose(_teardown);
    return const SyncState();
  }

  Future<void> _teardown() async {
    await _eventSub?.cancel();
    try {
      await PriniaBluetooth.stopServer();
    } catch (_) {}
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

    // 常驻服务端监听（同步完成后仍保持准备态）
    await PriniaBluetooth.startServer();
    if (!_busy) {
      state = state.copyWith(
          phase: SyncPhase.listening,
          status: manual ? '等待对端连接…' : '同步准备就绪');
    }

    // 尝试主动连接已知对端（对端应用已打开即会命中）
    await _connectKnownPeers();
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
      }
    } else if (e.type == 'closed' && _busy) {
      // 会话通道被对端关闭：engine 的流会自然出错/结束
    }
  }

  // ── 主动连接 ────────────────────────────────────────────────

  Future<void> _connectKnownPeers() async {
    if (_busy) return;
    final peers = await PriniaBluetooth.bondedDevices();
    if (peers.isEmpty) {
      state = state.copyWith(
          phase: SyncPhase.listening,
          status: '尚无已配对设备，请在系统蓝牙中配对');
      return;
    }

    for (final peer in peers) {
      if (_busy) return;
      state = state.copyWith(
          phase: SyncPhase.connecting, status: '正在连接 ${peer.name}…');
      int? connId;
      try {
        connId = await PriniaBluetooth.connect(peer.address)
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        continue; // 对端不在线/未开应用，试下一个
      }

      // 等待期间对端已连入并开跑会话：放弃本次出站，避免双会话
      if (_busy) {
        await PriniaBluetooth.closeConn(connId);
        return;
      }
      _busy = true;
      state = state.copyWith(
          phase: SyncPhase.syncing, status: '已连接 ${peer.name}，正在同步…');
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
        state = state.copyWith(
          phase: SyncPhase.listening,
          status: '同步失败',
          lastError: err.toString(),
        );
      } finally {
        await channel.close();
        _busy = false;
      }
      return; // 一次连接成功即完成本轮
    }

    state = state.copyWith(
        phase: SyncPhase.listening, status: '对端均不在线，保持同步准备');
  }
}

final syncManagerProvider =
    NotifierProvider<SyncManager, SyncState>(SyncManager.new);
