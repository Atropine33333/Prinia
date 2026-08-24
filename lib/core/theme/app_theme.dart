import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 全局字体：优先 Mi Sans，其次 Noto Sans，避免系统自定义字体导致字形怪异。
const globalFontFallback = [
  'MiSans',
  'MiSans VF',
  'Noto Sans CJK SC',
  'Noto Sans SC',
  'sans-serif',
];

TextTheme _withFontFallback(TextTheme t) => t.copyWith(
      displayLarge: t.displayLarge?.copyWith(fontFamilyFallback: globalFontFallback),
      displayMedium: t.displayMedium?.copyWith(fontFamilyFallback: globalFontFallback),
      displaySmall: t.displaySmall?.copyWith(fontFamilyFallback: globalFontFallback),
      headlineLarge: t.headlineLarge?.copyWith(fontFamilyFallback: globalFontFallback),
      headlineMedium: t.headlineMedium?.copyWith(fontFamilyFallback: globalFontFallback),
      headlineSmall: t.headlineSmall?.copyWith(fontFamilyFallback: globalFontFallback),
      titleLarge: t.titleLarge?.copyWith(fontFamilyFallback: globalFontFallback),
      titleMedium: t.titleMedium?.copyWith(fontFamilyFallback: globalFontFallback),
      titleSmall: t.titleSmall?.copyWith(fontFamilyFallback: globalFontFallback),
      bodyLarge: t.bodyLarge?.copyWith(fontFamilyFallback: globalFontFallback),
      bodyMedium: t.bodyMedium?.copyWith(fontFamilyFallback: globalFontFallback),
      bodySmall: t.bodySmall?.copyWith(fontFamilyFallback: globalFontFallback),
      labelLarge: t.labelLarge?.copyWith(fontFamilyFallback: globalFontFallback),
      labelMedium: t.labelMedium?.copyWith(fontFamilyFallback: globalFontFallback),
      labelSmall: t.labelSmall?.copyWith(fontFamilyFallback: globalFontFallback),
    );

/// 干脆利落的页面转场（150ms 淡入淡出，无拖泥带水）。
class FastPageTransitionsBuilder extends PageTransitionsBuilder {
  const FastPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 1, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(curved),
      child: child,
    );
  }
}

/// 由 [AppColors] 构建完整 [ThemeData]（Material 3）。
ThemeData buildThemeData(AppColors c) {
  final base = ThemeData(useMaterial3: true);
  final isDark = c.text.computeLuminance() > 0.5;

  return base.copyWith(
    textTheme: _withFontFallback(base.textTheme),
    primaryTextTheme: _withFontFallback(base.primaryTextTheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FastPageTransitionsBuilder(),
        TargetPlatform.windows: FastPageTransitionsBuilder(),
        TargetPlatform.linux: FastPageTransitionsBuilder(),
        TargetPlatform.iOS: FastPageTransitionsBuilder(),
        TargetPlatform.macOS: FastPageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
    colorScheme: ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: c.primary,
      onPrimary: c.bg,
      secondary: c.primary,
      onSecondary: c.bg,
      error: c.error,
      onError: c.bg,
      surface: c.surface,
      onSurface: c.text,
      outline: c.border,
      outlineVariant: c.border,
      surfaceContainerHighest: c.hoverBg,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: c.border),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.primary),
      ),
      hintStyle: TextStyle(color: c.textMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primary.withValues(alpha: 0.16),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? c.primary
              : c.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.normal,
          color: states.contains(WidgetState.selected)
              ? c.primary
              : c.textMuted,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.activeBg,
      selectedIconTheme: IconThemeData(color: c.primary),
      unselectedIconTheme: IconThemeData(color: c.textMuted),
      selectedLabelTextStyle: TextStyle(color: c.text, fontSize: 13),
      unselectedLabelTextStyle: TextStyle(color: c.textMuted, fontSize: 13),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.text,
      contentTextStyle: TextStyle(color: c.bg),
      behavior: SnackBarBehavior.floating,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: c.primary),
    ),
    iconTheme: IconThemeData(color: c.text),
  );
}
