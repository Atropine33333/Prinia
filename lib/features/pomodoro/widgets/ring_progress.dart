import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 番茄钟环形进度：track 为 border 色，进度为 primary，
/// 运行时外圈呼吸光晕。
class RingProgress extends StatelessWidget {
  final double fraction; // 已流逝 0~1
  final bool breathing;
  final Widget child;

  const RingProgress({
    super.key,
    required this.fraction,
    required this.breathing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, anim, _) {
        return CustomPaint(
          painter: _RingPainter(
            fraction: anim,
            trackColor: colors.border,
            progressColor: colors.primary,
            glowColor: colors.primary.withValues(alpha: 0.25),
            breathing: breathing,
          ),
          child: Center(child: child),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;
  final bool breathing;

  _RingPainter({
    required this.fraction,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
    required this.breathing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;
    const stroke = 12.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 呼吸光晕
    if (breathing) {
      canvas.drawCircle(
        center,
        radius + 8,
        Paint()
          ..color = glowColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    // 底环
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = trackColor,
    );

    // 进度弧（从 12 点顺时针）
    if (fraction > 0) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = progressColor;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * fraction, false, p);
      // 端点圆头
      final angle = -math.pi / 2 + 2 * math.pi * fraction;
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        stroke / 2,
        p..strokeCap = StrokeCap.butt,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.breathing != breathing ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
