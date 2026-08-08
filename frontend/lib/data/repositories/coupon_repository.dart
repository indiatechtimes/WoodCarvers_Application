import '../providers/api_provider.dart';

class CouponRepository {
  final _api = ApiProvider().dio;

  /// Returns {coupon: {...}, discount: number}
  Future<Map<String, dynamic>> validateCoupon(String code, double subtotal) async {
    final res = await _api.post('/coupons/validate', data: {
      'code': code,
      'subtotal': subtotal,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<Map<String, dynamic>>> listCoupons() async {
    final res = await _api.get('/coupons');
    return (res.data['coupons'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> createCoupon(Map<String, dynamic> data) async {
    await _api.post('/coupons', data: data);
  }

  Future<void> updateCoupon(String id, Map<String, dynamic> data) async {
    await _api.put('/coupons/$id', data: data);
  }

  Future<void> deleteCoupon(String id) async {
    await _api.delete('/coupons/$id');
  }
}
