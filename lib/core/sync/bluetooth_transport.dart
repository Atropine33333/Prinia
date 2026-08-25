import 'dart:async';

import 'package:flutter/services.dart';

import 'sync_engine.dart';

/// 蓝牙事件（来自 Kotlin EventChannel）。
class BtEvent {
  final String type; // opened | data | closed
  final int id;
  final String address;
  final String name;
  final bool incoming;
  final List<int> bytes;

  const BtEvent({
    required this.type,
    required this.id,
    this.address = '',
    this.name = '',
    this.incoming = false,
    this.bytes = const <int>[],
  });

  factory BtEvent.fromMap(Map<Object?, Object?> m) => BtEvent(
        type: m['event'] as String? ?? '',
        id: (m['id'] as num?)?.toInt() ?? -1,
        address: m['address'] as String? ?? '',
        name: m['name'] as String? ?? '',
        incoming: m['incoming'] == true,
        bytes: (m['bytes'] as List?)?.cast<int>() ?? const <int>[],
      );
}

/// 蓝牙平台通道封装。
class PriniaBluetooth {
  static const _methods = MethodChannel('prinia/bt');
  static const _events = EventChannel('prinia/bt_events');

  static Stream<BtEvent>? _eventStream;

  static Stream<BtEvent> get events =>
      _eventStream ??= _events
          .receiveBroadcastStream()
          .map((m) => BtEvent.fromMap(m as Map<Object?, Object?>));

  static Future<bool> isOn() async => await _methods.invokeMethod('isOn');

  /// 弹系统对话框请求开启蓝牙。
  static Future<bool> requestEnable() async =>
      await _methods.invokeMethod('requestEnable') == true;

  /// 请求 Android 12+ 的 BLUETOOTH_CONNECT 运行时权限。
  static Future<bool> requestConnectPermission() async =>
      await _methods.invokeMethod('requestConnectPermission') == true;

  static Future<String> myName() async =>
      await _methods.invokeMethod('myName') ?? '';

  static Future<List<({String address, String name})>> bondedDevices() async {
    final list = await _methods.invokeMethod<List<dynamic>>('bondedDevices');
    return (list ?? [])
        .map((e) => (e as Map).cast<String, Object?>())
        .map((m) => (
              address: m['address'] as String,
              name: m['name'] as String? ?? m['address'] as String,
            ))
        .toList();
  }

  static Future<void> startServer() async =>
      await _methods.invokeMethod('startServer');

  static Future<void> stopServer() async =>
      await _methods.invokeMethod('stopServer');

  /// 连接已配对设备，返回连接 id。
  static Future<int> connect(String address) async =>
      (await _methods.invokeMethod<int>('connect', {'address': address}))!;

  static Future<void> send(int id, Uint8List bytes) async =>
      await _methods.invokeMethod('send', {'id': id, 'bytes': bytes});

  static Future<void> closeConn(int id) async =>
      await _methods.invokeMethod('closeConn', {'id': id});
}

/// 把某条蓝牙连接包装成 [SyncChannel] 供 SyncEngine 使用。
class BtSyncChannel extends SyncChannel {
  final int connId;
  final Stream<BtEvent> events;
  final StreamController<Uint8List> _incoming = StreamController<Uint8List>();
  StreamSubscription<Uint8List>? _sub;

  BtSyncChannel._(this.connId, this.events) {
    _sub = events
        .where((e) => e.id == connId && e.type == 'data')
        .map((e) => Uint8List.fromList(e.bytes))
        .listen(_incoming.add,
            onError: _incoming.addError, cancelOnError: true);
  }

  factory BtSyncChannel.forConnection(int connId) =>
      BtSyncChannel._(connId, PriniaBluetooth.events);

  @override
  Future<void> send(Uint8List frame) => PriniaBluetooth.send(connId, frame);

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _incoming.close();
    await PriniaBluetooth.closeConn(connId);
  }
}
