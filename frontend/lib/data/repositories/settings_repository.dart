import '../providers/api_provider.dart';

class SettingsRepository {
  final _api = ApiProvider().dio;

  /// Returns the raw settings map, e.g. hero_image, hero_headline,
  /// hero_subheading, promo_banner: { active, text }
  Future<Map<String, dynamic>> getSettings() async {
    final res = await _api.get('/settings');
    return Map<String, dynamic>.from(res.data['settings'] ?? {});
  }

  Future<void> updateSetting(String key, dynamic value) async {
    await _api.put('/settings/$key', data: {'value': value});
  }
}
