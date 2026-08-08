import 'dart:io';
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../providers/api_provider.dart';

class MediaRepository {
  final _api = ApiProvider().dio;

  Future<ProductMedia> upload(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final res = await _api.post('/media/upload', data: formData);
    final media = res.data['media'];
    return ProductMedia(
      url: media['url'],
      publicId: media['publicId'] ?? '',
      type: media['type'] ?? 'image',
    );
  }
}
