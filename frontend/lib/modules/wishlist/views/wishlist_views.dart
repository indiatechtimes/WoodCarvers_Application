import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/product_card.dart';
import '../controllers/wishlist_page_controller.dart';
import '../controllers/public_wishlist_controller.dart';

class WishlistView extends GetView<WishlistPageController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: const AppHeader(),
      body: Obx(() {
        if (!auth.isLoggedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Your wishlist', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 12),
                  const Text('Sign in to save pieces you love.', style: TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () => Get.toNamed(Routes.auth), child: const Text('Sign in')),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SAVED FOR LATER', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
                        const SizedBox(height: 6),
                        Text('Your wishlist', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  if (controller.items.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: controller.share,
                      icon: Icon(controller.copied.value ? Icons.check : Icons.share_outlined, size: 16),
                      label: Text(controller.copied.value ? 'Copied' : 'Share wishlist'),
                    ),
                ],
              ),
              if (controller.shareUrl.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('Public link: ${controller.shareUrl.value}',
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                ),
              const SizedBox(height: 20),
              if (controller.loading.value)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (controller.items.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border, style: BorderStyle.solid), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border, size: 32, color: AppColors.mutedForeground.withOpacity(0.6)),
                      const SizedBox(height: 16),
                      const Text('Nothing saved yet.', style: TextStyle(color: AppColors.mutedForeground)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => Get.toNamed(Routes.shop), child: const Text('Browse the shop')),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (_, i) => ProductCard(product: controller.items[i], width: double.infinity),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class PublicWishlistView extends GetView<PublicWishlistController> {
  const PublicWishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notFound.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Wishlist unavailable', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 12),
                  const Text('This share link is invalid or has been revoked.', style: TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () => Get.toNamed(Routes.shop), child: const Text('Explore the shop')),
                ],
              ),
            ),
          );
        }

        final name = controller.ownerName.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('SHARED WISHLIST', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
              const SizedBox(height: 6),
              Text(name.isNotEmpty ? "$name's picks" : 'Curated picks',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              Text(
                'A little collection of handmade pieces ${name.isNotEmpty ? '$name loves.' : 'someone loves.'}',
                style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
              ),
              const SizedBox(height: 24),
              if (controller.items.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border, style: BorderStyle.solid), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border, size: 28, color: AppColors.mutedForeground.withOpacity(0.6)),
                      const SizedBox(height: 14),
                      const Text('This wishlist is empty right now.', style: TextStyle(color: AppColors.mutedForeground)),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (_, i) => ProductCard(product: controller.items[i], width: double.infinity),
                ),
            ],
          ),
        );
      }),
    );
  }
}
