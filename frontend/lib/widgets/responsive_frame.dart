import 'package:flutter/material.dart';
import '../app/theme/app_theme.dart';

/// Wraps every screen so it renders at a fixed phone-like width on wide
/// viewports (web/desktop) instead of stretching every Row/GridView across
/// the full browser window. Below [_breakpoint] (real phones/small
/// windows) it's a no-op passthrough — this only kicks in on wide screens.
class ResponsiveFrame extends StatelessWidget {
  final Widget child;
  const ResponsiveFrame({super.key, required this.child});

  static const double _breakpoint = 700;
  static const double _maxContentWidth = 480;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _breakpoint) return child;

    return ColoredBox(
      color: AppColors.secondary,
      child: Center(
        child: Container(
          width: _maxContentWidth,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: AppColors.background),
          child: child,
        ),
      ),
    );
  }
}
