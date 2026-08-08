import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class OrdersListController extends GetxController {
  final _repo = OrderRepository();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      orders.value = await _repo.listMyOrders();
    } catch (_) {
      // keep empty
    } finally {
      loading.value = false;
    }
  }
}

class OrderDetailController extends GetxController {
  final _repo = OrderRepository();

  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final RxBool loading = true.obs;

  String get orderId => Get.parameters['id'] ?? '';
  bool get justPaid => Get.parameters['just_paid'] == '1';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      order.value = await _repo.getOrder(orderId);
    } catch (_) {
      order.value = null;
    } finally {
      loading.value = false;
    }
  }
}
