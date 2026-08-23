import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/core/theme/app_colors.dart';
import 'package:octo_note/core/theme/oklch.dart';
import 'package:octo_note/core/theme/presets.dart';

void main() {
  group('oklch 转换', () {
    test('极值正确映射为黑与白', () {
      expect(oklch(0, 0, 0), const Color(0xFF000000));
      expect(oklch(1, 0, 0), const Color(0xFFFFFFFF));
    });

    test('中性灰无色度时 RGB 三通道相等', () {
      final c = oklch(0.5, 0, 180);
      expect(c.r, c.g);
      expect(c.g, c.b);
    });

    test('light 主题背景接近纯白', () {
      final c = oklch(0.985, 0, 0);
      expect(c.r, greaterThan(0.98));
      expect(c.g, greaterThan(0.98));
      expect(c.b, greaterThan(0.98));
    });

    test('主色落在预期色相区间（蓝）', () {
      final c = oklch(0.55, 0.18, 255);
      expect(c.b, greaterThan(c.r)); // 蓝色调
    });
  });

  group('AppColors', () {
    test('hex 列表往返转换保持一致', () {
      final colors = presetThemes.first.colors;
      final restored = AppColors.fromHexList(colors.toHexList());
      expect(restored.toHexList(), colors.toHexList());
    });
  });

  group('预设主题', () {
    test('至少包含 6 套且 id 唯一', () {
      expect(presetThemes.length, greaterThanOrEqualTo(6));
      expect(
        presetThemes.map((p) => p.id).toSet().length,
        presetThemes.length,
      );
    });
  });
}
