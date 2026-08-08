import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_header.dart';
import '../controllers/admin_controllers.dart';
import 'admin_product_editor.dart';
import 'admin_coupon_editor.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  static const _tabs = [
    ('dashboard', Icons.dashboard_outlined, 'Dashboard'),
    ('products', Icons.inventory_2_outlined, 'Products'),
    ('orders', Icons.shopping_bag_outlined, 'Orders'),
    ('coupons', Icons.local_offer_outlined, 'Coupons'),
    ('banners', Icons.image_outlined, 'Banners'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: const AppHeader(),
      body: Obx(() {
        final user = auth.user.value;
        if (user == null) {
          return const Center(
            child: Text(
              'Please sign in.',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          );
        }
        if (!auth.isAdmin) {
          return const Center(
            child: Text(
              'Not authorised.',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'WC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ADMIN DASHBOARD',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Studio control',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: Obx(
                      () => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tabs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final (id, icon, label) = _tabs[i];
                          final active = controller.activeTab.value == id;
                          return GestureDetector(
                            onTap: () => controller.setTab(id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.secondary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 14,
                                    color: active
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: active
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                switch (controller.activeTab.value) {
                  case 'products':
                    return const _ProductsTab();
                  case 'orders':
                    return const _OrdersTab();
                  case 'coupons':
                    return const _CouponsTab();
                  case 'banners':
                    return const _BannersTab();
                  default:
                    return const _DashboardTab();
                }
              }),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------- Dashboard ----------------

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdminDashboardController());
    return Obx(() {
      if (c.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final stats = c.stats.value;
      if (stats == null) {
        return const Center(
          child: Text(
            'Could not load analytics',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _statCard(
                  Icons.currency_rupee,
                  'Revenue (paid)',
                  formatInr(stats.revenue),
                ),
                _statCard(
                  Icons.shopping_bag_outlined,
                  'Orders',
                  '${stats.ordersCount}',
                ),
                _statCard(
                  Icons.inventory_2_outlined,
                  'Products',
                  '${stats.productsCount}',
                ),
                _statCard(
                  Icons.people_outline,
                  'Customers',
                  '${stats.customersCount}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Last 30 days revenue',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _SparklinePainter(stats.salesSeries),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECENT ORDERS',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (stats.recentOrders.isEmpty)
                    const Text(
                      'No orders yet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                      ),
                    )
                  else
                    for (final o in stats.recentOrders)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${(o['_id'] ?? '').toString().length >= 8 ? (o['_id']).toString().substring((o['_id']).toString().length - 8) : o['_id']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Text(
                              formatInr((o['total'] ?? 0)),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOP SELLERS',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (stats.topProducts.isEmpty)
                    const Text(
                      'No sales yet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                      ),
                    )
                  else
                    for (final t in stats.topProducts)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${t['name']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '${t['sold']} sold · ${formatInr(t['revenue'] ?? 0)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
            if (stats.lowStock.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          size: 14,
                          color: Colors.red,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'LOW STOCK',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final p in stats.lowStock)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${p['name']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '${p['stock']} left',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _statCard(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1,
                color: AppColors.mutedForeground,
              ),
            ),
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _SparklinePainter extends CustomPainter {
  final List<dynamic> points;
  _SparklinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxRevenue = points
        .map((p) => p.revenue as double)
        .fold<double>(1, (a, b) => b > a ? b : a);
    final step = size.width / (points.length - 1 <= 0 ? 1 : points.length - 1);

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.75
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.35),
          AppColors.primary.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * step;
      final y =
          size.height -
          ((points[i].revenue as double) / maxRevenue) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points;
}

// ---------------- Products ----------------

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdminProductsController());
    return Obx(() {
      if (c.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  c.openNew();
                  showAdminProductEditor(context, c);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New product'),
              ),
            ),
            const SizedBox(height: 14),
            for (final p in c.products)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 56,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${formatCategory(p.category)} · ${formatInr(p.price)} · stock ${p.stock}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        c.openEdit(p);
                        showAdminProductEditor(context, c);
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _confirmDelete(context, () => c.delete(p.id)),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete this?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

// ---------------- Orders ----------------

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdminOrdersController());
    return Obx(() {
      if (c.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final o in c.orders)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '#${o.id.length >= 8 ? o.id.substring(o.id.length - 8) : o.id}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          formatInr(o.total),
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      o.shippingAddress.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: kOrderStatuses.contains(o.status)
                          ? o.status
                          : kOrderStatuses.first,
                      decoration: const InputDecoration(isDense: true),
                      items: [
                        for (final s in kOrderStatuses)
                          DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) c.setStatus(o.id, v);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ---------------- Coupons ----------------

class _CouponsTab extends StatelessWidget {
  const _CouponsTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdminCouponsController());
    return Obx(() {
      if (c.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  c.openNew();
                  showAdminCouponEditor(context, c);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New coupon'),
              ),
            ),
            const SizedBox(height: 14),
            for (final coupon in c.coupons)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            coupon['code'] ?? '',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 2,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: coupon['active'] == true
                                ? AppColors.primary.withOpacity(0.12)
                                : AppColors.secondary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            coupon['active'] == true ? 'Active' : 'Off',
                            style: TextStyle(
                              fontSize: 9,
                              color: coupon['active'] == true
                                  ? AppColors.primary
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((coupon['description'] ?? '')
                        .toString()
                        .isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        coupon['description'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      coupon['type'] == 'percent'
                          ? '${coupon['value']}% off'
                          : '${formatInr(coupon['value'] ?? 0)} off',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'min ${formatInr(coupon['minSubtotal'] ?? 0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      'Used ${coupon['usedCount'] ?? 0}${(coupon['usageLimit'] ?? 0) > 0 ? ' / ${coupon['usageLimit']}' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            c.openEdit(coupon);
                            showAdminCouponEditor(context, c);
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _confirmDelete(
                            context,
                            () => c.delete(coupon['_id']),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ---------------- Banners ----------------

class _BannersTab extends StatelessWidget {
  const _BannersTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdminBannersController());
    return Obx(() {
      if (c.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HERO BANNER',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 7,
                      child:
                          c.settings['hero_image'] != null &&
                              c.settings['hero_image'].toString().isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: c.settings['hero_image'],
                              fit: BoxFit.cover,
                            )
                          : Container(color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: c.uploadHero,
                    icon: const Icon(Icons.upload_outlined, size: 16),
                    label: const Text('Upload new hero image'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: c.headlineCtrl,
                    decoration: const InputDecoration(hintText: 'Headline'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: c.subheadingCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Subheading'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: c.saving.value ? null : c.saveHeadline,
                        child: const Text('Save headline'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: c.saving.value ? null : c.saveSubheading,
                        child: const Text('Save subheading'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROMO BAR',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: c.promoTextCtrl,
                    decoration: const InputDecoration(hintText: 'Promo text'),
                  ),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    value: c.promoActive.value,
                    onChanged: (v) => c.promoActive.value = v ?? false,
                    title: const Text('Active', style: TextStyle(fontSize: 13)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: c.saving.value ? null : c.savePromo,
                    child: const Text('Save promo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
