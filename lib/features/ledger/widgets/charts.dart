import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 每日支出柱状图：固定 0~300 坐标系，超顶满格并标数字，点击显示金额。
///
/// [selectedDay]/[onDayChanged] 受控联动外部（如饼图）。
class ExpenseBarChart extends StatelessWidget {
  final Map<int, double> data;
  final int? selectedDay;
  final ValueChanged<int?> onDayChanged;

  const ExpenseBarChart({
    super.key,
    required this.data,
    required this.onDayChanged,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: GestureDetector(
        onTapUp: (d) => _handleTap(context, d.localPosition),
        child: CustomPaint(
          painter: _BarPainter(
            data: data,
            barColor: colors.primary,
            faintColor: colors.border,
            labelColor: colors.textMuted,
            axisColor: colors.border,
            selectedDay: selectedDay,
            selectedColor: colors.primaryHover,
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, Offset local) {
    final days = data.isEmpty ? 0 : data.keys.reduce(math.max);
    if (days == 0) return;
    const axisW = 30.0;
    final chartW = context.size!.width - axisW;
    final slotW = chartW / days;
    final day = ((local.dx - axisW) / slotW).floor() + 1;
    if (day < 1 || day > days) {
      onDayChanged(null);
      return;
    }
    onDayChanged(selectedDay == day ? null : day);
  }
}

const _axisMax = 300.0;
const _axisLabels = [0, 100, 200, 300];

class _BarPainter extends CustomPainter {
  final Map<int, double> data;
  final Color barColor;
  final Color faintColor;
  final Color labelColor;
  final Color axisColor;
  final int? selectedDay;
  final Color selectedColor;

  _BarPainter({
    required this.data,
    required this.barColor,
    required this.faintColor,
    required this.labelColor,
    required this.axisColor,
    required this.selectedDay,
    required this.selectedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    const axisW = 30.0;
    const topPad = 18.0; // 顶部留标签空间
    final chartH = size.height - 18 - topPad;
    final chartW = size.width - axisW;
    final days = data.keys.reduce(math.max);
    final slotW = chartW / days;
    final barW = math.min(slotW * 0.62, 16.0);

    // ── 坐标系：横线 + 左侧刻度 ──
    final grid = Paint()
      ..strokeWidth = 0.8
      ..color = axisColor;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final v in _axisLabels) {
      final y = topPad + chartH - (v / _axisMax) * chartH;
      canvas.drawLine(Offset(axisW, y), Offset(size.width, y), grid);
      tp.text = TextSpan(
        text: '$v',
        style: TextStyle(fontSize: 9, color: labelColor),
      );
      tp.layout();
      tp.paint(canvas, Offset(axisW - tp.width - 3, y - tp.height / 2));
    }

    // ── 柱子 ──
    final paint = Paint()..style = PaintingStyle.fill;
    for (var d = 1; d <= days; d++) {
      final v = data[d] ?? 0;
      final capped = v > _axisMax;
      final h = v <= 0
          ? 2.0
          : math.min(v / _axisMax, 1.0) * (chartH - 4);
      final x = axisW + slotW * (d - 1) + (slotW - barW) / 2;
      final y = topPad + chartH - h;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barW, h),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      paint.color = v <= 0
          ? faintColor.withValues(alpha: 0.5)
          : (selectedDay == d ? selectedColor : barColor);
      canvas.drawRRect(rect, paint);

      final isSelected = selectedDay == d;
      // 超顶满格：恒显数字；选中：显示金额
      if ((capped || isSelected) && v > 0) {
        final numText = v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
        final text = capped ? numText : '¥$numText';
        tp.text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        );
        tp.layout();
        var tx = x + barW / 2 - tp.width / 2;
        tx = tx.clamp(axisW, size.width - tp.width - 1);
        tp.paint(canvas, Offset(tx, y - tp.height - 3));
      }
    }

    // ── 日期标签 ──
    for (final d in [1, 5, 10, 15, 20, 25, days]) {
      tp.text = TextSpan(
        text: d.toString(),
        style: TextStyle(fontSize: 9, color: labelColor),
      );
      tp.layout();
      tp.paint(canvas,
          Offset(axisW + slotW * (d - 0.5) - tp.width / 2, topPad + chartH + 4));
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.data != data ||
      old.selectedDay != selectedDay ||
      old.barColor != barColor;
}

/// 类别占比饼图（环形）。
class CategoryPieChart extends StatelessWidget {
  final List<(String, double)> totals;
  final String? highlighted;
  final ValueChanged<String>? onTapSlice;

  const CategoryPieChart({
    super.key,
    required this.totals,
    this.highlighted,
    this.onTapSlice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final palette = piePalette(colors);
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _PiePainter(
          totals: totals,
          palette: palette,
          trackColor: colors.hoverBg,
          borderColor: colors.surface,
          highlighted: highlighted,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _totalText(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              Text(
                '总支出',
                style: TextStyle(fontSize: 11, color: colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _totalText() {
    final t = totals.fold<double>(0, (s, e) => s + e.$2);
    return '¥${t.toStringAsFixed(t % 1 == 0 ? 0 : 2)}';
  }
}

class _PiePainter extends CustomPainter {
  final List<(String, double)> totals;
  final List<Color> palette;
  final Color trackColor;
  final Color borderColor;
  final String? highlighted;

  _PiePainter({
    required this.totals,
    required this.palette,
    required this.trackColor,
    required this.borderColor,
    this.highlighted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    const stroke = 22.0;

    canvas.drawCircle(
      center,
      radius - stroke / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = trackColor,
    );

    final total = totals.fold<double>(0, (s, e) => s + e.$2);
    if (total <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;
    for (var i = 0; i < totals.length; i++) {
      final sweep = (totals[i].$2 / total) * 2 * math.pi;
      paint.color = palette[i % palette.length];
      if (highlighted != null && totals[i].$1 != highlighted) {
        paint.color = paint.color.withValues(alpha: 0.25);
      }
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.totals != totals ||
      old.highlighted != highlighted ||
      old.palette != palette;
}

/// 类别在饼图中的固定色序（低饱和，取自主题派生）。
List<Color> piePalette(AppColors c) => [
      c.primary,
      c.highlight,
      c.primaryHover,
      c.activeBg,
      c.borderStrong,
      c.error.withValues(alpha: 0.75),
      c.textMuted.withValues(alpha: 0.6),
    ];
