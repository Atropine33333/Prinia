import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_shell.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/ledger/ledger_edit_page.dart';

final shellKey = GlobalKey<AppShellState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 本地通知初始化（饭点提醒 / 课程提醒）
  unawaited(NotificationService.init());
  NotificationService.registerTapHandler(_handleNotificationTap);
  runApp(const ProviderScope(child: PriniaApp()));
}

void _handleNotificationTap(String payload) {
  switch (payload) {
    case 'ledger_add':
      shellKey.currentState?.switchTo(0);
      final ctx = shellKey.currentContext;
      if (ctx != null) {
        Navigator.of(ctx, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const LedgerEditPage()),
        );
      }
  }
}

class PriniaApp extends ConsumerWidget {
  const PriniaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(activeColorsProvider);
    return MaterialApp(
      title: 'Prinia',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(colors),
      home: AppShell(key: shellKey),
    );
  }
}
