import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// 各模块就绪前的占位页。
class PlaceholderPage extends StatelessWidget {
  final String label;
  const PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 48, color: colors.textMuted),
          const SizedBox(height: 12),
          Text('$label · 建设中',
              style: TextStyle(color: colors.textMuted)),
        ],
      ),
    );
  }
}
