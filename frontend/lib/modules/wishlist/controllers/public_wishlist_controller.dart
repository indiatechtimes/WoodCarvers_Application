import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/wishlist_repository.dart';

class PublicWishlistController extends GetxController {
  final _repo = WishlistRepository();

  final RxString ownerName = ''.obs;
  final RxList<ProductModel> items = <ProductModel>[].obs;
  final RxBool loading = true.obs;
  final RxBool notFound = false.obs;

  String get shareId => Get.parameters['shareId'] ?? '';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    try {
      final (name, products) = await _repo.getPublicWishlist(shareId);
      ownerName.value = name;
      items.value = products;
    } catch (_) {
      notFound.value = true;
    } finally {
      loading.value = false;
    }
  }
}
