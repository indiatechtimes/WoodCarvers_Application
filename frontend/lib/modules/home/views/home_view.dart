import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_footer.dart';
import '../../../widgets/promo_bar.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/star_rating.dart';
import '../controllers/home_controller.dart';

// Static content matching HomePage.jsx's CATEGORIES/FEATURES/REVIEWS/IG_TILES
// (these are hardcoded on the React side too, not API-driven).
const _categories = [
  (
    'wall-decor',
    'Wall Décor',
    'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1200&q=80',
  ),
  (
    'home-decor',
    'Home Décor',
    'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200&q=80',
  ),
  (
    'kitchen',
    'Kitchen',
    'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=1200&q=80',
  ),
  (
    'office',
    'Office',
    'https://images.unsplash.com/photo-1631679706909-1844bbd07221?w=1200&q=80',
  ),
  (
    'gifts',
    'Gifts',
    'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=1200&q=80',
  ),
  (
    'personalized',
    'Personalized',
    'https://images.unsplash.com/photo-1519741497674-611481863552?w=1200&q=80',
  ),
];

const _features = [
  (
    Icons.emoji_events_outlined,
    '100% Handmade',
    'Every piece shaped and sanded by our craftsmen.',
  ),
  (
    Icons.eco_outlined,
    'Premium Wood',
    'Sheesham, teak, walnut, mango — responsibly sourced.',
  ),
  (
    Icons.auto_awesome_outlined,
    'Eco-friendly',
    'Natural oils and beeswax, zero-waste offcuts.',
  ),
  (
    Icons.shield_outlined,
    'Secure Payments',
    'Razorpay-backed, UPI/Netbanking/Cards.',
  ),
  (
    Icons.local_shipping_outlined,
    'Fast Delivery',
    'Free shipping over ₹1,499 · pan-India.',
  ),
  (
    Icons.place_outlined,
    'Made in India',
    'Crafted in Jodhpur by third-generation artisans.',
  ),
];

const _reviews = [
  (
    'Ananya P.',
    'Bengaluru',
    5,
    'The walnut sunburst is even richer in person. It has completely transformed our living room.',
  ),
  (
    'Rohan S.',
    'Mumbai',
    5,
    'A wedding coordinates plaque — arrived beautifully packaged. Now proudly hanging in our hallway.',
  ),
  (
    'Priya M.',
    'Delhi',
    5,
    'The teak lamp is a gorgeous object. The linen shade is warm and the weight is reassuring.',
  ),
];

const _igTiles = [
  'https://images.unsplash.com/photo-1584208632869-05fa2b2a5934?w=800&q=80',
  'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80',
  'https://images.unsplash.com/photo-1631679706909-1844bbd07221?w=800&q=80',
  'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=800&q=80',
  'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
  'https://images.unsplash.com/photo-1611967164521-abae8fba4668?w=800&q=80',
];

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PromoBar(text: controller.promoText.value),
                _hero(context),
                _categoriesSection(context),
                _bestSellersSection(context),
                _whyChooseSection(context),
                _newArrivalsSection(context),
                _testimonialsSection(context),
                _instagramSection(context),
                const AppFooter(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String eyebrow,
    String title, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SizedBox(
                width: 28,
                height: 1,
                child: ColoredBox(color: AppColors.accent),
              ),
              SizedBox(width: 8),
              Text(
                'WOOD CARVERS · Studio Collection 2026',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => Text(
              controller.heroHeadline.value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                height: 1.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => Text(
              controller.heroSubheading.value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.shop),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Shop Collection'),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Obx(
                () => CachedNetworkImage(
                  imageUrl: controller.heroImage.value,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppColors.muted),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statBlock('14+', 'Master artisans'),
              const SizedBox(width: 20),
              _statBlock('4.9★', 'Avg. buyer rating'),
              const SizedBox(width: 20),
              _statBlock('2026', 'Studio est.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBlock(String value, String label) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    ),
  );

  Widget _categoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          context,
          'Explore the collection',
          'Featured categories',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 5 / 4,
            ),
            itemBuilder: (_, i) {
              final (key, label, image) = _categories[i];
              return GestureDetector(
                onTap: () => Get.toNamed('${Routes.shop}?category=$key'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xB34A5D3E), Colors.transparent],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 12,
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _bestSellersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(context, 'Loved by home-makers', 'Best sellers'),
        Obx(
          () => SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.bestSellers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (_, i) =>
                  ProductCard(product: controller.bestSellers[i], width: 170),
            ),
          ),
        ),
      ],
    );
  }

  Widget _whyChooseSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      color: AppColors.secondary.withOpacity(0.6),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'WHY WOOD CARVERS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A studio built on craft, not shortcuts',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (_, i) {
              final (icon, title, desc) = _features[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 20, color: AppColors.accent),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _newArrivalsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          context,
          'Fresh from the studio',
          'New arrivals',
          trailing: TextButton(
            onPressed: () => Get.toNamed('${Routes.shop}?sort=-createdAt'),
            child: const Text('See all'),
          ),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.newArrivals.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 14,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (_, i) => ProductCard(
                product: controller.newArrivals[i],
                width: double.infinity,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _testimonialsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT BUYERS SAY',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: Color(0xFFD2A679),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Objects that live longer than trends',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          for (final r in _reviews)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StarRating(value: r.$3.toDouble(), size: 14),
                  const SizedBox(height: 10),
                  Text(
                    '"${r.$4}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    r.$1,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  Text(
                    r.$2,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _instagramSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          context,
          'In your homes',
          '@woodcarvers.co',
          trailing: const Icon(
            Icons.camera_alt_outlined,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _igTiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _igTiles[i],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
