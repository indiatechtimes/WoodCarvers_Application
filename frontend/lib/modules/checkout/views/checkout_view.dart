import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/controllers/cart_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_header.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      appBar: const AppHeader(),
      body: Obx(() {
        if (cartCtrl.cart.value.isEmpty) {
          return Center(
            child: Text('Your bag is empty.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('SECURE CHECKOUT', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
              const SizedBox(height: 6),
              Text('Almost home', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 20),
              _stepIndicator(),
              const SizedBox(height: 24),
              Obx(() {
                switch (controller.step.value) {
                  case 1:
                    return _step1Shipping();
                  case 2:
                    return _step2Payment();
                  default:
                    return _step3Review();
                }
              }),
              const SizedBox(height: 24),
              _navButtons(),
              const SizedBox(height: 28),
              _summaryCard(),
            ],
          ),
        );
      }),
    );
  }

  Widget _stepIndicator() {
    const labels = ['Shipping', 'Payment', 'Review'];
    return Obx(() => Row(
          children: List.generate(3, (i) {
            final n = i + 1;
            final active = controller.step.value >= n;
            return Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: active ? AppColors.primary : AppColors.muted,
                    child: Text('$n', style: TextStyle(color: active ? Colors.white : AppColors.mutedForeground, fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  Text(labels[i], style: TextStyle(fontSize: 11, color: active ? AppColors.primary : AppColors.mutedForeground)),
                  if (i < 2) Expanded(child: Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 8), color: AppColors.border)),
                ],
              ),
            );
          }),
        ));
  }

  Widget _step1Shipping() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.savedAddresses.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SAVED ADDRESSES', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
              const SizedBox(height: 10),
              for (final a in controller.savedAddresses)
                Obx(() {
                  final selected = controller.selectedAddressId.value == a.id;
                  return GestureDetector(
                    onTap: () => controller.selectSavedAddress(a),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                        color: selected ? AppColors.secondary.withOpacity(0.5) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(a.label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                            if (a.isDefault) ...[
                              const SizedBox(width: 8),
                              const Text('DEFAULT', style: TextStyle(fontSize: 9, letterSpacing: 1, color: AppColors.accent)),
                            ],
                          ]),
                          const SizedBox(height: 4),
                          Text('${a.name} · ${a.phone}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          Text('${a.line1}, ${a.city} ${a.pincode}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  );
                }),
              GestureDetector(
                onTap: controller.clearAddress,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('+ Ship to a new address', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }),
        const Text('SHIP TO', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
        const SizedBox(height: 10),
        TextField(controller: controller.nameCtrl, decoration: const InputDecoration(hintText: 'Full name')),
        const SizedBox(height: 10),
        TextField(controller: controller.phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone')),
        const SizedBox(height: 10),
        TextField(controller: controller.line1Ctrl, decoration: const InputDecoration(hintText: 'Street address')),
        const SizedBox(height: 10),
        TextField(controller: controller.line2Ctrl, decoration: const InputDecoration(hintText: 'Apartment, suite (optional)')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(controller: controller.cityCtrl, decoration: const InputDecoration(hintText: 'City'))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: controller.stateCtrl, decoration: const InputDecoration(hintText: 'State'))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(controller: controller.pincodeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Pincode'))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: controller.countryCtrl, decoration: const InputDecoration(hintText: 'Country'))),
        ]),
        Obx(() => controller.selectedAddressId.value == null
            ? CheckboxListTile(
                value: controller.saveAddress.value,
                onChanged: (v) => controller.saveAddress.value = v ?? true,
                title: const Text('Save this address for next time', style: TextStyle(fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _step2Payment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PAYMENT METHOD', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            color: AppColors.secondary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.credit_card, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Razorpay Secure', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    Text('UPI · Cards · Netbanking · Wallets', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ]),
              const SizedBox(height: 12),
              const Row(children: [
                Icon(Icons.lock_outline, size: 12, color: AppColors.mutedForeground),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Encrypted end-to-end. Your card details never touch our servers.',
                      style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('COUPON', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              onChanged: (v) => controller.couponCode.value = v.toUpperCase(),
              controller: TextEditingController(text: controller.couponCode.value),
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'Coupon code'),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: controller.applyCoupon, child: const Text('Apply')),
        ]),
        Obx(() => controller.couponInfo.value != null
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('✓ ${controller.couponInfo.value!['code']} applied · saved ${formatInr(controller.couponInfo.value!['discount'])}',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              )
            : const SizedBox.shrink()),
        const SizedBox(height: 20),
        const Text('ORDER NOTES', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
        const SizedBox(height: 10),
        TextField(
          controller: controller.notesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Anything you'd like us to know?"),
        ),
      ],
    );
  }

  Widget _step3Review() {
    final cartCtrl = Get.find<CartController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('REVIEW YOUR ORDER', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: [
                for (final item in cartCtrl.cart.value.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 70,
                            child: item.product.thumbnailUrl.isNotEmpty
                                ? CachedNetworkImage(imageUrl: item.product.thumbnailUrl, fit: BoxFit.cover)
                                : Container(color: AppColors.muted),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: const TextStyle(color: AppColors.primary)),
                              const SizedBox(height: 2),
                              Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                        Text(formatInr(item.lineTotal), style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
              ],
            )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ship to', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(height: 4),
              Obx(() => Text(
                    '${controller.nameCtrl.text}\n${controller.line1Ctrl.text}, ${controller.cityCtrl.text} ${controller.pincodeCtrl.text}\n${controller.phoneCtrl.text}',
                    style: const TextStyle(fontSize: 13, color: AppColors.foreground),
                  )),
              const SizedBox(height: 12),
              const Text('Payment', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(height: 2),
              const Text('Razorpay Secure', style: TextStyle(fontSize: 13, color: AppColors.foreground)),
              Obx(() => controller.couponInfo.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Coupon', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          Text(controller.couponInfo.value!['code'], style: const TextStyle(fontSize: 13, color: AppColors.primary)),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navButtons() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            controller.step.value > 1
                ? TextButton.icon(
                    onPressed: controller.placingOrder.value ? null : controller.previousStep,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                  )
                : const SizedBox.shrink(),
            ElevatedButton(
              onPressed: controller.placingOrder.value ? null : controller.nextStep,
              child: Text(
                controller.step.value == 3
                    ? (controller.placingOrder.value ? 'Placing…' : 'Pay ${formatInr(controller.total)}')
                    : 'Continue',
              ),
            ),
          ],
        ));
  }

  Widget _summaryCard() {
    final cartCtrl = Get.find<CartController>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SUMMARY', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
              const SizedBox(height: 12),
              for (final item in cartCtrl.cart.value.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('${item.product.name} × ${item.quantity}',
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                      Text(formatInr(item.lineTotal), style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              const Divider(height: 24),
              _row('Subtotal', formatInr(controller.subtotal)),
              if (controller.discount > 0) _row('Discount', '-${formatInr(controller.discount)}'),
              _row('Shipping', controller.shipping == 0 ? 'Free' : formatInr(controller.shipping)),
              _row('Tax', formatInr(controller.tax)),
              const Divider(height: 20),
              _row('Total', formatInr(controller.total), bold: true),
              const SizedBox(height: 10),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 10, color: AppColors.mutedForeground),
                    SizedBox(width: 4),
                    Text('Secured via Razorpay', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: bold ? AppColors.primary : AppColors.mutedForeground, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
            Text(value, style: TextStyle(fontSize: bold ? 15 : 13, color: AppColors.primary, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      );
}
