import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/star_rating.dart';
import '../../../app/controllers/wishlist_controller.dart';
import '../controllers/product_detail_controller.dart';
import '../controllers/reviews_controller.dart';
import 'review_section.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = controller.product.value;
        if (p == null) {
          return const Center(
            child: Text(
              'Product not found',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          );
        }

        // One ReviewsController instance per product, kept alive via tag.
        final reviewsCtrl = Get.put(
          ReviewsController(
            productId: p.id,
            initialRating: p.rating,
            initialCount: p.reviewCount,
          ),
          tag: p.id,
        );

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _breadcrumb(p),
                  _gallery(p),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _info(context, p),
                  ),
                  ReviewSection(controller: reviewsCtrl),
                  if (controller.related.isNotEmpty)
                    _relatedSection(context, p),
                  if (controller.recentlyViewed.isNotEmpty)
                    _recentlyViewedSection(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _stickyAddToCart(p),
            ),
          ],
        );
      }),
    );
  }

  Widget _breadcrumb(ProductModel p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Wrap(
        children: [
          GestureDetector(
            onTap: () => Get.offAllNamed(Routes.home),
            child: const Text(
              'Home',
              style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
            ),
          ),
          const Text(
            '  ·  ',
            style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.shop),
            child: const Text(
              'Shop',
              style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
            ),
          ),
          const Text(
            '  ·  ',
            style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('${Routes.shop}?category=${p.category}'),
            child: Text(
              formatCategory(p.category),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gallery(ProductModel p) {
    final media = p.media.isNotEmpty ? p.media : [ProductMedia(url: '')];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Obx(() {
            final active =
                media[controller.activeMediaIndex.value.clamp(
                  0,
                  media.length - 1,
                )];
            return ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: active.url.isEmpty
                    ? Container(color: AppColors.muted)
                    : CachedNetworkImage(
                        imageUrl: active.url,
                        fit: BoxFit.cover,
                      ),
              ),
            );
          }),
          if (media.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: media.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => controller.activeMediaIndex.value = i,
                    child: Obx(
                      () => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: controller.activeMediaIndex.value == i
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: media[i].type == 'video'
                              ? Container(
                                  color: AppColors.primary.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: AppColors.primary,
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: media[i].url,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _info(BuildContext context, ProductModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${formatCategory(p.category)} · WOOD CARVERS',
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          p.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            height: 1.05,
          ),
        ),
        if (p.reviewCount > 0) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              StarRating(value: p.rating, size: 15),
              const SizedBox(width: 6),
              Text(
                p.rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                ' · ${p.reviewCount} review${p.reviewCount != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatInr(p.price),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
            ),
            if (p.onSale) ...[
              const SizedBox(width: 10),
              Text(
                formatInr(p.compareAtPrice),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.mutedForeground,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Save ${formatInr(p.compareAtPrice - p.price)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Inclusive of all taxes · Free shipping over ₹1,499',
          style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 18),
        Text(
          p.description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.foreground,
            height: 1.6,
          ),
        ),
        if (p.materials.isNotEmpty ||
            p.dimensions.isNotEmpty ||
            p.weight.isNotEmpty) ...[
          const SizedBox(height: 18),
          if (p.materials.isNotEmpty)
            _specRow('Materials', p.materials.join(' · ')),
          if (p.dimensions.isNotEmpty) _specRow('Dimensions', p.dimensions),
          if (p.weight.isNotEmpty) _specRow('Weight', p.weight),
          _specRow(
            'Availability',
            p.stock > 0 ? 'In stock — ${p.stock} pieces' : 'Sold out',
            color: p.stock > 0 ? AppColors.primary : Colors.red,
          ),
        ],
        const SizedBox(height: 22),
        Row(
          children: [
            _qtyStepper(),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: p.stock > 0 ? controller.addToCart : null,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Add to bag'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(() {
              final isWished = Get.find<WishlistController>().has(p.id);
              return GestureDetector(
                onTap: controller.toggleWishlist,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isWished ? Colors.red : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    isWished ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isWished ? Colors.red : AppColors.primary,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 4.5,
          children: const [
            _PerkRow(
              icon: Icons.local_shipping_outlined,
              label: 'Free shipping over ₹1,499',
            ),
            _PerkRow(
              icon: Icons.verified_user_outlined,
              label: 'Secure Razorpay checkout',
            ),
            _PerkRow(icon: Icons.replay_outlined, label: '7-day easy returns'),
            _PerkRow(
              icon: Icons.emoji_events_outlined,
              label: 'Handmade guarantee',
            ),
          ],
        ),
      ],
    );
  }

  Widget _specRow(
    String label,
    String value, {
    Color color = AppColors.foreground,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.5,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, color: color)),
      ],
    ),
  );

  Widget _qtyStepper() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 14),
            onPressed: controller.decrementQty,
          ),
          Obx(
            () => SizedBox(
              width: 20,
              child: Text(
                '${controller.quantity.value}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 14),
            onPressed: controller.incrementQty,
          ),
        ],
      ),
    );
  }

  Widget _relatedSection(BuildContext context, ProductModel p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOU MIGHT ALSO LIKE',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'More from ${formatCategory(p.category)}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.related.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (_, i) =>
                  ProductCard(product: controller.related[i], width: 170),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentlyViewedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENTLY VIEWED',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick up where you left off',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.recentlyViewed.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final r = controller.recentlyViewed[i];
                return GestureDetector(
                  onTap: () => Get.toNamed('/product/${r.slug}'),
                  child: SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 130,
                            height: 130,
                            child: r.image.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: r.image,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: AppColors.muted),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          formatInr(r.price),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stickyAddToCart(ProductModel p) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  Text(
                    formatInr(p.price * controller.quantity.value),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: p.stock > 0 ? controller.addToCart : null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Add to bag'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PerkRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.foreground),
          ),
        ),
      ],
    );
  }
}
