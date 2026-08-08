import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app/controllers/auth_controller.dart';
import '../app/controllers/cart_controller.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';
import '../data/repositories/coupon_repository.dart';
import '../utils/formatters.dart';

/// Opens the cart as a right-aligned modal, matching the React CartDrawer.
Future<void> showCartDrawer() {
  return Get.bottomSheet(
    const _CartDrawerSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _CartDrawerSheet extends StatefulWidget {
  const _CartDrawerSheet();

  @override
  State<_CartDrawerSheet> createState() => _CartDrawerSheetState();
}

class _CartDrawerSheetState extends State<_CartDrawerSheet> {
  final _couponCtrl = TextEditingController();
  final _couponRepo = CouponRepository();

  Map<String, dynamic>? _applied; // {code, discount}
  bool _checking = false;

  static const _freeShippingThreshold = 1499.0;
  static const _flatShipping = 99.0;

  Future<void> _applyCoupon(double subtotal) async {
    if (_couponCtrl.text.trim().isEmpty) return;
    setState(() => _checking = true);
    try {
      final res = await _couponRepo.validateCoupon(
        _couponCtrl.text.trim(),
        subtotal,
      );
      setState(
        () => _applied = {
          'code': res['coupon']['code'],
          'discount': (res['discount'] as num).toDouble(),
        },
      );
      Get.snackbar(
        '${_applied!['code']} applied',
        'You saved ${formatInr(_applied!['discount'])}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setState(() => _applied = null);
      Get.snackbar('Invalid coupon', '', snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _checking = false);
    }
  }

  void _goCheckout() {
    final auth = Get.find<AuthController>();
    Get.back(); // close drawer
    if (!auth.isLoggedIn) {
      Get.toNamed(Routes.auth);
      return;
    }
    Get.toNamed(Routes.checkout, arguments: {'couponCode': _applied?['code']});
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Obx(() {
            final cart = cartCtrl.cart.value;
            final subtotal = cartCtrl.subtotal;
            final discount = (_applied?['discount'] as double?) ?? 0;
            final afterDiscount = (subtotal - discount).clamp(
              0,
              double.infinity,
            );
            final shipping = afterDiscount == 0
                ? 0.0
                : (afterDiscount >= _freeShippingThreshold
                      ? 0.0
                      : _flatShipping);
            final tax = (afterDiscount * 0.05).round().toDouble();
            final total = afterDiscount + shipping + tax;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YOUR BAG',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            Text(
                              '${cartCtrl.count} ${cartCtrl.count == 1 ? 'piece' : 'pieces'}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 32,
                                color: AppColors.mutedForeground,
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Your bag is empty. Explore the collection to find your next heirloom.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.mutedForeground,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  Get.toNamed(Routes.shop);
                                },
                                child: const Text('Browse shop'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: cart.items.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final item = cart.items[i];
                            final p = item.product;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 64,
                                      height: 76,
                                      child: p.thumbnailUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: p.thumbnailUrl,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(color: AppColors.muted),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatInr(p.price),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.mutedForeground,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _qtyStepper(item.quantity, p.id),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () =>
                                                  cartCtrl.remove(p.id),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color:
                                                    AppColors.mutedForeground,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatInr(item.lineTotal),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                if (cart.items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _couponCtrl,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  hintText: 'Coupon code',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _checking
                                  ? null
                                  : () => _applyCoupon(subtotal),
                              child: Text(_checking ? '…' : 'Apply'),
                            ),
                          ],
                        ),
                        if (_applied != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '✓ ${_applied!['code']} applied · saved ${formatInr(_applied!['discount'])}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        _summaryRow('Subtotal', formatInr(subtotal)),
                        if (discount > 0)
                          _summaryRow('Discount', '-${formatInr(discount)}'),
                        _summaryRow(
                          'Shipping',
                          shipping == 0 ? 'Free' : formatInr(shipping),
                        ),
                        _summaryRow('Tax (5%)', formatInr(tax)),
                        const Divider(),
                        _summaryRow('Total', formatInr(total), bold: true),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _goCheckout,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Secure checkout'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                        if (afterDiscount > 0 &&
                            afterDiscount < _freeShippingThreshold)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Add ${formatInr(_freeShippingThreshold - afterDiscount)} more to unlock complimentary shipping.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _qtyStepper(int quantity, String productId) {
    final cartCtrl = Get.find<CartController>();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            iconSize: 14,
            onPressed: () => cartCtrl.updateQuantity(productId, quantity - 1),
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 24,
            child: Text('$quantity', textAlign: TextAlign.center),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            iconSize: 14,
            onPressed: () => cartCtrl.updateQuantity(productId, quantity + 1),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: bold ? AppColors.primary : AppColors.mutedForeground,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
}
