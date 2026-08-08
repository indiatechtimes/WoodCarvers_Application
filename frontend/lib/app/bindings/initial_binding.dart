import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../../modules/splash/controllers/splash_controller.dart';
import '../services/push_notification_service.dart';

// These stay alive for the whole app, mirroring the top-level
// AuthProvider/CartProvider/WishlistProvider wrapping in App.js.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
    Get.put(SplashController());

    // Firebase.initializeApp() in main() is wrapped in try/catch — only
    // wire up push if it actually succeeded (google-services.json /
    // GoogleService-Info.plist present).
    if (Firebase.apps.isNotEmpty) {
      final push = Get.put(PushNotificationService(), permanent: true);
      push.init();
    }
  }
}
