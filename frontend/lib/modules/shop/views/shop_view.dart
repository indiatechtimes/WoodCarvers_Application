import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/product_card.dart';
import '../controllers/shop_controller.dart';
import 'shop_filters_panel.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({super.key});

  void _openFilters(BuildContext context) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Filters', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                  ),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ShopFiltersPanel(controller: controller),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(() => ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('See ${controller.total.value} pieces'),
                  )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('THE COLLECTION',
                    style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
                const SizedBox(height: 6),
                Text('Shop wooden treasures', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.loading.value ? 'Loading pieces…' : '${controller.total.value} pieces',
                      style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                    )),
                const SizedBox(height: 12),
                // Search
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 16, color: AppColors.mutedForeground),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onSubmitted: (v) => controller.searchQuery.value = v,
                          decoration: const InputDecoration(
                            hintText: 'Search pieces, materials, tags…',
                            border: InputBorder.none,
                            isDense: true,
                            filled: false,
                          ),
                        ),
                      ),
                      Obx(() => controller.searchQuery.value.isNotEmpty
                          ? GestureDetector(
                              onTap: () => controller.searchQuery.value = '',
                              child: const Icon(Icons.clear, size: 16, color: AppColors.mutedForeground),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Sort + view + filter row
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.sort.value,
                                isExpanded: true,
                                items: [
                                  for (final (key, label) in ShopController.sortOptions)
                                    DropdownMenuItem(value: key, child: Text(label, style: const TextStyle(fontSize: 13))),
                                ],
                                onChanged: (v) => controller.sort.value = v ?? '-createdAt',
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => IconButton(
                          onPressed: () => controller.viewMode.value = controller.viewMode.value == 'grid' ? 'list' : 'grid',
                          icon: Icon(controller.viewMode.value == 'grid' ? Icons.view_list : Icons.grid_view, size: 20),
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: const CircleBorder(),
                          ),
                        )),
                    const SizedBox(width: 8),
                    Obx(() => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () => _openFilters(context),
                              icon: const Icon(Icons.tune, size: 20),
                              style: IconButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: const CircleBorder()),
                            ),
                            if (controller.activeFilterCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text('${controller.activeFilterCount}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 9, color: Colors.white)),
                                ),
                              ),
                          ],
                        )),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.products.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Nothing matches these filters. Try widening the search.',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedForeground)),
                  ),
                );
              }
              final isGrid = controller.viewMode.value == 'grid';
              return NotificationListener<ScrollNotification>(
                onNotification: (notif) {
                  if (notif.metrics.pixels >= notif.metrics.maxScrollExtent - 200) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      isGrid
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.products.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.62,
                              ),
                              itemBuilder: (_, i) => ProductCard(product: controller.products[i], width: double.infinity),
                            )
                          : Column(
                              children: [
                                for (final p in controller.products)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _ListRow(product: p),
                                  ),
                              ],
                            ),
                      if (controller.loadingMore.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  final ProductModel product;
  const _ListRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product/${product.slug}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 90,
                child: product.thumbnailUrl.isNotEmpty
                    ? Image.network(product.thumbnailUrl, fit: BoxFit.cover)
                    : Container(color: AppColors.muted),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(formatInr(product.price),
                      style: const TextStyle(color: AppColors.foreground, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
