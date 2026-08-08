import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/auth_controller.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Obx(() {
          final user = auth.user.value;
          final items = <(String, VoidCallback)>[
            ('Home', () => Get.offAllNamed(Routes.home)),
            ('Shop', () => Get.toNamed(Routes.shop)),
            ('Personalized', () => Get.toNamed('${Routes.shop}?category=personalized')),
            ('Wall Décor', () => Get.toNamed('${Routes.shop}?category=wall-decor')),
            ('Home Décor', () => Get.toNamed('${Routes.shop}?category=home-decor')),
            ('Story', () => Get.toNamed(Routes.about)),
            if (auth.isAdmin) ('Admin', () => Get.toNamed(Routes.admin)),
            if (user != null) ('Account', () => Get.toNamed(Routes.account)),
            if (user != null) ('Orders', () => Get.toNamed(Routes.orders)),
            if (user != null) ('Wishlist', () => Get.toNamed(Routes.wishlist)),
            if (user == null) ('Sign in', () => Get.toNamed(Routes.auth)),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text('WOOD CARVERS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final item in items)
                      ListTile(
                        title: Text(item.$1,
                            style: const TextStyle(fontSize: 20, color: AppColors.primary)),
                        onTap: () {
                          Get.back(); // close drawer
                          item.$2();
                        },
                      ),
                  ],
                ),
              ),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () async {
                      Get.back();
                      await auth.logout();
                    },
                    child: const Text('Log out', style: TextStyle(color: AppColors.mutedForeground)),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
