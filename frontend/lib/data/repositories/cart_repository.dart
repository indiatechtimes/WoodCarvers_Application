import '../models/cart_model.dart';
import '../providers/api_provider.dart';

class CartRepository {
  final _api = ApiProvider().dio;

  Future<CartModel> getCart() async {
    final res = await _api.get('/cart');
    return CartModel.fromJson(res.data['cart']);
  }

  Future<CartModel> addToCart(String productId, {int quantity = 1}) async {
    final res = await _api.post('/cart/add', data: {
      'productId': productId,
      'quantity': quantity,
    });
    return CartModel.fromJson(res.data['cart']);
  }

  Future<CartModel> updateItem(String productId, int quantity) async {
    final res = await _api.put('/cart/item', data: {
      'productId': productId,
      'quantity': quantity,
    });
    return CartModel.fromJson(res.data['cart']);
  }

  Future<CartModel> removeItem(String productId) async {
    final res = await _api.delete('/cart/item/$productId');
    return CartModel.fromJson(res.data['cart']);
  }

  Future<CartModel> clearCart() async {
    final res = await _api.delete('/cart');
    return CartModel.fromJson(res.data['cart']);
  }
}
