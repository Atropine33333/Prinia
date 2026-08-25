import 'dart:math';

/// 轻量 UUID v4 生成器（避免引入 uuid 依赖）。
///
/// 输出 32 位十六进制字符串，全局唯一性依赖随机数质量。
String genUuid() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40; // version 4
  b[8] = (b[8] & 0x3f) | 0x80; // variant 10
  return b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
}
