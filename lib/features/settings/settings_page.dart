import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/presets.dart';
import '../../core/theme/theme_controller.dart';
import '../timetable/timetable_providers.dart';
import 'theme_editor_page.dart';

/// 设置页。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _mealReminder = false;

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final pending = await NotificationService.pendingCount();
    if (mounted) setState(() => _mealReminder = pending >= 2);
  }

  Future<void> _toggleMealReminder(bool v) async {
    if (v) {
      final granted = await NotificationService.requestPermission();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未授予通知权限，无法提醒')),
        );
        return;
      }
    }
    await NotificationService.setMealReminder(v);
    if (mounted) setState(() => _mealReminder = v);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final activeId = ref.watch(themeControllerProvider);
    final semesterStart = ref.watch(semesterStartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 主题 ──
          _SectionTitle('配色板'),
          const SizedBox(height: 8),
          for (final p in presetThemes)
            _ThemeTile(
              name: p.name,
              colors: p.colors,
              selected: activeId == p.id,
              onTap: () =>
                  ref.read(themeControllerProvider.notifier).select(p.id),
            ),
          // 自定义配色板
          for (final entry in ThemeController.loadCustomThemes().entries)
            Dismissible(
              key: ValueKey(entry.key),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: colors.error.withValues(alpha: 0.15),
                child: Icon(Icons.delete_outline, color: colors.error),
              ),
              confirmDismiss: (_) async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('删除「${entry.key}」？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('取消',
                            style: TextStyle(color: colors.textMuted)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child:
                            Text('删除', style: TextStyle(color: colors.error)),
                      ),
                    ],
                  ),
                );
                return ok == true;
              },
              onDismissed: (_) =>
                  ref.read(themeControllerProvider.notifier).deleteCustomTheme(
                        entry.key,
                      ),
              child: _ThemeTile(
                name: entry.key,
                colors: entry.value,
                selected: activeId == entry.key,
                onTap: () => ref
                    .read(themeControllerProvider.notifier)
                    .select(entry.key),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThemeEditorPage()),
            ),
            icon: Icon(Icons.palette_outlined, size: 18),
            label: const Text('创建自定义配色板'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
          // ── 提醒 ──
          _SectionTitle('提醒'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('饭点记账提醒',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text('每天 12:00 / 18:00 提醒你记账',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            value: _mealReminder,
            activeThumbColor: colors.primary,
            onChanged: _toggleMealReminder,
          ),
          const SizedBox(height: 24),
          // ── 课表 ──
          _SectionTitle('课表'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('学期开始日期（第 1 周周一）',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text(
              DateFormat('yyyy-MM-dd').format(semesterStart),
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: colors.textMuted),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: semesterStart,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (d != null) {
                // 对齐到周一
                final monday = d.subtract(Duration(days: d.weekday - 1));
                await ref.read(semesterStartProvider.notifier).set(monday);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Text(text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textMuted));
  }
}

class _ThemeTile extends StatelessWidget {
  final String name;
  final AppColors colors;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.name,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: // 三色预览
          SizedBox(
        width: 54,
        height: 32,
        child: Row(
          children: [
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        color: colors.bg,
                        border: Border.all(color: c.border),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(8))))),
            Expanded(child: Container(color: colors.surface)),
            Expanded(
                child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(8))),
                    child: ColoredBox(color: colors.primary))),
          ],
        ),
      ),
      title: Text(name,
          style: TextStyle(
              fontSize: 15,
              color: selected ? c.primary : c.text,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal)),
      trailing: selected
          ? Icon(Icons.check, color: c.primary, size: 20)
          : null,
    );
  }
}
