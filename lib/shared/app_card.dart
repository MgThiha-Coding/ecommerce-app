import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final bool topBorder;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.topBorder = false,
    this.elevation = 1,
    this.margin = const EdgeInsets.all(8),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Theme.of(context).cardColor,
      elevation: elevation,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: topBorder
            ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              )
            : BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
