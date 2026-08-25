import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../features/ledger/ledger_page.dart';
import '../features/pomodoro/pomodoro_page.dart';
import '../features/settings/settings_page.dart';
import '../features/timetable/timetable_page.dart';

/// 应用主外壳：手机底部导航 / 平板侧边导航。
///
/// 断点 600dp；三个标签共用 [IndexedStack] 保持各页状态。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _index = 0;

  /// 平板侧栏：0~2 主页面，3 = 设置。
  int _railIndex = 0;

  /// 通知点击等外部入口切换到指定主页面（0=记账本）。
  void switchTo(int index) => setState(() {
        _index = index;
        _railIndex = index;
      });

  static const _destinations = [
    _Destination(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: '记账本',
    ),
    _Destination(
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
      label: '番茄钟',
    ),
    _Destination(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      label: '课表',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final pages = [
      const LedgerPage(),
      const PomodoroPage(),
      const TimetablePage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        if (!isTablet) {
          return Scaffold(
            body: IndexedStack(index: _index, children: pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        // ── 平板：常驻侧边栏（参考 Kazumi）──
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                backgroundColor: colors.surface,
                groupAlignment: 1,
                labelType: NavigationRailLabelType.selected,
                selectedIndex: _railIndex,
                onDestinationSelected: (i) =>
                    setState(() => _railIndex = i),
                selectedIconTheme:
                    IconThemeData(size: 30, color: colors.primary),
                unselectedIconTheme:
                    IconThemeData(size: 28, color: colors.textMuted),
                selectedLabelTextStyle:
                    TextStyle(color: colors.text, fontSize: 14),
                unselectedLabelTextStyle:
                    TextStyle(color: colors.textMuted, fontSize: 13),
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('设置'),
                  ),
                ],
              ),
              VerticalDivider(width: 1, color: colors.border),
              Expanded(
                child: _railIndex == 3
                    ? const SettingsPage()
                    : IndexedStack(index: _railIndex, children: pages),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 各页 AppBar 共用的设置入口（手机用）。
class SettingsAction extends StatelessWidget {
  const SettingsAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '设置',
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      ),
    );
  }
}

class _Destination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
