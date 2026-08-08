import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/admin_controllers.dart';

void showAdminCouponEditor(BuildContext context, AdminCouponsController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.editingId.value != null ? 'Edit coupon' : 'New coupon',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'CODE'),
                ),
                const SizedBox(height: 10),
                TextField(controller: controller.descriptionCtrl, decoration: const InputDecoration(hintText: 'Description')),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: controller.type.value,
                      items: const [
                        DropdownMenuItem(value: 'percent', child: Text('Percent')),
                        DropdownMenuItem(value: 'flat', child: Text('Flat ₹')),
                      ],
                      onChanged: (v) => controller.type.value = v ?? 'percent',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: controller.valueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Value'))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: controller.minSubtotalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Min subtotal'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: controller.maxDiscountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Max discount cap (0 = none)'))),
                ]),
                CheckboxListTile(
                  value: controller.active.value,
                  onChanged: (v) => controller.active.value = v ?? true,
                  title: const Text('Active', style: TextStyle(fontSize: 13)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 10),
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
  );
}
