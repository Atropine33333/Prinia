import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/database.dart';
import '../../core/db/db_provider.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_colors.dart';
import 'timetable_providers.dart';

/// 课程卡片预设色（低饱和 Morandi）。
const coursePalette = [
  '#7A9E9F', '#A89B8C', '#9B8AA0', '#8FA387',
  '#B08D8D', '#8896AB', '#B5A37E', '#96A0B5',
];

/// 新建/编辑课程。[existing] 为空表示新建。
class CourseEditPage extends ConsumerStatefulWidget {
  final CourseRow? existing;
  final int initialWeekday;
  final int initialHour; // 仅作为初始分钟数的整小时入口

  const CourseEditPage({
    super.key,
    this.existing,
    this.initialWeekday = 1,
    this.initialHour = 8,
  });

  @override
  ConsumerState<CourseEditPage> createState() => _CourseEditPageState();
}

class _CourseEditPageState extends ConsumerState<CourseEditPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _teacherCtrl;
  late TextEditingController _roomCtrl;
  late Set<int> _weekdays;
  late int _startWeek;
  late int _endWeek;
  late int _startMinutes;
  late int _durationMinutes;
  late String _colorHex;
  late List<CourseReminder> _reminders;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name);
    _teacherCtrl = TextEditingController(text: e?.teacher);
    _roomCtrl = TextEditingController(text: e?.room);
    _weekdays = e != null ? {e.weekday} : {widget.initialWeekday};
    _startWeek = e?.startWeek ?? 1;
    _endWeek = e?.endWeek ?? 16;
    _startMinutes = e?.startMinutes ?? widget.initialHour * 60;
    _durationMinutes = e?.durationMinutes ?? 60;
    _colorHex = e?.colorHex ??
        coursePalette[(e == null ? widget.initialWeekday : e.id) % coursePalette.length];
    _reminders = e == null ? [] : parseReminders(e.remindersJson);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '课程详情' : '新建课程'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameCtrl,
            maxLength: 20,
            style: TextStyle(color: colors.text, fontSize: 17),
            decoration: const InputDecoration(
              hintText: '课程名称',
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _teacherCtrl,
                  style: TextStyle(color: colors.text),
                  decoration: const InputDecoration(hintText: '教师（可选）'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _roomCtrl,
                  style: TextStyle(color: colors.text),
                  decoration: const InputDecoration(hintText: '教室（可选）'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 星期
          _SectionLabel('星期'),
          Wrap(
            spacing: 8,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  label: Text('周${'一二三四五六日'[d - 1]}'),
                  selected: _weekdays.contains(d),
                  onSelected: (on) {
                    setState(() {
                      if (on) {
                        _weekdays.add(d);
                      } else if (_weekdays.length > 1) {
                        _weekdays.remove(d);
                      }
                    });
                  },
                  selectedColor: colors.activeBg,
                  labelStyle: TextStyle(color: colors.text),
                  side: BorderSide(
                      color: _weekdays.contains(d)
                          ? colors.primary
                          : colors.border),
                  showCheckmark: false,
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 时间（15 分钟步进）
          _SectionLabel('时间（${_fmt(_startMinutes)} – ${_fmt(_startMinutes + _durationMinutes)}）'),
          Row(
            children: [
              _Stepper(
                label: '开始',
                value: 0,
                min: 0,
                max: 0,
                onChanged: (_) {},
                customText: _fmt(_startMinutes),
                onDown: () => setState(() {
                  if (_startMinutes >= 15) _startMinutes -= 15;
                }),
                onUp: () => setState(() {
                  if (_startMinutes + _durationMinutes <= 24 * 60 - 15) {
                    _startMinutes += 15;
                  }
                }),
              ),
              const SizedBox(width: 16),
              _Stepper(
                label: '时长',
                value: 0,
                min: 0,
                max: 0,
                onChanged: (_) {},
                customText: _durText(_durationMinutes),
                onDown: () => setState(() {
                  if (_durationMinutes > 15) _durationMinutes -= 15;
                }),
                onUp: () => setState(() {
                  if (_startMinutes + _durationMinutes <= 24 * 60 - 15) {
                    _durationMinutes += 15;
                  }
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 周次
          _SectionLabel('周次（第 $_startWeek ~ $_endWeek 周）'),
          Row(
            children: [
              _Stepper(
                label: '起',
                value: _startWeek,
                min: 1,
                max: _endWeek,
                onChanged: (v) => setState(() => _startWeek = v),
              ),
              const SizedBox(width: 16),
              _Stepper(
                label: '止',
                value: _endWeek,
                min: _startWeek,
                max: 30,
                onChanged: (v) => setState(() => _endWeek = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 颜色
          _SectionLabel('卡片颜色'),
          Wrap(
            spacing: 10,
            children: [
              for (final hex in coursePalette)
                GestureDetector(
                  onTap: () => setState(() => _colorHex = hex),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Color(int.parse(hex.substring(1), radix: 16) |
                          0xFF000000),
                      shape: BoxShape.circle,
                      border: _colorHex == hex
                          ? Border.all(
                              color: colors.text, width: 2.5)
                          : Border.all(color: colors.border),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // 提醒
          Row(
            children: [
              _SectionLabel('自定义提醒'),
              const Spacer(),
              TextButton.icon(
                onPressed: _addReminder,
                icon: Icon(Icons.add, size: 18, color: colors.primary),
                label: Text('添加提醒',
                    style: TextStyle(color: colors.primary, fontSize: 13)),
              ),
            ],
          ),
          for (var i = 0; i < _reminders.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.alarm, size: 18, color: colors.primary),
              title: Text(_reminders[i].text,
                  style: TextStyle(fontSize: 14, color: colors.text)),
              subtitle: Text(
                '${DateFormat('yyyy-MM-dd').format(_reminders[i].date)} 8:00 提醒',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
              trailing: IconButton(
                icon: Icon(Icons.close,
                    size: 18, color: colors.textMuted),
                onPressed: () => setState(() => _reminders.removeAt(i)),
              ),
            ),
          if (_reminders.isEmpty)
            Text('如「第 5 周前交作业」，将在截止日当天 8:00 通知你',
                style: TextStyle(fontSize: 12, color: colors.textMuted)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text(_isEdit ? '保存修改' : '保存',
                style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _addReminder() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('提醒内容'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLength: 30,
            decoration: const InputDecoration(hintText: '如：交作业 / 期中考试'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('取消',
                  style: TextStyle(color: colors.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: Text('确定', style: TextStyle(color: colors.primary)),
            ),
          ],
        );
      },
    );
    if (text == null || text.isEmpty || !mounted) return;
    setState(() => _reminders.add(CourseReminder(date: date, text: text)));
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('课程名称不能为空')),
      );
      return;
    }
    final db = ref.read(databaseProvider);
    final companion = CoursesCompanion.insert(
      name: name,
      teacher: Value(_teacherCtrl.text.trim().isEmpty
          ? null
          : _teacherCtrl.text.trim()),
      room: Value(
          _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim()),
      weekday: _weekdays.first,
      startWeek: _startWeek,
      endWeek: _endWeek,
      startMinutes: Value(_startMinutes),
      durationMinutes: Value(_durationMinutes),
      colorHex: Value(_colorHex),
      remindersJson: Value(encodeReminders(_reminders)),
    );

    if (_isEdit) {
      final id = widget.existing!.id;
      await NotificationService.cancelCourseReminders(
          id, parseReminders(widget.existing!.remindersJson).length);
      await db.coursesDao.updateCourse(id, companion);
      for (var i = 0; i < _reminders.length; i++) {
        await NotificationService.scheduleCourseReminder(
          courseId: id,
          reminderIndex: i,
          date: _reminders[i].date,
          text: '${widget.existing!.name}：${_reminders[i].text}',
        );
      }
    } else {
      // 多选星期：每天各建一条
      for (final wd in _weekdays) {
        final id = await db.coursesDao.insertCourse(
          companion.copyWith(weekday: Value(wd)),
        );
        for (var i = 0; i < _reminders.length; i++) {
          await NotificationService.scheduleCourseReminder(
            courseId: id,
            reminderIndex: i,
            date: _reminders[i].date,
            text: _reminders[i].text,
          );
        }
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这门课？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('取消', style: TextStyle(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('删除', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref
        .read(databaseProvider)
        .coursesDao
        .softDelete(widget.existing!.id);
    await NotificationService.cancelCourseReminders(
        widget.existing!.id,
        parseReminders(widget.existing!.remindersJson).length + 8);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _teacherCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }
}

String _fmt(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

String _durText(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m 分钟';
  if (m == 0) return '$h 小时';
  return '$h 小时 $m 分钟';
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textMuted)),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? customText;
  final VoidCallback? onDown;
  final VoidCallback? onUp;

  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.customText,
    this.onDown,
    this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
        color: colors.bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: colors.textMuted)),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDown ?? (value > min ? () => onChanged(value - 1) : null),
            icon: const Icon(Icons.remove, size: 18),
            color: colors.text,
          ),
          Text(customText ?? '$value',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.text)),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onUp ?? (value < max ? () => onChanged(value + 1) : null),
            icon: const Icon(Icons.add, size: 18),
            color: colors.text,
          ),
        ],
      ),
    );
  }
}
