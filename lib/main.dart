import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/presets.dart';
import 'core/theme/theme_controller.dart';

void main() {
  runApp(const ProviderScope(child: OctoNoteApp()));
}

class OctoNoteApp extends ConsumerWidget {
  const OctoNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(activeColorsProvider);
    return MaterialApp(
      title: 'OctoNote',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(colors),
      home: const HomePage(),
    );
  }
}

/// 临时占位首页：验证主题系统，后续替换为自适应导航外壳。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final id = ref.watch(themeControllerProvider);
    final name =
        presetThemes.where((p) => p.id == id).map((p) => p.name).firstOrNull ??
            id;
    return Scaffold(
      body: Center(
        child: Text(
          'OctoNote\n当前配色板：$name',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.text, fontSize: 18),
        ),
      ),
    );
  }
}
