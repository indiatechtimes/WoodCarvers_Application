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
    final isCompact = width < 180;
    final isVeryCompact = width < 150;

    return LayoutBuilder(
      builder: (context, constraints) {
        final actualWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : width;
        final imageHeight = actualWidth < 150
            ? 122.0
            : actualWidth < 180
            ? 138.0
            : actualWidth < 220
            ? 154.0
            : 174.0;

        return GestureDetector(
          onTap: () => Get.toNamed('/product/${product.slug}'),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: imageHeight,
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
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.bestSeller)
                                _badge(
                                  'Bestseller',
                                  AppColors.accent,
                                  AppColors.primary,
                                  isNarrow: isVeryCompact,
                                ),
                              if (product.newArrival)
                                _badge(
                                  'New',
                                  AppColors.primary,
                                  AppColors.primaryForeground,
                                  isNarrow: isVeryCompact,
                                ),
                              if (product.featured &&
                                  !product.bestSeller &&
                                  !product.newArrival)
                                _badge(
                                  'Featured',
                                  AppColors.primary.withOpacity(0.9),
                                  AppColors.primaryForeground,
                                  isNarrow: isVeryCompact,
                                ),
                            ],
                          ),
                        ),
                        if (product.onSale)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _badge(
                              '-${product.discountPercent}%',
                              AppColors.primary,
                              AppColors.primaryForeground,
                              isNarrow: isVeryCompact,
                            ),
                          ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Obx(() {
                            final isWished = wishlist.has(product.id);
                            return _circleButton(
                              icon: isWished
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWished ? Colors.red : AppColors.primary,
                              onTap: _onToggleWish,
                              size: isVeryCompact
                                  ? 26
                                  : isCompact
                                  ? 30
                                  : 36,
                              iconSize: isVeryCompact
                                  ? 12
                                  : isCompact
                                  ? 14
                                  : 16,
                            );
                          }),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: _onQuickAdd,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isVeryCompact
                                    ? 6
                                    : isCompact
                                    ? 8
                                    : 14,
                                vertical: isVeryCompact
                                    ? 4
                                    : isCompact
                                    ? 6
                                    : 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: isVeryCompact
                                        ? 10
                                        : isCompact
                                        ? 12
                                        : 14,
                                    color: AppColors.primaryForeground,
                                  ),
                                  SizedBox(
                                    width: isVeryCompact
                                        ? 3
                                        : isCompact
                                        ? 4
                                        : 6,
                                  ),
                                  Text(
                                    'Quick add',
                                    style: TextStyle(
                                      color: AppColors.primaryForeground,
                                      fontSize: isVeryCompact
                                          ? 8
                                          : isCompact
                                          ? 9
                                          : 11,
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
                SizedBox(
                  height: isVeryCompact
                      ? 6
                      : isCompact
                      ? 8
                      : 10,
                ),
                Text(
                  formatCategory(product.category),
                  style: TextStyle(
                    fontSize: isVeryCompact
                        ? 7.5
                        : isCompact
                        ? 8.5
                        : 10,
                    letterSpacing: 1.2,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isVeryCompact
                        ? 11.5
                        : isCompact
                        ? 12.5
                        : 15,
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: isVeryCompact
                      ? 3
                      : isCompact
                      ? 4
                      : 6,
                  runSpacing: 3,
                  children: [
                    Text(
                      formatInr(product.price),
                      style: TextStyle(
                        fontSize: isVeryCompact
                            ? 10
                            : isCompact
                            ? 11.5
                            : null,
                        color: AppColors.foreground,
                      ),
                    ),
                    if (product.onSale)
                      Text(
                        formatInr(product.compareAtPrice),
                        style: TextStyle(
                          fontSize: isVeryCompact
                              ? 9
                              : isCompact
                              ? 10.5
                              : 12,
                          color: AppColors.mutedForeground,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (product.reviewCount > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StarRating(
                            value: product.rating,
                            size: isVeryCompact
                                ? 9
                                : isCompact
                                ? 10
                                : 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${product.reviewCount})',
                            style: TextStyle(
                              fontSize: isVeryCompact
                                  ? 8
                                  : isCompact
                                  ? 9
                                  : 10,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _badge(String text, Color bg, Color fg, {required bool isNarrow}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 7 : 10,
          vertical: isNarrow ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: isNarrow ? 7.5 : 9,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double size,
    required double iconSize,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.85),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: color),
    ),
  );
}
