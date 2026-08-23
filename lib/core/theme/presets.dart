import 'oklch.dart';
import 'app_colors.dart';

// 预设配色板。前四套取自 ref.css 的 oklch 原始定义，
// 后四套按同一 Adwaita/Morandi 低饱和风格补齐。

AppColors _palette({
  required double bgL, required double bgC, required double bgH,
  required double surfaceL, required double surfaceC,
  required double textL, required double textC, required double textH,
  required double mutedL, required double mutedC, required double mutedH,
  required double primaryL, required double primaryC, required double primaryH,
  double? primaryHoverL,
  required double borderL, required double borderC, required double borderH,
  required double borderStrongL,
  required double hoverL,
  required double activeL, required double activeC, required double activeH, required double activeA,
  required double highlightL, required double highlightC, required double highlightH,
  required double errorL, required double errorC, required double errorH,
}) {
  return AppColors(
    bg: oklch(bgL, bgC, bgH),
    surface: oklch(surfaceL, surfaceC, bgH),
    text: oklch(textL, textC, textH),
    textMuted: oklch(mutedL, mutedC, mutedH),
    primary: oklch(primaryL, primaryC, primaryH),
    primaryHover: oklch(primaryHoverL ?? primaryL - 0.07, primaryC, primaryH),
    border: oklch(borderL, borderC, borderH),
    borderStrong: oklch(borderStrongL, borderC, borderH),
    hoverBg: oklch(hoverL, bgC * 0.75, bgH),
    activeBg: oklch(activeL, activeC, activeH, alpha: activeA),
    highlight: oklch(highlightL, highlightC, highlightH),
    error: oklch(errorL, errorC, errorH),
  );
}

class ThemePreset {
  final String id;
  final String name;
  final AppColors colors;
  const ThemePreset(this.id, this.name, this.colors);
}

final presetThemes = <ThemePreset>[
  // ── ref.css 原生四套 ──────────────────────────────────────────
  ThemePreset('light', '亮白', _palette(
    bgL: 0.985, bgC: 0, bgH: 0,
    surfaceL: 0.99, surfaceC: 0,
    textL: 0.2, textC: 0, textH: 0,
    mutedL: 0.45, mutedC: 0, mutedH: 0,
    primaryL: 0.55, primaryC: 0.18, primaryH: 255,
    borderL: 0.88, borderC: 0, borderH: 0, borderStrongL: 0.75,
    hoverL: 0.95,
    activeL: 0.9, activeC: 0.15, activeH: 255, activeA: 0.15,
    highlightL: 0.92, highlightC: 0.17, highlightH: 100,
    errorL: 0.55, errorC: 0.18, errorH: 25,
  )),
  ThemePreset('cream', '米黄', _palette(
    bgL: 0.96, bgC: 0.015, bgH: 85,
    surfaceL: 0.94, surfaceC: 0.015,
    textL: 0.23, textC: 0.015, textH: 80,
    mutedL: 0.44, mutedC: 0.02, mutedH: 80,
    primaryL: 0.48, primaryC: 0.12, primaryH: 40,
    borderL: 0.85, borderC: 0.02, borderH: 85, borderStrongL: 0.72,
    hoverL: 0.91,
    activeL: 0.85, activeC: 0.06, activeH: 50, activeA: 0.15,
    highlightL: 0.88, highlightC: 0.14, highlightH: 95,
    errorL: 0.5, errorC: 0.15, errorH: 30,
  )),
  ThemePreset('dark', '暗夜', _palette(
    bgL: 0.2, bgC: 0.005, bgH: 260,
    surfaceL: 0.24, surfaceC: 0.005,
    textL: 0.88, textC: 0.003, textH: 260,
    mutedL: 0.58, mutedC: 0.005, mutedH: 260,
    primaryL: 0.65, primaryC: 0.14, primaryH: 240,
    primaryHoverL: 0.72,
    borderL: 0.3, borderC: 0.005, borderH: 260, borderStrongL: 0.4,
    hoverL: 0.27,
    activeL: 0.35, activeC: 0.08, activeH: 255, activeA: 0.2,
    highlightL: 0.35, highlightC: 0.1, highlightH: 90,
    errorL: 0.65, errorC: 0.15, errorH: 20,
  )),
  ThemePreset('mint', '青青', _palette(
    bgL: 0.95, bgC: 0.015, bgH: 160,
    surfaceL: 0.93, surfaceC: 0.015,
    textL: 0.25, textC: 0.015, textH: 175,
    mutedL: 0.45, mutedC: 0.015, mutedH: 170,
    primaryL: 0.5, primaryC: 0.07, primaryH: 180,
    borderL: 0.86, borderC: 0.02, borderH: 160, borderStrongL: 0.74,
    hoverL: 0.9,
    activeL: 0.85, activeC: 0.05, activeH: 180, activeA: 0.15,
    highlightL: 0.88, highlightC: 0.1, highlightH: 130,
    errorL: 0.5, errorC: 0.14, errorH: 25,
  )),
  // ── 补齐四套 ─────────────────────────────────────────────────
  ThemePreset('pink', '樱花', _palette(
    bgL: 0.96, bgC: 0.012, bgH: 350,
    surfaceL: 0.94, surfaceC: 0.012,
    textL: 0.24, textC: 0.02, textH: 340,
    mutedL: 0.45, mutedC: 0.02, mutedH: 345,
    primaryL: 0.58, primaryC: 0.1, primaryH: 5,
    borderL: 0.87, borderC: 0.015, borderH: 350, borderStrongL: 0.74,
    hoverL: 0.91,
    activeL: 0.85, activeC: 0.06, activeH: 5, activeA: 0.15,
    highlightL: 0.88, highlightC: 0.09, highlightH: 100,
    errorL: 0.52, errorC: 0.16, errorH: 25,
  )),
  ThemePreset('blue', '海蓝', _palette(
    bgL: 0.95, bgC: 0.01, bgH: 230,
    surfaceL: 0.93, surfaceC: 0.012,
    textL: 0.23, textC: 0.015, textH: 240,
    mutedL: 0.44, mutedC: 0.015, mutedH: 235,
    primaryL: 0.45, primaryC: 0.06, primaryH: 240,
    borderL: 0.85, borderC: 0.015, borderH: 230, borderStrongL: 0.72,
    hoverL: 0.9,
    activeL: 0.84, activeC: 0.05, activeH: 240, activeA: 0.15,
    highlightL: 0.88, highlightC: 0.08, highlightH: 200,
    errorL: 0.52, errorC: 0.15, errorH: 25,
  )),
  ThemePreset('gray', '侘寂', _palette(
    bgL: 0.94, bgC: 0.004, bgH: 90,
    surfaceL: 0.92, surfaceC: 0.004,
    textL: 0.25, textC: 0.006, textH: 90,
    mutedL: 0.46, mutedC: 0.006, mutedH: 90,
    primaryL: 0.44, primaryC: 0.03, primaryH: 80,
    borderL: 0.83, borderC: 0.006, borderH: 90, borderStrongL: 0.7,
    hoverL: 0.89,
    activeL: 0.82, activeC: 0.02, activeH: 80, activeA: 0.18,
    highlightL: 0.86, highlightC: 0.04, highlightH: 95,
    errorL: 0.5, errorC: 0.13, errorH: 28,
  )),
  ThemePreset('forest', '森绿', _palette(
    bgL: 0.95, bgC: 0.012, bgH: 150,
    surfaceL: 0.93, surfaceC: 0.014,
    textL: 0.24, textC: 0.015, textH: 155,
    mutedL: 0.44, mutedC: 0.015, mutedH: 152,
    primaryL: 0.46, primaryC: 0.07, primaryH: 150,
    borderL: 0.85, borderC: 0.016, borderH: 150, borderStrongL: 0.71,
    hoverL: 0.9,
    activeL: 0.84, activeC: 0.05, activeH: 150, activeA: 0.15,
    highlightL: 0.88, highlightC: 0.09, highlightH: 120,
    errorL: 0.52, errorC: 0.15, errorH: 25,
  )),
];
