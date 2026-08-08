import '../providers/api_provider.dart';

class FcmRepository {
  final _api = ApiProvider().dio;

  Future<void> registerToken(String token) async {
    await _api.post('/auth/fcm-token', data: {'token': token});
  }
}
