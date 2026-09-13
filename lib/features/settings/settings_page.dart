import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/db_provider.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/sync/device_identity.dart';
import '../../core/update/update_service.dart';
import '../../core/sync/bluetooth_transport.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/sync/sync_targets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/presets.dart';
import '../../core/theme/theme_controller.dart';
import '../../shared/responsive.dart';
import '../timetable/period_editor_page.dart';
import '../timetable/periods.dart';
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
  TimeOfDay _first = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _second = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final sp = await SharedPreferences.getInstance();
    final f = sp.getString('meal_first');
    final s2 = sp.getString('meal_second');
    if (!mounted) return;
    if (f != null) _first = _parseTod(f);
    if (s2 != null) _second = _parseTod(s2);
    final pending = await NotificationService.pendingCount();
    if (mounted) setState(() => _mealReminder = pending >= 2);
  }

  static TimeOfDay _parseTod(String s) {
    final parts = s.split(':');
    return TimeOfDay(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _fmtTod(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _applyReminder(bool enabled) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('meal_first', _fmtTod(_first));
    await sp.setString('meal_second', _fmtTod(_second));
    await NotificationService.setMealReminder(
      enabled,
      firstHour: _first.hour,
      firstMinute: _first.minute,
      secondHour: _second.hour,
      secondMinute: _second.minute,
    );
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
    await _applyReminder(v);
    if (mounted) setState(() => _mealReminder = v);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final activeId = ref.watch(themeControllerProvider);
    final semesterStart = ref.watch(semesterStartProvider);
    final periods = ref.watch(periodsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ResponsiveFormBox(
        child: ListView(
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
            subtitle: Text('每天提醒你记账',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            value: _mealReminder,
            activeThumbColor: colors.primary,
            onChanged: _toggleMealReminder,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('第一次提醒',
                style: TextStyle(color: colors.text, fontSize: 15)),
            trailing: Text(_fmtTod(_first),
                style: TextStyle(fontSize: 15, color: colors.primary)),
            onTap: () async {
              final t = await showTimePicker(
                  context: context, initialTime: _first);
              if (t != null) {
                setState(() => _first = t);
                if (_mealReminder) await _applyReminder(true);
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('第二次提醒',
                style: TextStyle(color: colors.text, fontSize: 15)),
            trailing: Text(_fmtTod(_second),
                style: TextStyle(fontSize: 15, color: colors.primary)),
            onTap: () async {
              final t = await showTimePicker(
                  context: context, initialTime: _second);
              if (t != null) {
                setState(() => _second = t);
                if (_mealReminder) await _applyReminder(true);
              }
            },
          ),
          const SizedBox(height: 24),
          // ── 课表 ──
          _SectionTitle('课表'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('课程名字号',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Slider(
              value: ref.watch(timetableFontProvider),
              min: 10,
              max: 22,
              divisions: 12,
              label: ref.watch(timetableFontProvider).toStringAsFixed(0),
              activeColor: colors.primary,
              onChanged: (v) =>
                  ref.read(timetableFontProvider.notifier).set(v),
            ),
          ),
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
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('自定义作息',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text(
              '${periods.length} 节 · '
              '${formatMinutes(periods.first.startMinutes)}'
              '–${formatMinutes(periods.last.endMinutes)}',
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: colors.textMuted),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PeriodEditorPage()),
            ),
          ),
          const SizedBox(height: 24),
          // ── 多设备同步 ──
          _SectionTitle('多设备同步'),
          Consumer(builder: (ctx, sref, _) {
            final st = sref.watch(syncManagerProvider);
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('状态',
                      style:
                          TextStyle(color: colors.text, fontSize: 15)),
                  subtitle: Text(
                    st.status.isEmpty ? _phaseText(st.phase) : st.status,
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
                  ),
                ),
                _SyncDevicePicker(colors: colors),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('本机设备名',
                      style:
                          TextStyle(color: colors.text, fontSize: 15)),
                  subtitle: Text(DeviceIdentity.name,
                      style:
                          TextStyle(color: colors.textMuted, fontSize: 12)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('最近同步',
                      style:
                          TextStyle(color: colors.text, fontSize: 15)),
                  subtitle: Text(
                    st.lastSyncAt == null
                        ? '从未'
                        : DateFormat('yyyy-MM-dd HH:mm')
                            .format(st.lastSyncAt!),
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: st.phase == SyncPhase.syncing
                        ? null
                        : () =>
                            sref.read(syncManagerProvider.notifier).syncNow(),
                    icon: st.phase == SyncPhase.syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2))
                        : Icon(Icons.sync, size: 18),
                    label: const Text('立即同步'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(
                          color:
                              colors.primary.withValues(alpha: 0.4)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Text('两台设备需先在系统蓝牙中配对；同步通过蓝牙完成，无需网络',
                    style: TextStyle(
                        fontSize: 11, color: colors.textMuted)),
              ],
            );
          }),
          const SizedBox(height: 24),
          // ── 关于 ──
          _SectionTitle('关于'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('版本',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text('1.2.2',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('检查更新',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text('从 GitHub 获取最新版本（默认下载 arm64-v8a 包）',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: colors.textMuted),
            onTap: () => UpdateService.manualCheck(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('开源许可证',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text('Apache License 2.0 及各依赖组件许可',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: colors.textMuted),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const OpenSourceLicensesPage()),
            ),
          ),
          const SizedBox(height: 24),
          // ── 危险区 ──
          _SectionTitle('数据'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('清除课程表数据',
                style: TextStyle(color: colors.error, fontSize: 15)),
            subtitle: Text('删除全部课程（测试用，自定义作息保留）',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            onTap: () => _confirmClearCourses(colors),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('清除本地数据',
                style: TextStyle(color: colors.error, fontSize: 15)),
            subtitle: Text('清空账目/专注记录/课程/自定义标签，不可恢复',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            onTap: () => _confirmClearData(colors),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _confirmClearCourses(AppColors colors) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除全部课程？'),
        content: Text('课程表中的所有课程都将被删除（含已删除记录），且不可恢复。自定义作息不受影响。',
            style: TextStyle(color: colors.textMuted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('取消', style: TextStyle(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('清除', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(databaseProvider).clearAllCourses();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('课程表已清空')),
      );
    }
  }

  Future<void> _confirmClearData(AppColors colors) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除全部本地数据？'),
        content: Text('账目、专注记录、课程、自定义标签都将被清空，且不可恢复。',
            style: TextStyle(color: colors.textMuted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('取消', style: TextStyle(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('清除', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(databaseProvider).clearAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已清除')),
      );
    }
  }
}

/// 已配对设备勾选列表：勾选者参与同步轮询。
class _SyncDevicePicker extends ConsumerStatefulWidget {
  final AppColors colors;
  const _SyncDevicePicker({required this.colors});

  @override
  ConsumerState<_SyncDevicePicker> createState() => _SyncDevicePickerState();
}

class _SyncDevicePickerState extends ConsumerState<_SyncDevicePicker> {
  List<({String address, String name})>? _bonded;

  @override
  void initState() {
    super.initState();
    PriniaBluetooth.bondedDevices().then((list) {
      if (mounted) setState(() => _bonded = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(syncTargetsProvider);
    final bonded = _bonded ?? const [];
    if (bonded.isEmpty) {
      return Text('未检测到已配对蓝牙设备',
          style: TextStyle(fontSize: 12, color: widget.colors.textMuted));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('参与同步的设备（未勾选的不参与轮询）',
            style: TextStyle(fontSize: 12, color: widget.colors.textMuted)),
        for (final d in bonded)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(d.name,
                style: TextStyle(fontSize: 14, color: widget.colors.text)),
            subtitle: Text(d.address,
                style:
                    TextStyle(fontSize: 11, color: widget.colors.textMuted)),
            value: SyncTargetsController.isSelected(selection, d.address),
            onChanged: (_) => ref
                .read(syncTargetsProvider.notifier)
                .toggle(d.address, [for (final x in bonded) x.address]),
            activeColor: widget.colors.primary,
          ),
      ],
    );
  }
}

String _phaseText(SyncPhase p) => switch (p) {
      SyncPhase.off => '未启动',
      SyncPhase.starting => '启动中…',
      SyncPhase.listening => '同步准备就绪',
      SyncPhase.connecting => '连接中…',
      SyncPhase.syncing => '同步中…',
    };

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

/// 开源许可证页（Flutter 内置 LicensePage，自动汇总全部依赖许可）。
class OpenSourceLicensesPage extends StatelessWidget {
  const OpenSourceLicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('开源许可证')),
      body: const LicensePage(
        applicationName: 'Prinia',
        applicationVersion: '1.2.2',
        applicationLegalese: 'Prinia · 记账、番茄钟与课表的本地效率工具',
      ),
    );
  }
}
