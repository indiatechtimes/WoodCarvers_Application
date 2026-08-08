import 'package:flutter/material.dart';
import '../app/theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double value;
  final double size;

  const StarRating({super.key, this.value = 0, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final rounded = value.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = (i + 1) <= rounded;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: filled ? AppColors.accent : AppColors.mutedForeground.withOpacity(0.4),
        );
      }),
    );
  }
}

/// Interactive star picker, mirrors Stars.jsx StarPicker (used in review form)
class StarPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const StarPicker({super.key, required this.value, required this.onChanged, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        final filled = starIndex <= value;
        return IconButton(
          onPressed: () => onChanged(starIndex),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: filled ? AppColors.accent : AppColors.mutedForeground.withOpacity(0.5),
          ),
        );
      }),
    );
  }
}
