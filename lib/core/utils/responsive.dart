import 'package:flutter/material.dart';

/// Shared breakpoints and spacing for iPhone / iPad layouts.
class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  static bool isWideTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 900;

  static int featureGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 900
        ? 32.0
        : width >= 600
            ? 24.0
            : 16.0;
    return EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32);
  }

  static double sectionSpacing(BuildContext context) =>
      isTablet(context) ? 24.0 : 16.0;

  static const double minTapTarget = 44;
}
