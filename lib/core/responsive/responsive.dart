import 'package:flutter/material.dart';

/// Responsive breakpoint helpers for desktop layouts.
class Responsive {
  Responsive._();

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 1024;

  static bool isMedium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 1024 && w < 1440;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1440;

  static bool isUltraWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1920;

  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1920) return 1600;
    if (w >= 1440) return 1200;
    return w - 48;
  }

  static int gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1440) return 3;
    if (w >= 1024) return 2;
    return 1;
  }
}

/// Adaptive layout builder widget.
class AdaptiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) compact;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context)? expanded;

  const AdaptiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1440 && expanded != null) {
      return expanded!(context);
    }
    if (width >= 1024 && medium != null) {
      return medium!(context);
    }
    return compact(context);
  }
}
