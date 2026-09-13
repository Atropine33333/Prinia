import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/backup/backup_service.dart';
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
import '../timetable/schedule_import.dart';
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
            subtitle: Text('2.0.0',
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
            title: Text('导出数据备份',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text('生成 JSON 备份并分享保存（换包名/换机迁移用）',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            onTap: _exportBackup,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('导入数据备份',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text('从备份恢复数据与设置（按行合并，不清空现有数据）',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            onTap: _importBackup,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('导入课表 JSON',
                style: TextStyle(color: colors.text, fontSize: 15)),
            subtitle: Text('按统一格式追加导入课程，不覆盖现有课程',
                style: TextStyle(color: colors.textMuted, fontSize: 12)),
            onTap: _importScheduleJson,
          ),
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

  /// 导出全部数据为 JSON 备份，并通过系统分享交给用户保存。
  Future<void> _exportBackup() async {
    try {
      final json = await exportBackup(ref.read(databaseProvider));
      final dir = await getTemporaryDirectory();
      final stamp = DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
      final file = File('${dir.path}/prinia-backup-$stamp.json');
      await file.writeAsString(json);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Prinia 数据备份',
        text: '保存后可在 Prinia「设置 → 数据 → 导入数据备份」中还原',
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    }
  }

  /// 从 JSON 备份恢复数据（逐行 LWW 合并 + 偏好覆盖）。
  Future<void> _importBackup() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final file = await openFile();
    if (file == null || !mounted) return;
    final source = await file.readAsString();
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入数据备份'),
        content: Text(
          '将把备份中的数据合并到本机（相同 uuid 以更新的时间戳为准），并恢复主题、'
          '番茄钟时长等设置。主题与番茄钟设置需重启应用后生效。',
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('取消', style: TextStyle(color: colors.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('导入'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final db = ref.read(databaseProvider);
      final result = await importBackup(source, db);
      // 备份里的课程提醒需要按本机重新调度
      final courses = await db.coursesDao.watchAll().first;
      await NotificationService.rescheduleCourseReminders([
        for (final c in courses)
          (uuid: c.uuid, name: c.name, remindersJson: c.remindersJson),
      ]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('已导入 ${result.applied} 条数据'
              '（跳过 ${result.skipped} 条旧数据），恢复 ${result.prefs} 项设置'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败：$e')),
        );
      }
    }
  }

  /// 选择统一格式 JSON 文件，解析后追加导入课程表。
  Future<void> _importScheduleJson() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final file = await openFile();
    if (file == null || !mounted) return;
    final source = await file.readAsString();
    if (!mounted) return;

    final report =
        parseScheduleJson(source, periods: ref.read(periodsProvider));
    if (report.isEmpty) {
      final reason =
          report.skipped.isEmpty ? '文件格式不正确' : report.skipped.first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('没有可导入的安排：$reason')),
      );
      return;
    }

    final currentStart = ref.read(semesterStartProvider);
    final termText = report.termStart == null
        ? '\n\n注意：文件未提供学期开始日期，周次/单双周可能不准，'
            '请到「设置 → 课表」手动核对。'
        : '\n\n学期开始日期将设为 '
            '${DateFormat('yyyy-MM-dd').format(report.termStart!)}'
            '（当前 ${DateFormat('yyyy-MM-dd').format(currentStart)}，'
            '用于计算周次与单双周）。';
    final skipText = report.skipped.isEmpty
        ? ''
        : '\n\n跳过 ${report.skipped.length} 条：\n'
            '${report.skipped.take(5).join('\n')}'
            '${report.skipped.length > 5 ? '\n…' : ''}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入课表'),
        content: Text(
          '将新增 ${report.rows.length} 条课程安排并追加到现有课表。'
          '$termText$skipText',
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('取消', style: TextStyle(color: colors.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('导入'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final count =
        await insertImportedRows(ref.read(databaseProvider), report.rows);
    if (report.termStart != null) {
      // 对齐到周一（第 1 周周一），保证周次与单双周与文件一致
      final d = report.termStart!;
      final monday = d.subtract(Duration(days: d.weekday - 1));
      await ref.read(semesterStartProvider.notifier).set(monday);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已导入 $count 条课程安排'
              '${report.termStart == null ? '' : '，学期开始日期已更新'}'),
        ),
      );
    }
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
        applicationVersion: '2.0.0',
        applicationLegalese: 'Prinia · 记账、番茄钟与课表的本地效率工具',
      ),
    );
  }
}
