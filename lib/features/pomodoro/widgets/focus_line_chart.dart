import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../pomodoro_providers.dart';

/// 最近 7 天专注分钟折线图。
class FocusLineChart extends StatelessWidget {
  final List<DayFocus> data;
  const FocusLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(
        painter: _LinePainter(
          data: data,
          lineColor: colors.primary,
          fillColor: colors.primary.withValues(alpha: 0.06),
          dotColor: colors.primary,
          labelColor: colors.textMuted,
          gridColor: colors.border,
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<DayFocus> data;
  final Color lineColor;
  final Color fillColor;
  final Color dotColor;
  final Color labelColor;
  final Color gridColor;

  _LinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
    required this.labelColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final chartH = size.height - 20; // 底部标签
    final maxV = math.max(
      25.0,
      data.fold<double>(0, (m, d) => math.max(m, d.minutes)),
    );
    final stepX = size.width / (data.length - 1);

    Offset pt(int i) => Offset(
          stepX * i,
          chartH - (data[i].minutes / maxV) * (chartH - 14),
        );

    // 横向网格线（25%/50%/75%）
    final grid = Paint()
      ..strokeWidth = 1
      ..color = gridColor.withValues(alpha: 0.6);
    for (final f in [0.25, 0.5, 0.75]) {
      final y = chartH * f;
      canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), grid);
    }

    // 折线
    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < data.length; i++) {
      path.lineTo(pt(i).dx, pt(i).dy);
    }
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;
    canvas.drawPath(path, line);

    // 数据点 + 标签
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(pt(i), 3.5, Paint()..color = dotColor);
      tp.text = TextSpan(
        text: dayLabel(data[i].day),
        style: TextStyle(fontSize: 9, color: labelColor),
      );
      tp.layout();
      double dx = pt(i).dx - tp.width / 2;
      dx = dx.clamp(2, size.width - tp.width - 2);
      tp.paint(canvas, Offset(dx, chartH + 4));
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.data != data || old.lineColor != lineColor;
}
