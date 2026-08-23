import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'category_icons.dart';

/// 每日支出柱状图。
///
/// [data]: 天(1~31) → 金额；空白天画基线小柱。
class ExpenseBarChart extends StatelessWidget {
  final Map<int, double> data;
  const ExpenseBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(
          data: data,
          barColor: colors.primary,
          faintColor: colors.border,
          labelColor: colors.textMuted,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final Map<int, double> data;
  final Color barColor;
  final Color faintColor;
  final Color labelColor;

  _BarPainter({
    required this.data,
    required this.barColor,
    required this.faintColor,
    required this.labelColor,
  });

  int get _days {
    if (data.isEmpty) return 30;
    return data.keys.reduce(math.max);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final days = _days;
    final maxV =
        data.values.fold<double>(0.001, (m, v) => math.max(m, v));
    final chartH = size.height - 18; // 底部留标签
    final slotW = size.width / days;
    final barW = math.min(slotW * 0.62, 14.0);

    final paint = Paint()..style = PaintingStyle.fill;
    for (var d = 1; d <= days; d++) {
      final v = data[d] ?? 0;
      final h = v <= 0 ? 2.0 : (v / maxV) * (chartH - 8);
      final x = slotW * (d - 1) + (slotW - barW) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, chartH - h, barW, h),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      paint.color = v <= 0 ? faintColor.withValues(alpha: 0.5) : barColor;
      canvas.drawRRect(rect, paint);
    }

    // 日期标签：1、5、10、15、20、25、月末
    final tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (final d in [
      1, 5, 10, 15, 20, 25, days //
    ]) {
      tp.text = TextSpan(
        text: '$d',
        style: TextStyle(fontSize: 9, color: labelColor),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(slotW * (d - 0.5) - tp.width / 2, chartH + 4),
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.data != data || old.barColor != barColor;
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

    // 底环
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
      ..strokeWidth = highlighted == null ? stroke : stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2; // 从 12 点开始
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
