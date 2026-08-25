import 'package:shared_preferences/shared_preferences.dart';

import 'uuid_util.dart';

/// 本机同步身份：安装时生成一次，写入所有本地行作为 device_id。
///
/// LWW 冲突平局时按 device_id 字典序裁决，因此必须全局唯一且稳定。
class DeviceIdentity {
  static const _key = 'install_device_id';
  static String _current = 'local';
  static String _name = 'Android 设备';

  /// 当前设备 id（应用启动早期加载；加载完成前写入的行暂为 'local'）。
  static String get current => _current;

  static String get name => _name;

  static Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    var id = sp.getString(_key);
    if (id == null) {
      id = genUuid();
      await sp.setString(_key, id);
    }
    _current = id;
    _name = sp.getString('device_name') ?? _name;
  }

  static Future<void> setName(String name) async {
    _name = name;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('device_name', name);
  }

  /// 仅测试用。
  static void overrideForTest(String id) => _current = id;
}
