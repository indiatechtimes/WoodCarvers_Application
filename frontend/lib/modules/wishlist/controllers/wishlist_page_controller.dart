import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/controllers/wishlist_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/wishlist_repository.dart';

class WishlistPageController extends GetxController {
  final _repo = WishlistRepository();

  final RxList<ProductModel> items = <ProductModel>[].obs;
  final RxBool loading = true.obs;
  final RxString shareUrl = ''.obs;
  final RxBool copied = false.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      _load();
    } else {
      loading.value = false;
    }

    // Keep the list in sync if items are toggled elsewhere (e.g. from a
    // ProductCard heart icon while this page is open).
    final wishlistCtrl = Get.find<WishlistController>();
    ever(wishlistCtrl.ids, (Set<String> ids) {
      items.removeWhere((p) => !ids.contains(p.id));
    });
  }

  Future<void> _load() async {
    loading.value = true;
    try {
      items.value = await _repo.getWishlist();
    } catch (_) {
      // keep empty
    } finally {
      loading.value = false;
    }
  }

  Future<void> share() async {
    try {
      final shareId = await _repo.getShareLink();
      final url = 'https://woodcarvers.co/w/$shareId'; // matches window.location.origin/w/:shareId
      shareUrl.value = url;
      await Clipboard.setData(ClipboardData(text: url));
      copied.value = true;
      Get.snackbar('Copied', 'Share link copied to clipboard', snackPosition: SnackPosition.BOTTOM);
      await Future.delayed(const Duration(milliseconds: 2500));
      copied.value = false;
    } catch (_) {
      Get.snackbar('Error', 'Could not create share link', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
