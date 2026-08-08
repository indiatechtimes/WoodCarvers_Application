import 'package:get/get.dart';
import '../../data/repositories/wishlist_repository.dart';
import 'auth_controller.dart';

class WishlistController extends GetxController {
  final _repo = WishlistRepository();

  final RxSet<String> ids = <String>{}.obs;

  bool has(String productId) => ids.contains(productId);

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    ever(auth.user, (_) => refresh());
    if (auth.isLoggedIn) refresh();
  }

  @override
  Future<void> refresh() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      ids.clear();
      return;
    }
    try {
      final fetched = await _repo.getIds();
      ids
        ..clear()
        ..addAll(fetched);
    } catch (_) {
      // ignore, keep previous state
    }
  }

  /// Returns true if the item was added, false if removed.
  Future<bool> toggle(String productId) async {
    final (added, updatedIds) = await _repo.toggle(productId);
    ids
      ..clear()
      ..addAll(updatedIds);
    return added;
  }
}
