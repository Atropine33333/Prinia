import 'package:flutter/services.dart';

/// 屏幕状态查询（区分"切到其他应用"与"仅息屏"）。
class ScreenState {
  static const _channel = MethodChannel('prinia/screen');

  /// 屏幕是否点亮（息屏 = false）。
  static Future<bool> isInteractive() async {
    try {
      return await _channel.invokeMethod('isScreenOn') == true;
    } catch (_) {
      return true; // 查询失败按点亮处理，走原有逻辑
    }
  }
}
