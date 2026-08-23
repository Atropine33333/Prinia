import 'package:flutter/material.dart';

/// 12 个语义化颜色变量，对标 CSS `:root` 自定义属性。
///
/// 通过 [ThemeExtension] 注入 [ThemeData]，
/// 页面中用 `Theme.of(context).extension<AppColors>()!` 获取。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg; // 页面背景
  final Color surface; // 卡片/侧栏背景
  final Color text; // 主要文字
  final Color textMuted; // 次要文字
  final Color primary; // 主色调（按钮/链接）
  final Color primaryHover; // 按压或悬停态
  final Color border; // 普通边框
  final Color borderStrong; // 强调边框
  final Color hoverBg; // 悬停背景
  final Color activeBg; // 选中态背景
  final Color highlight; // 高亮色
  final Color error; // 错误/警告色

  const AppColors({
    required this.bg,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.primary,
    required this.primaryHover,
    required this.border,
    required this.borderStrong,
    required this.hoverBg,
    required this.activeBg,
    required this.highlight,
    required this.error,
  });

  /// 从 12 个 Hex 字符串构建（用户自定义配色板存储格式）。
  factory AppColors.fromHexList(List<String> hex) {
    assert(hex.length == 12, '需要恰好 12 个颜色值');
    Color c(int i) => Color(int.parse(hex[i].replaceFirst('#', ''), radix: 16) | 0xFF000000);
    return AppColors(
      bg: c(0),
      surface: c(1),
      text: c(2),
      textMuted: c(3),
      primary: c(4),
      primaryHover: c(5),
      border: c(6),
      borderStrong: c(7),
      hoverBg: c(8),
      activeBg: c(9),
      highlight: c(10),
      error: c(11),
    );
  }

  /// 导出为 12 个 Hex 字符串（持久化格式，顺序与 [fromHexList] 一致）。
  List<String> toHexList() => [
        bg.toHex(),
        surface.toHex(),
        text.toHex(),
        textMuted.toHex(),
        primary.toHex(),
        primaryHover.toHex(),
        border.toHex(),
        borderStrong.toHex(),
        hoverBg.toHex(),
        activeBg.toHex(),
        highlight.toHex(),
        error.toHex(),
      ];

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? text,
    Color? textMuted,
    Color? primary,
    Color? primaryHover,
    Color? border,
    Color? borderStrong,
    Color? hoverBg,
    Color? activeBg,
    Color? highlight,
    Color? error,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      hoverBg: hoverBg ?? this.hoverBg,
      activeBg: activeBg ?? this.activeBg,
      highlight: highlight ?? this.highlight,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      hoverBg: Color.lerp(hoverBg, other.hoverBg, t)!,
      activeBg: Color.lerp(activeBg, other.activeBg, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension ColorHex on Color {
  String toHex() =>
      '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
