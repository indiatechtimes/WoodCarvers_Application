import 'package:get/get.dart';
import '../controllers/wishlist_page_controller.dart';
import '../controllers/public_wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistPageController>(() => WishlistPageController());
  }
}

class PublicWishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublicWishlistController>(() => PublicWishlistController());
  }
}
