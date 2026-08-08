import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';

class AuthRepository {
  final _api = ApiProvider().dio;
  final _box = GetStorage();

  Future<UserModel> register(String name, String email, String password) async {
    final res = await _api.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    await _saveTokens(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> login(String email, String password) async {
    final res = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _saveTokens(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel?> getMe() async {
    final token = _box.read('accessToken');
    if (token == null) return null;
    try {
      final res = await _api.get('/auth/me');
      return UserModel.fromJson(res.data['user']);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final res = await _api.put('/auth/profile', data: data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', data: {
        'refreshToken': _box.read('refreshToken'),
      });
    } catch (_) {
      // ignore network errors on logout
    }
    await _box.remove('accessToken');
    await _box.remove('refreshToken');
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await _box.write('accessToken', data['accessToken']);
    await _box.write('refreshToken', data['refreshToken']);
  }

  // Addresses
  Future<List<AddressModel>> listAddresses() async {
    final res = await _api.get('/addresses');
    return (res.data['addresses'] as List)
        .map((a) => AddressModel.fromJson(a))
        .toList();
  }

  Future<List<AddressModel>> addAddress(AddressModel address) async {
    final res = await _api.post('/addresses', data: address.toJson());
    return (res.data['addresses'] as List)
        .map((a) => AddressModel.fromJson(a))
        .toList();
  }

  Future<List<AddressModel>> updateAddress(String id, AddressModel address) async {
    final res = await _api.put('/addresses/$id', data: address.toJson());
    return (res.data['addresses'] as List)
        .map((a) => AddressModel.fromJson(a))
        .toList();
  }

  Future<List<AddressModel>> deleteAddress(String id) async {
    final res = await _api.delete('/addresses/$id');
    return (res.data['addresses'] as List)
        .map((a) => AddressModel.fromJson(a))
        .toList();
  }
}
