import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';

class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  final _emailCtrl = TextEditingController();

  static const _categories = [
    ('Wall Décor', 'wall-decor'),
    ('Home Décor', 'home-decor'),
    ('Kitchen', 'kitchen'),
    ('Office', 'office'),
    ('Gifts', 'gifts'),
    ('Personalized', 'personalized'),
  ];

  void _subscribe() {
    if (!_emailCtrl.text.contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.snackbar(
      'Welcome to the WOOD CARVERS list',
      '10% off is on its way',
      snackPosition: SnackPosition.BOTTOM,
    );
    _emailCtrl.clear();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WOOD CARVERS',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text(
            'A small studio in Kolkata , India crafting timeless wooden décor, gifts and personalised heirlooms. Each piece is finished by hand.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.mail_outline, size: 14, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                '@WoodCarversStore.com',
                style: TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Kolkata, Assam ,  · India',
                style: TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Text(
            'SHOP',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final c in _categories)
                GestureDetector(
                  onTap: () => Get.toNamed('${Routes.shop}?category=${c.$2}'),
                  child: Text(
                    c.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),

          Text(
            'NEWSLETTER',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sign up for 10% off your first heirloom + early access to seasonal collections.',
            style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(hintText: 'you@gmail.com'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _subscribe,
                child: const Text('Subscribe'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '© ${DateTime.now().year} WOOD CARVERS · Handcrafted with care in India',
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
}
