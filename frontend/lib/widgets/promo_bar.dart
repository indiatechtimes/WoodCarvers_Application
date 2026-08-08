import 'package:flutter/material.dart';
import '../app/theme/app_theme.dart';

class PromoBar extends StatelessWidget {
  final String? text;

  const PromoBar({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: List.generate(6, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 4,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    text!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryForeground,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
