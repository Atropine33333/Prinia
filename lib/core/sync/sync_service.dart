/// P2P 同步抽象接口（本次迭代不实现，仅预留架构扩展点）。
///
/// 未来可替换为蓝牙 / Wi-Fi 热点发现 + WebSocket 等实现。
/// 数据表已含 `updated_at` 与 `device_id` 字段，
/// 实现 LWW（Last-Write-Wins）合并时直接可用。
abstract class SyncService {
  /// 扫描附近设备，返回设备标识列表。
  Future<List<Device>> discoverDevices();

  /// 连接到指定设备。
  Future<void> connect(Device device);

  /// 发送增量更新数据（payload 为 JSON 格式的变更日志）。
  Future<void> sendUpdate(Map<String, dynamic> payload);

  /// 接收数据流（监听传入数据）。
  Stream<Map<String, dynamic>> receiveUpdates();

  /// 断开连接。
  void disconnect();
}

/// 可被发现的对端设备描述。
class Device {
  final String id;
  final String name;

  const Device({required this.id, required this.name});
}

/// 空实现：所有调用立即返回/空流。
///
/// 应用启动时注入此实现，保证上层代码不感知同步尚未落地。
class NoOpSyncService implements SyncService {
  /// 本机设备标识；真实实现未来从平台 API 读取。
  static const deviceId = 'local';

  const NoOpSyncService();

  @override
  Future<List<Device>> discoverDevices() async => const [];

  @override
  Future<void> connect(Device device) async {}

  @override
  Future<void> sendUpdate(Map<String, dynamic> payload) async {}

  @override
  Stream<Map<String, dynamic>> receiveUpdates() => const Stream.empty();

  @override
  void disconnect() {}
}
