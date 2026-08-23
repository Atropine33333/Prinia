import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_icon_catalog.dart';

/// 统一图标渲染：Material 图标 或 猫猫头 SVG（跟随主题色）。
///
/// [codePoint] 为 [kCatCodePoint] 或未知码点时渲染猫猫。
class AppIconView extends StatelessWidget {
  final int codePoint;
  final Color color;
  final double size;

  const AppIconView({
    super.key,
    required this.codePoint,
    required this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    if (codePoint == kCatCodePoint) {
      return CatIconView(size: size, color: color);
    }
    final data = iconDataFromCode(codePoint);
    if (data == null) {
      return CatIconView(size: size, color: color);
    }
    return Icon(data, size: size, color: color);
  }
}

/// Fluent 猫猫头（assets/icons/cat.svg，currentColor 语义）。
class CatIconView extends StatelessWidget {
  final double size;
  final Color color;

  const CatIconView({super.key, this.size = 22, required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/cat.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
