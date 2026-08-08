import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/settings_repository.dart';

const _heroFallbackImage =
    'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=2000&q=85';

class HomeController extends GetxController {
  final _productRepo = ProductRepository();
  final _settingsRepo = SettingsRepository();

  final RxList<ProductModel> bestSellers = <ProductModel>[].obs;
  final RxList<ProductModel> newArrivals = <ProductModel>[].obs;
  final RxBool loading = true.obs;

  final RxString heroImage = _heroFallbackImage.obs;
  final RxString heroHeadline = 'Handcrafted Elegance for Every Home'.obs;
  final RxString heroSubheading =
      'Premium handcrafted wooden décor and personalized creations made with passion, precision, and timeless craftsmanship.'
          .obs;
  final RxString promoText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    loading.value = true;
    await Future.wait([_loadProducts(), _loadSettings()]);
    loading.value = false;
  }

  Future<void> _loadProducts() async {
    try {
      final results = await Future.wait([
        _productRepo.listProducts(params: {'featured': true, 'limit': 8}),
        _productRepo.listProducts(params: {'sort': '-createdAt', 'limit': 6}),
      ]);
      bestSellers.value = results[0].products;
      newArrivals.value = results[1].products;
    } catch (_) {
      // keep empty lists on failure
    }
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsRepo.getSettings();
      if (settings['hero_image'] != null) heroImage.value = settings['hero_image'];
      if (settings['hero_headline'] != null) heroHeadline.value = settings['hero_headline'];
      if (settings['hero_subheading'] != null) heroSubheading.value = settings['hero_subheading'];
      final banner = settings['promo_banner'];
      if (banner is Map && banner['active'] == true && (banner['text'] as String?)?.isNotEmpty == true) {
        promoText.value = banner['text'];
      }
    } catch (_) {
      // keep fallbacks
    }
  }
}
