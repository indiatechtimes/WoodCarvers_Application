class OrderItemModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.name,
    this.image = '',
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product'] is String ? json['product'] : (json['product']?['_id'] ?? ''),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class ShippingAddress {
  final String name;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  ShippingAddress({
    this.name = '',
    this.phone = '',
    this.line1 = '',
    this.line2 = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.country = 'India',
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      line1: json['line1'] ?? '',
      line2: json['line2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
      };
}

class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final double discount;
  final String couponCode;
  final String status; // pending, confirmed, processing, shipped, delivered, cancelled...
  final String paymentStatus;
  final String paymentMethod;
  final String razorpayOrderId;
  final ShippingAddress shippingAddress;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    this.items = const [],
    this.subtotal = 0,
    this.shipping = 0,
    this.tax = 0,
    this.total = 0,
    this.discount = 0,
    this.couponCode = '',
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod = 'razorpay',
    this.razorpayOrderId = '',
    required this.shippingAddress,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItemModel.fromJson(i))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shipping: (json['shipping'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      couponCode: json['couponCode'] ?? '',
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'razorpay',
      razorpayOrderId: json['razorpayOrderId'] ?? '',
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
