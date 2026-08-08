import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app/controllers/auth_controller.dart';
import '../app/controllers/cart_controller.dart';
import '../app/controllers/wishlist_controller.dart';

import '../app/theme/app_theme.dart';
import '../data/models/product_model.dart';
import '../utils/formatters.dart';
import 'star_rating.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final double width;

  const ProductCard({super.key, required this.product, this.width = 180});

  Future<void> _onToggleWish() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.snackbar(
        'Sign in required',
        'Sign in to save items',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      final added = await Get.find<WishlistController>().toggle(product.id);
      Get.snackbar(
        added ? 'Saved to wishlist' : 'Removed from wishlist',
        '',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not update wishlist',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _onQuickAdd() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.snackbar(
        'Sign in required',
        'Sign in to add to cart',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      await Get.find<CartController>().add(product.id, quantity: 1);
      Get.snackbar('Added to cart', '', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not add to cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = Get.find<WishlistController>();

    return GestureDetector(
      onTap: () => Get.toNamed('/product/${product.slug}'),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.muted,
                      child: product.thumbnailUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.thumbnailUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: AppColors.muted),
                              errorWidget: (context, url, error) =>
                                  Container(color: AppColors.secondary),
                            )
                          : Container(color: AppColors.secondary),
                    ),
                    // Top-left badges
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.bestSeller)
                            _badge(
                              'Bestseller',
                              AppColors.accent,
                              AppColors.primary,
                            ),
                          if (product.newArrival)
                            _badge(
                              'New',
                              AppColors.primary,
                              AppColors.primaryForeground,
                            ),
                          if (product.featured &&
                              !product.bestSeller &&
                              !product.newArrival)
                            _badge(
                              'Featured',
                              AppColors.primary.withOpacity(0.9),
                              AppColors.primaryForeground,
                            ),
                        ],
                      ),
                    ),
                    if (product.onSale)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _badge(
                          '-${product.discountPercent}%',
                          AppColors.primary,
                          AppColors.primaryForeground,
                        ),
                      ),
                    // Wishlist heart
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Obx(() {
                        final isWished = wishlist.has(product.id);
                        return _circleButton(
                          icon: isWished
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isWished ? Colors.red : AppColors.primary,
                          onTap: _onToggleWish,
                        );
                      }),
                    ),
                    // Quick add
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: GestureDetector(
                        onTap: _onQuickAdd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 14,
                                color: AppColors.primaryForeground,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Quick add',
                                style: TextStyle(
                                  color: AppColors.primaryForeground,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatCategory(product.category),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  formatInr(product.price),
                  style: const TextStyle(color: AppColors.foreground),
                ),
                if (product.onSale) ...[
                  const SizedBox(width: 6),
                  Text(
                    formatInr(product.compareAtPrice),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                const Spacer(),
                if (product.reviewCount > 0) ...[
                  StarRating(value: product.rating, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    '(${product.reviewCount})',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: fg,
        fontSize: 9,
        letterSpacing: 1,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.85),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    ),
  );
}
