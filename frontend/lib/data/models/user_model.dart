class AddressModel {
  final String? id;
  final String label;
  final String name;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool isDefault;

  AddressModel({
    this.id,
    this.label = 'Home',
    this.name = '',
    this.phone = '',
    this.line1 = '',
    this.line2 = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.country = 'India',
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'],
      label: json['label'] ?? 'Home',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      line1: json['line1'] ?? '',
      line2: json['line2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'label': label,
        'name': name,
        'phone': phone,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
        'isDefault': isDefault,
      };
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'user' | 'admin'
  final String phone;
  final List<AddressModel> addresses;
  final List<String> wishlist;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.phone = '',
    this.addresses = const [],
    this.wishlist = const [],
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      phone: json['phone'] ?? '',
      addresses: (json['addresses'] as List? ?? [])
          .map((a) => AddressModel.fromJson(a))
          .toList(),
      wishlist: (json['wishlist'] as List? ?? [])
          .map((w) => w is String ? w : (w['_id'] ?? ''))
          .cast<String>()
          .toList(),
    );
  }
}
