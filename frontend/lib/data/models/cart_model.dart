import 'product_model.dart';

class CartItemModel {
  // `product` is the populated product object returned by GET /cart
  final ProductModel product;
  final int quantity;

  CartItemModel({required this.product, required this.quantity});

  double get lineTotal => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartModel {
  final List<CartItemModel> items;

  CartModel({this.items = const []});

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);

  bool get isEmpty => items.isEmpty;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List? ?? [])
          .map((i) => CartItemModel.fromJson(i))
          .toList(),
    );
  }

  factory CartModel.empty() => CartModel(items: []);
}
