import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../features/ledger/ledger_page.dart';
import '../features/pomodoro/pomodoro_page.dart';
import 'placeholder_page.dart';

/// 应用主外壳：手机底部导航 / 平板侧边导航。
///
/// 断点 600dp；三个标签共用 [IndexedStack] 保持各页状态。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _railExtended = false;

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
      const PlaceholderPage(label: '课表'),
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

        return Scaffold(
          body: Row(
            children: [
              Column(
                children: [
                  // 收起/展开按钮
                  IconButton(
                    onPressed: () =>
                        setState(() => _railExtended = !_railExtended),
                    icon: Icon(
                      _railExtended
                          ? Icons.menu_open
                          : Icons.menu,
                      color: colors.textMuted,
                    ),
                    tooltip: _railExtended ? '收起' : '展开',
                  ),
                  Expanded(
                    child: NavigationRail(
                      extended: _railExtended,
                      minExtendedWidth: 160,
                      labelType: _railExtended
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      selectedIndex: _index,
                      onDestinationSelected: (i) =>
                          setState(() => _index = i),
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: _railExtended
                            ? null
                            : Icon(Icons.sticky_note_2,
                                color: colors.primary),
                      ),
                      destinations: [
                        for (final d in _destinations)
                          NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selectedIcon),
                            label: Text(d.label),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              // 侧栏与内容区分隔线
              VerticalDivider(width: 1, color: colors.border),
              Expanded(
                child: IndexedStack(index: _index, children: pages),
              ),
            ],
          ),
        );
      },
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
