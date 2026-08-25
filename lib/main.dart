import 'dart:async';
import 'dart:io';

import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_shell.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/sync/device_identity.dart';
import 'core/theme/theme_controller.dart';
import 'features/ledger/ledger_edit_page.dart';

final shellKey = GlobalKey<AppShellState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceIdentity.load(); // 同步身份必须先于任何数据库写入
  unawaited(_enableHighRefreshRate());
  unawaited(initializeDateFormatting('zh_CN'));
  // 本地通知初始化（饭点提醒 / 课程提醒）
  unawaited(NotificationService.init());
  NotificationService.registerTapHandler(_handleNotificationTap);
  runApp(const ProviderScope(child: PriniaApp()));
}

/// 请求设备最高刷新率（如 120fps）；不支持则系统自动回退 60fps。
Future<void> _enableHighRefreshRate() async {
  try {
    if (!Platform.isAndroid) return;
    final modes = await FlutterDisplayMode.supported;
    final best = modes.reduce(
        (a, b) => a.refreshRate > b.refreshRate ? a : b);
    await FlutterDisplayMode.setPreferredMode(best);
  } catch (_) {
    // 平台不支持时静默忽略
  }
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
