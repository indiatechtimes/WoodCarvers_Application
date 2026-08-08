import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/controllers/cart_controller.dart';
import '../../../app/controllers/wishlist_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../widgets/cart_drawer.dart';

class RecentProduct {
  final String slug;
  final String name;
  final String image;
  final double price;

  RecentProduct({required this.slug, required this.name, required this.image, required this.price});

  factory RecentProduct.fromJson(Map<String, dynamic> json) => RecentProduct(
        slug: json['slug'] ?? '',
        name: json['name'] ?? '',
        image: json['image'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {'slug': slug, 'name': name, 'image': image, 'price': price};
}

class ProductDetailController extends GetxController {
  final _repo = ProductRepository();
  final _box = GetStorage();
  static const _recentKey = 'wc_recent';
  static const _maxRecent = 8;

  final Rxn<ProductModel> product = Rxn<ProductModel>();
  final RxList<ProductModel> related = <ProductModel>[].obs;
  final RxList<RecentProduct> recentlyViewed = <RecentProduct>[].obs;
  final RxBool loading = true.obs;
  final RxInt activeMediaIndex = 0.obs;
  final RxInt quantity = 1.obs;

  String get slug => Get.parameters['slug'] ?? '';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    activeMediaIndex.value = 0;
    quantity.value = 1;
    try {
      final (p, rel) = await _repo.getProduct(slug);
      product.value = p;
      related.value = rel;
      _updateRecentlyViewed(p);
    } catch (_) {
      product.value = null;
    } finally {
      loading.value = false;
    }
  }

  void _updateRecentlyViewed(ProductModel p) {
    final stored = (_box.read<List>(_recentKey) ?? [])
        .map((e) => RecentProduct.fromJson(Map<String, dynamic>.from(e)))
        .where((r) => r.slug != p.slug)
        .toList();

    recentlyViewed.value = stored.take(_maxRecent).toList();

    final updated = [
      RecentProduct(slug: p.slug, name: p.name, image: p.thumbnailUrl, price: p.price),
      ...stored,
    ].take(_maxRecent).toList();
    _box.write(_recentKey, updated.map((r) => r.toJson()).toList());
  }

  void incrementQty() => quantity.value += 1;
  void decrementQty() => quantity.value = (quantity.value - 1).clamp(1, 999);

  Future<void> addToCart() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.toNamed(Routes.auth);
      return;
    }
    final p = product.value;
    if (p == null) return;
    try {
      await Get.find<CartController>().add(p.id, quantity: quantity.value);
      Get.snackbar('Added to cart', '', snackPosition: SnackPosition.BOTTOM);
      showCartDrawer();
    } catch (_) {
      Get.snackbar('Error', 'Could not add to cart', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleWishlist() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.toNamed(Routes.auth);
      return;
    }
    final p = product.value;
    if (p == null) return;
    final added = await Get.find<WishlistController>().toggle(p.id);
    Get.snackbar(added ? 'Saved to wishlist' : 'Removed from wishlist', '', snackPosition: SnackPosition.BOTTOM);
  }
}
