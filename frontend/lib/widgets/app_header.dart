import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/auth_controller.dart';
import '../app/controllers/cart_controller.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';
import 'cart_drawer.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  void _submitSearch(BuildContext context, String query) {
    if (query.trim().isEmpty) return;
    Get.toNamed('${Routes.shop}?q=${Uri.encodeComponent(query.trim())}');
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final cart = Get.find<CartController>();

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: GestureDetector(
        onTap: () => Get.offAllNamed(Routes.home),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'WC',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'WOOD CARVERS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => showSearch(
            context: context,
            delegate: _SearchDelegate(
              onSubmit: (q) => _submitSearch(context, q),
            ),
          ),
        ),
        Obx(() {
          final user = auth.user.value;
          if (user == null) {
            return IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => Get.toNamed(Routes.auth),
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => Get.toNamed(Routes.wishlist),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Get.toNamed(Routes.account),
              ),
            ],
          );
        }),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Obx(
            () => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () => showCartDrawer(),
                ),
                if (cart.count > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cart.count}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final ValueChanged<String> onSubmit;
  _SearchDelegate({required this.onSubmit});

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) {
    onSubmit(query);
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();

  @override
  String get searchFieldLabel => 'Search wooden treasures';
}
