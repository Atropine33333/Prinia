import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_shell.dart';
import 'core/theme/app_theme.dart';
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
      title: 'Prinia',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(colors),
      home: const AppShell(),
    );
  }
}
