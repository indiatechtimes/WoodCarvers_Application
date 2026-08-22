// import 'package:get/get.dart';
// import '../controllers/admin_controllers.dart';

// class AdminBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<AdminController>(() => AdminController());
//   }
// }


import 'package:get/get.dart';
import '../controllers/admin_controllers.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
  }
}
