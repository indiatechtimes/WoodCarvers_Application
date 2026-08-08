import 'package:get/get.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _boot();
  }

  Future<void> _boot() async {
    final auth = Get.find<AuthController>();
    // Wait for the initial /auth/me check (kicked off in AuthController.onInit)
    // to finish before deciding where to send the user.
    while (auth.loading.value) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    // Always land on Home ('/') — auth is only required for
    // checkout/wishlist/account/orders/admin, same as the React app's
    // RequireAuth wrapper which lets guests browse freely otherwise.
    Get.offAllNamed(Routes.home);
  }
}
