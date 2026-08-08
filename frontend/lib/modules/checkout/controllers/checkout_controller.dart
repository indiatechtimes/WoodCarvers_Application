import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/controllers/cart_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/coupon_repository.dart';
import '../../../data/repositories/order_repository.dart';

class CheckoutController extends GetxController {
  final _authRepo = AuthRepository();
  final _orderRepo = OrderRepository();
  final _couponRepo = CouponRepository();
  final _razorpay = Razorpay();

  final RxInt step = 1.obs; // 1: shipping, 2: payment, 3: review

  final RxList<AddressModel> savedAddresses = <AddressModel>[].obs;
  final Rxn<String> selectedAddressId = Rxn<String>();

  // Shipping form fields
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final line1Ctrl = TextEditingController();
  final line2Ctrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final countryCtrl = TextEditingController(text: 'India');
  final notesCtrl = TextEditingController();
  final RxBool saveAddress = true.obs;

  final RxString couponCode = ''.obs;
  final Rxn<Map<String, dynamic>> couponInfo = Rxn<Map<String, dynamic>>(); // {code, discount}

  final RxBool placingOrder = false.obs;

  double get subtotal => Get.find<CartController>().subtotal;
  double get discount => (couponInfo.value?['discount'] as num?)?.toDouble() ?? 0;
  double get afterDiscount => (subtotal - discount).clamp(0, double.infinity);
  double get shipping => afterDiscount >= 1499 ? 0 : 99;
  double get tax => (afterDiscount * 0.05).roundToDouble();
  double get total => afterDiscount + shipping + tax;

  bool get canProceedStep1 =>
      nameCtrl.text.trim().isNotEmpty &&
      phoneCtrl.text.trim().isNotEmpty &&
      line1Ctrl.text.trim().isNotEmpty &&
      cityCtrl.text.trim().isNotEmpty &&
      stateCtrl.text.trim().isNotEmpty &&
      pincodeCtrl.text.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    nameCtrl.text = auth.user.value?.name ?? '';

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    _loadAddresses();

    final args = Get.arguments as Map?;
    final prefilledCoupon = args?['couponCode'] as String?;
    if (prefilledCoupon != null && prefilledCoupon.isNotEmpty) {
      couponCode.value = prefilledCoupon;
      _previewCoupon();
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _authRepo.listAddresses();
      savedAddresses.value = addresses;
      final def = addresses.firstWhereOrNull((a) => a.isDefault) ?? (addresses.isNotEmpty ? addresses.first : null);
      if (def != null) selectSavedAddress(def);
    } catch (_) {
      // no addresses yet — fine, user fills the form fresh
    }
  }

  Future<void> _previewCoupon() async {
    if (couponCode.value.isEmpty) return;
    try {
      final res = await _couponRepo.validateCoupon(couponCode.value, subtotal);
      couponInfo.value = {'code': res['coupon']['code'], 'discount': (res['discount'] as num).toDouble()};
    } catch (_) {
      couponCode.value = '';
    }
  }

  Future<void> applyCoupon() async {
    if (couponCode.value.trim().isEmpty) return;
    try {
      final res = await _couponRepo.validateCoupon(couponCode.value.trim(), subtotal);
      couponInfo.value = {'code': res['coupon']['code'], 'discount': (res['discount'] as num).toDouble()};
      Get.snackbar('Applied', 'Saved ₹${couponInfo.value!['discount']}', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      couponInfo.value = null;
      Get.snackbar('Invalid coupon', '', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void selectSavedAddress(AddressModel a) {
    selectedAddressId.value = a.id;
    nameCtrl.text = a.name;
    phoneCtrl.text = a.phone;
    line1Ctrl.text = a.line1;
    line2Ctrl.text = a.line2;
    cityCtrl.text = a.city;
    stateCtrl.text = a.state;
    pincodeCtrl.text = a.pincode;
    countryCtrl.text = a.country;
    saveAddress.value = false;
  }

  void clearAddress() {
    selectedAddressId.value = null;
    final auth = Get.find<AuthController>();
    nameCtrl.text = auth.user.value?.name ?? '';
    phoneCtrl.clear();
    line1Ctrl.clear();
    line2Ctrl.clear();
    cityCtrl.clear();
    stateCtrl.clear();
    pincodeCtrl.clear();
    countryCtrl.text = 'India';
    saveAddress.value = true;
  }

  void nextStep() {
    if (step.value == 1 && !canProceedStep1) {
      Get.snackbar('Incomplete address', 'Please complete your address', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (step.value == 3) {
      placeOrder();
      return;
    }
    step.value += 1;
  }

  void previousStep() {
    if (step.value > 1) step.value -= 1;
  }

  ShippingAddress _buildShippingAddress() => ShippingAddress(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        line1: line1Ctrl.text.trim(),
        line2: line2Ctrl.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        pincode: pincodeCtrl.text.trim(),
        country: countryCtrl.text.trim().isEmpty ? 'India' : countryCtrl.text.trim(),
      );

  OrderModel? _pendingOrder;

  Future<void> placeOrder() async {
    placingOrder.value = true;
    try {
      if (saveAddress.value && selectedAddressId.value == null) {
        try {
          await _authRepo.addAddress(AddressModel(
            label: 'Home',
            name: nameCtrl.text.trim(),
            phone: phoneCtrl.text.trim(),
            line1: line1Ctrl.text.trim(),
            line2: line2Ctrl.text.trim(),
            city: cityCtrl.text.trim(),
            state: stateCtrl.text.trim(),
            pincode: pincodeCtrl.text.trim(),
            country: countryCtrl.text.trim(),
          ));
        } catch (_) {
          // non-fatal
        }
      }

      final (order, rp) = await _orderRepo.createOrder(
        shippingAddress: _buildShippingAddress(),
        notes: notesCtrl.text.trim(),
        couponCode: couponInfo.value?['code'],
      );
      _pendingOrder = order;

      if (rp.mock || rp.keyId == null) {
        Get.snackbar('Demo mode', 'Razorpay keys not configured — completing in demo mode',
            snackPosition: SnackPosition.BOTTOM);
        await _finishOrder(rp.orderId, 'mock_pay_${DateTime.now().millisecondsSinceEpoch}', 'mock');
        return;
      }

      final auth = Get.find<AuthController>();
      final user = auth.user.value;
      _razorpay.open({
        'key': rp.keyId,
        'amount': rp.amount,
        'currency': rp.currency,
        'name': 'WOOD CARVERS',
        'description': 'Order #${order.id.length >= 6 ? order.id.substring(order.id.length - 6) : order.id}',
        'order_id': rp.orderId,
        'prefill': {
          'contact': phoneCtrl.text.trim(),
          if (user != null) 'name': user.name,
          if (user != null) 'email': user.email,
        },
        'theme': {'color': '#5C3A21'},
      });
    } catch (e) {
      Get.snackbar('Error', 'Could not place order', snackPosition: SnackPosition.BOTTOM);
      placingOrder.value = false;
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    await _finishOrder(
      response.orderId ?? '',
      response.paymentId ?? '',
      response.signature ?? '',
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    placingOrder.value = false;
    Get.snackbar('Payment failed', response.message ?? 'Payment was not completed', snackPosition: SnackPosition.BOTTOM);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    placingOrder.value = false;
    Get.snackbar('External wallet selected', response.walletName ?? '', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _finishOrder(String razorpayOrderId, String razorpayPaymentId, String razorpaySignature) async {
    final order = _pendingOrder;
    if (order == null) return;
    try {
      final verified = await _orderRepo.verifyPayment(
        orderId: order.id,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      await Get.find<CartController>().refresh();
      Get.offAllNamed('${Routes.orders}/${verified.id}?just_paid=1');
    } catch (_) {
      Get.snackbar('Error', 'Payment could not be verified', snackPosition: SnackPosition.BOTTOM);
    } finally {
      placingOrder.value = false;
    }
  }

  @override
  void onClose() {
    _razorpay.clear();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    line1Ctrl.dispose();
    line2Ctrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pincodeCtrl.dispose();
    countryCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }
}
