import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/responsive.dart';
import 'periods.dart';
import 'timetable_providers.dart';

/// 自定义作息编辑页：增删节次、调整每节起止时间。
class PeriodEditorPage extends ConsumerStatefulWidget {
  const PeriodEditorPage({super.key});

  @override
  ConsumerState<PeriodEditorPage> createState() => _PeriodEditorPageState();
}

class _PeriodEditorPageState extends ConsumerState<PeriodEditorPage> {
  late List<CoursePeriod> _draft;

  @override
  void initState() {
    super.initState();
    _draft = List.of(ref.read(periodsProvider));
  }

  void _replace(int i, {int? start, int? end}) {
    final p = _draft[i];
    setState(() {
      _draft[i] =
          CoursePeriod(i + 1, start ?? p.startMinutes, end ?? p.endMinutes);
    });
  }

  static int _snap5(int m) => ((m + 2) ~/ 5) * 5;

  Future<void> _pickTime(int i, {required bool isStart}) async {
    final p = _draft[i];
    final minutes = isStart ? p.startMinutes : p.endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (picked == null) return;
    final snapped = _snap5(picked.hour * 60 + picked.minute);
    if (isStart) {
      _replace(i, start: snapped);
    } else {
      _replace(i, end: snapped);
    }
  }

  void _add() {
    final last = _draft.isEmpty ? null : _draft.last;
    final start = _snap5(last == null ? 8 * 60 : last.endMinutes + 10);
    final duration = last?.durationMinutes ?? 45;
    final end = start + duration > 24 * 60 ? 24 * 60 : start + duration;
    setState(() => _draft.add(CoursePeriod(_draft.length + 1, start, end)));
  }

  Future<void> _save() async {
    final error = validatePeriods(_draft);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await ref.read(periodsProvider.notifier).set(_draft);
    if (mounted) Navigator.of(context).pop();
  }

  void _resetToDefault() => setState(() => _draft = List.of(defaultPeriods));

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义作息'),
        actions: [
          TextButton(
            onPressed: _resetToDefault,
            child: const Text('恢复默认'),
          ),
        ],
      ),
      body: ResponsiveFormBox(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '按学校作息设置每天的节次时间；课程按分钟保存，调整作息不会移动已有课程。会随多设备同步下发。',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _draft.length; i++) _periodTile(colors, i),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _add,
              icon: Icon(Icons.add, size: 18, color: colors.primary),
              label: const Text('添加一节'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side:
                    BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _periodTile(AppColors colors, int i) {
    final p = _draft[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(10),
          color: colors.bg,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                '第 ${i + 1} 节',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
            ),
            _timeButton(colors, formatMinutes(p.startMinutes),
                () => _pickTime(i, isStart: true)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('–', style: TextStyle(color: colors.textMuted)),
            ),
            _timeButton(
                colors, formatMinutes(p.endMinutes), () => _pickTime(i, isStart: false)),
            const Spacer(),
            IconButton(
              tooltip: '删除',
              onPressed: _draft.length <= 1
                  ? null
                  : () => setState(() => _draft.removeAt(i)),
              icon: Icon(Icons.close, size: 18, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeButton(AppColors colors, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}
