import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/shop_controller.dart';

class ShopFiltersPanel extends StatelessWidget {
  final ShopController controller;
  const ShopFiltersPanel({super.key, required this.controller});

  Widget _optionList(
    String label,
    List<(String, String)> options,
    String Function() currentValue,
    void Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
        const SizedBox(height: 10),
        for (final (key, text) in options)
          Obx(() {
            final active = currentValue() == key;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: GestureDetector(
                onTap: () => onSelect(key),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: active ? AppColors.primary : AppColors.mutedForeground,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _optionList(
          'Category',
          ShopController.categories,
          () => controller.category.value,
          (v) => controller.category.value = v,
        ),
        _optionList(
          'Price',
          ShopController.priceRanges,
          () => controller.priceRange.value,
          (v) => controller.priceRange.value = v,
        ),
        _optionList(
          'Rating',
          const [('', 'Any rating'), ('4', '4★ & up'), ('4.5', '4.5★ & up')],
          () => controller.minRating.value,
          (v) => controller.minRating.value = v,
        ),
        Obx(() => CheckboxListTile(
              value: controller.inStockOnly.value,
              onChanged: (v) => controller.inStockOnly.value = v ?? false,
              title: const Text('In stock only', style: TextStyle(fontSize: 14, color: AppColors.foreground)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            )),
        Obx(() => controller.activeFilterCount > 0
            ? TextButton(
                onPressed: controller.clearAllFilters,
                child: const Text('Clear all filters',
                    style: TextStyle(fontSize: 12, decoration: TextDecoration.underline, color: AppColors.mutedForeground)),
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}
