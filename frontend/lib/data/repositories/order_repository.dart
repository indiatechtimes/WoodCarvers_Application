import '../models/order_model.dart';
import '../providers/api_provider.dart';

class RazorpayOrderInfo {
  final String orderId;
  final String? keyId;
  final int amount; // in paise
  final String currency;
  final bool mock;

  RazorpayOrderInfo({
    required this.orderId,
    this.keyId,
    required this.amount,
    this.currency = 'INR',
    this.mock = false,
  });

  factory RazorpayOrderInfo.fromJson(Map<String, dynamic> json) =>
      RazorpayOrderInfo(
        orderId: json['orderId'] ?? '',
        keyId: json['keyId'],
        amount: json['amount'] ?? 0,
        currency: json['currency'] ?? 'INR',
        mock: json['mock'] == true,
      );
}

class OrderRepository {
  final _api = ApiProvider().dio;

  /// Returns (order, razorpayInfo)
  Future<(OrderModel, RazorpayOrderInfo)> createOrder({
    required ShippingAddress shippingAddress,
    String notes = '',
    String? couponCode,
  }) async {
    final res = await _api.post(
      '/orders',
      data: {
        'shippingAddress': shippingAddress.toJson(),
        'notes': notes,
        if (couponCode != null) 'couponCode': couponCode,
      },
    );
    return (
      OrderModel.fromJson(res.data['order']),
      RazorpayOrderInfo.fromJson(res.data['razorpay']),
    );
  }

  Future<OrderModel> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final res = await _api.post(
      '/orders/verify',
      data: {
        'orderId': orderId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );
    return OrderModel.fromJson(res.data['order']);
  }

  Future<List<OrderModel>> listMyOrders() async {
    final res = await _api.get('/orders');
    return (res.data['orders'] as List)
        .map((o) => OrderModel.fromJson(o))
        .toList();
  }

  Future<OrderModel> getOrder(String id) async {
    final res = await _api.get('/orders/$id');
    return OrderModel.fromJson(res.data['order']);
  }

  // Admin
  Future<List<OrderModel>> listAllOrders() async {
    final res = await _api.get('/orders/all');
    return (res.data['orders'] as List)
        .map((o) => OrderModel.fromJson(o))
        .toList();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _api.put('/orders/$id/status', data: {'status': status});
  }
}
