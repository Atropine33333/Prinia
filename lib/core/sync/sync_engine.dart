import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'protocol.dart';
import 'sync_tables.dart';

/// 一条已建立的同步连接（由传输层提供，如蓝牙 RFCOMM）。
abstract class SyncChannel {
  Future<void> send(Uint8List frame);
  Stream<Uint8List> get incoming;
  Future<void> close();
}

/// 一次同步会话的结果统计。
class SyncResult {
  final String peerDeviceId;
  final String peerName;
  final int applied; // 从对端应用的行数
  final int sent; // 发给对端的行数
  final Duration duration;

  const SyncResult({
    required this.peerDeviceId,
    required this.peerName,
    required this.applied,
    required this.sent,
    required this.duration,
  });

  @override
  String toString() =>
      '与 $peerName 同步完成：收到 $applied 条，发出 $sent 条（${duration.inSeconds}s）';
}

const int _batchSize = 100;
const Duration sessionTimeout = Duration(seconds: 90);

/// 同步会话引擎：握手 → 双向增量 → LWW 落库 → 更新对端游标。
///
/// 协议时序（双向独立）：
///   连接后双方立即发 hello(id, name)
///   收到 hello → 查本端 sync_peers 得该对端游标 → 发送其后的变更（分批）→ 发 end
///   收到 data → 逐行 LWW 落库
///   双方 end 俱到 → 对端 lastSyncAt 更新为会话起始时刻（期间改动下轮重传，幂等）
class SyncEngine {
  final AppDatabase db;
  final String myDeviceId;
  final String myDeviceName;
  final void Function(String status)? onStatus;

  SyncEngine({
    required this.db,
    required this.myDeviceId,
    required this.myDeviceName,
    this.onStatus,
  });

  /// 在 [channel] 上执行一次完整会话。
  Future<SyncResult> run(SyncChannel channel) async {
    final startedAt = DateTime.now().millisecondsSinceEpoch;
    final adapters = buildSyncAdapters(db);
    final codec = FrameCodec();
    final decoder = codec.decoder();

    var peerDeviceId = '';
    var peerName = '';
    var sentAll = false;
    var receivedAll = false;
    var applied = 0;
    var sent = 0;
    var newCursor = 0;

    final completer = Completer<SyncResult>();

    void maybeFinish() {
      if (sentAll && receivedAll && !completer.isCompleted) {
        completer.complete(SyncResult(
          peerDeviceId: peerDeviceId,
          peerName: peerName.isEmpty ? peerDeviceId : peerName,
          applied: applied,
          sent: sent,
          duration: Duration(
              milliseconds:
                  DateTime.now().millisecondsSinceEpoch - startedAt),
        ));
      }
    }

    Future<void> sendAllChanges() async {
      final known = await (db.select(db.syncPeers)
            ..where((t) => t.peerDeviceId.equals(peerDeviceId)))
          .getSingleOrNull();
      var cursor = known?.lastSyncAt ?? 0;
      onStatus?.call('正在比对增量…');

      for (final adapter in adapters) {
        final changes = await adapter.changesSince(cursor);
        for (var i = 0; i < changes.length; i += _batchSize) {
          final batch = changes.sublist(
              i, math.min(i + _batchSize, changes.length));
          sent += batch.length;
          for (final row in batch) {
            cursor = math.max(cursor, row['updatedAt'] as int? ?? 0);
          }
          await channel.send(codec.encode(SyncMessage.data(
            deviceId: myDeviceId,
            table: adapter.name,
            rows: batch,
          )));
        }
      }
      await channel.send(codec.encode(SyncMessage.end(myDeviceId)));
      sentAll = true;
      newCursor = cursor;
      maybeFinish();
    }

    // 先订阅再发 hello（广播流无订阅者时会丢帧）
    final sub = channel.incoming.listen(
      (chunk) async {
        try {
          for (final msg in decoder.push(chunk)) {
            switch (msg.type) {
              case 'hello':
                peerDeviceId = msg.deviceId;
                peerName = msg.deviceName;
                onStatus?.call('已连接 $peerName');
                unawaited(sendAllChanges());
              case 'data':
                final adapter =
                    adapters.firstWhere((a) => a.name == msg.table);
                for (final row in msg.rows) {
                  if (await adapter.applyLww(row)) applied++;
                }
              case 'end':
                receivedAll = true;
                maybeFinish();
            }
          }
        } catch (e, st) {
          if (!completer.isCompleted) completer.completeError(e, st);
        }
      },
      onError: (Object e, StackTrace st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      },
      cancelOnError: true,
    );

    // 已订阅，现在亮明身份（双方各自发出）
    unawaited(channel.send(codec.encode(SyncMessage.hello(
      deviceId: myDeviceId,
      deviceName: myDeviceName,
      cursors: const {},
    ))));

    Timer(sessionTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('同步会话超时'));
      }
    });

    try {
      final result = await completer.future;
      // 游标 = 本轮已发送行的时间戳高水位（对端已见）
      await db.into(db.syncPeers).insertOnConflictUpdate(SyncPeersCompanion(
            peerDeviceId: Value(peerDeviceId),
            peerName: Value(result.peerName),
            lastSyncAt: Value(newCursor),
          ));
      return result;
    } finally {
      await sub.cancel();
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
