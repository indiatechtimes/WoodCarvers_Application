import 'package:get/get.dart';
import '../controllers/orders_controllers.dart';

class OrdersListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersListController>(() => OrdersListController());
  }
}

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderDetailController>(() => OrderDetailController());
  }
}
