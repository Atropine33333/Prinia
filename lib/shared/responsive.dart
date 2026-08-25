import 'package:flutter/material.dart';

/// 宽屏（平板/桌面）下把表单类内容限宽居中，避免拉伸全屏。
class ResponsiveFormBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveFormBox({
    super.key,
    required this.child,
    this.maxWidth = 560,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
