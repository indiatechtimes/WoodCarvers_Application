import 'package:get/get.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
  final _repo = CartRepository();

  final Rx<CartModel> cart = CartModel.empty().obs;
  final RxBool loading = false.obs;

  int get count => cart.value.itemCount;
  double get subtotal => cart.value.subtotal;

  @override
  void onInit() {
    super.onInit();
    // React re-fetches the cart whenever `user` changes; mirror that by
    // listening to AuthController's user state here.
    final auth = Get.find<AuthController>();
    ever(auth.user, (_) => refresh());
    if (auth.isLoggedIn) refresh();
  }

  @override
  Future<void> refresh() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      cart.value = CartModel.empty();
      return;
    }
    loading.value = true;
    try {
      cart.value = await _repo.getCart();
    } catch (_) {
      // ignore, keep previous state
    } finally {
      loading.value = false;
    }
  }

  Future<void> add(String productId, {int quantity = 1}) async {
    cart.value = await _repo.addToCart(productId, quantity: quantity);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    cart.value = await _repo.updateItem(productId, quantity);
  }

  Future<void> remove(String productId) async {
    cart.value = await _repo.removeItem(productId);
  }

  Future<void> clear() async {
    cart.value = await _repo.clearCart();
  }
}
