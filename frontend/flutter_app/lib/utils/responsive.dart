import 'package:flutter/material.dart';

class Responsive {
  static const int mobileBreakpoint = 600;
  static const int tabletBreakpoint = 1000;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static Widget build(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    required Widget desktop,
  }) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}
