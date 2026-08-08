import 'package:get/get.dart';
import '../controllers/auth_page_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthPageController>(() => AuthPageController());
  }
}
