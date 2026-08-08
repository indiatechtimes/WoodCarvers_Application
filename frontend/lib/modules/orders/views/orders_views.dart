import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_header.dart';
import '../controllers/orders_controllers.dart';

(Color, Color) _statusColors(String status) {
  switch (status) {
    case 'paid':
      return (AppColors.primary.withOpacity(0.12), AppColors.primary);
    case 'processing':
      return (AppColors.accent.withOpacity(0.25), AppColors.primary);
    case 'shipped':
      return (AppColors.accent.withOpacity(0.35), AppColors.primary);
    case 'delivered':
      return (AppColors.primary, AppColors.primaryForeground);
    case 'cancelled':
    case 'failed':
      return (Colors.red.withOpacity(0.12), Colors.red);
    default:
      return (AppColors.secondary, AppColors.primary);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: TextStyle(fontSize: 11, color: fg)),
    );
  }
}

class OrdersListView extends GetView<OrdersListController> {
  const OrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('ORDER HISTORY', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
              const SizedBox(height: 6),
              Text('Your orders', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 24),
              if (controller.orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("You haven't placed any orders yet.", style: TextStyle(color: AppColors.mutedForeground)),
                )
              else
                for (final o in controller.orders)
                  GestureDetector(
                    onTap: () => Get.toNamed('${Routes.orders}/${o.id}'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${o.id.length >= 8 ? o.id.substring(o.id.length - 8) : o.id}',
                              style: const TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            '${o.createdAt != null ? DateFormat('d MMM y').format(o.createdAt!) : ''} · ${o.items.length} items',
                            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatusBadge(status: o.status),
                              Text(formatInr(o.total), style: const TextStyle(fontSize: 16, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final order = controller.order.value;
        if (order == null) {
          return const Center(child: Text('Order not found', style: TextStyle(color: AppColors.mutedForeground)));
        }
        final paid = order.paymentStatus == 'paid';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => Get.offNamed(Routes.orders),
                child: const Text('← All orders', style: TextStyle(fontSize: 13, color: AppColors.primary, decoration: TextDecoration.underline)),
              ),
              if (controller.justPaid && paid) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text('Thank you for shopping with WOOD CARVERS',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Text(
                        'Order #${order.id.length >= 8 ? order.id.substring(order.id.length - 8) : order.id} is confirmed. A receipt is on its way to your inbox.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('Order #${order.id.length >= 8 ? order.id.substring(order.id.length - 8) : order.id}',
                  style: const TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
              const SizedBox(height: 6),
              Text('Order details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatusBadge(status: order.status),
                  const SizedBox(width: 10),
                  Text('Payment: ${order.paymentStatus}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                ],
              ),
              const SizedBox(height: 24),
              for (final it in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 72,
                          height: 84,
                          child: it.image.isNotEmpty ? Image.network(it.image, fit: BoxFit.cover) : Container(color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.name, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Qty: ${it.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      Text(formatInr(it.price * it.quantity), style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SUMMARY', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
                    const SizedBox(height: 12),
                    _row('Subtotal', formatInr(order.subtotal)),
                    if (order.discount > 0) _row('Discount (${order.couponCode})', '-${formatInr(order.discount)}'),
                    _row('Shipping', order.shipping == 0 ? 'Free' : formatInr(order.shipping)),
                    _row('Tax', formatInr(order.tax)),
                    const Divider(height: 20),
                    _row('Total', formatInr(order.total), bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SHIP TO', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
                    const SizedBox(height: 10),
                    Text(order.shippingAddress.name, style: const TextStyle(fontSize: 13)),
                    Text(order.shippingAddress.line1, style: const TextStyle(fontSize: 13)),
                    if (order.shippingAddress.line2.isNotEmpty) Text(order.shippingAddress.line2, style: const TextStyle(fontSize: 13)),
                    Text('${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.pincode}', style: const TextStyle(fontSize: 13)),
                    Text(order.shippingAddress.country, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(order.shippingAddress.phone, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
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
