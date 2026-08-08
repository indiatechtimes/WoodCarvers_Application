import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/admin_controllers.dart';

void showAdminProductEditor(BuildContext context, AdminProductsController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.editingId.value != null ? 'Edit product' : 'New product',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
                        ),
                      ),
                      IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: controller.nameCtrl, decoration: const InputDecoration(hintText: 'Name')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: controller.skuCtrl, decoration: const InputDecoration(hintText: 'SKU'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: controller.brandCtrl, decoration: const InputDecoration(hintText: 'Brand'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: controller.priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Price (₹)'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: controller.compareAtPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Compare-at price'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.category.value,
                        decoration: const InputDecoration(),
                        items: [for (final c in kAdminCategories) DropdownMenuItem(value: c, child: Text(c))],
                        onChanged: (v) => controller.category.value = v ?? controller.category.value,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: controller.stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Stock'))),
                  ]),
                  const SizedBox(height: 10),
                  TextField(controller: controller.colorCtrl, decoration: const InputDecoration(hintText: 'Color')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: controller.dimensionsCtrl, decoration: const InputDecoration(hintText: 'Dimensions'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: controller.weightCtrl, decoration: const InputDecoration(hintText: 'Weight'))),
                  ]),
                  const SizedBox(height: 10),
                  TextField(controller: controller.tagsCtrl, decoration: const InputDecoration(hintText: 'Tags (comma separated)')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.materialsCtrl, decoration: const InputDecoration(hintText: 'Materials (comma separated)')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.shortDescriptionCtrl, decoration: const InputDecoration(hintText: 'Short description')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.descriptionCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Description')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.seoTitleCtrl, decoration: const InputDecoration(hintText: 'SEO title')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.seoDescriptionCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'SEO description')),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 4,
                    children: [
                      _flagChip('Featured', controller.featured),
                      _flagChip('Bestseller', controller.bestSeller),
                      _flagChip('New arrival', controller.newArrival),
                      _flagChip('Published', controller.published),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('MEDIA (first image is the cover)', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppColors.mutedForeground)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < controller.media.length; i++)
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 100,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.muted),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: controller.media[i].type == 'video'
                                    ? const Center(child: Icon(Icons.play_circle_outline, color: AppColors.primary))
                                    : CachedNetworkImage(imageUrl: controller.media[i].url, fit: BoxFit.cover),
                              ),
                            ),
                            if (i == 0)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  color: AppColors.primary,
                                  child: const Text('COVER', style: TextStyle(fontSize: 8, color: Colors.white)),
                                ),
                              ),
                            Positioned(
                              bottom: 2,
                              left: 2,
                              right: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(onTap: () => controller.moveMedia(i, i - 1), child: const Icon(Icons.arrow_back, size: 14, color: Colors.white)),
                                  GestureDetector(onTap: () => controller.removeMedia(i), child: const Icon(Icons.delete, size: 14, color: Colors.redAccent)),
                                  GestureDetector(onTap: () => controller.moveMedia(i, i + 1), child: const Icon(Icons.arrow_forward, size: 14, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      GestureDetector(
                        onTap: controller.uploading.value ? null : controller.uploadMedia,
                        child: Container(
                          width: 90,
                          height: 100,
                          decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_outlined, size: 18, color: AppColors.mutedForeground),
                              const SizedBox(height: 4),
                              Text(controller.uploading.value ? '…' : 'Upload', style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: controller.saving.value
                            ? null
                            : () async {
                                await controller.save();
                                if (context.mounted && !controller.editorOpen.value) Get.back();
                              },
                        child: Text(controller.saving.value ? 'Saving…' : 'Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              )),
        ),
      ),
    ),
  );
}

Widget _flagChip(String label, RxBool value) {
  return Obx(() => FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: value.value,
        onSelected: (v) => value.value = v,
        selectedColor: AppColors.primary.withOpacity(0.15),
        checkmarkColor: AppColors.primary,
      ));
}
