// import 'dart:io';
// import 'package:dio/dio.dart';
// import '../models/product_model.dart';
// import '../providers/api_provider.dart';

// class MediaRepository {
//   final _api = ApiProvider().dio;

//   Future<ProductMedia> upload(File file) async {
//     final formData = FormData.fromMap({
//       'file': await MultipartFile.fromFile(file.path),
//     });
//     final res = await _api.post('/media/upload', data: formData);
//     final media = res.data['media'];
//     return ProductMedia(
//       url: media['url'],
//       publicId: media['publicId'] ?? '',
//       type: media['type'] ?? 'image',
//     );
//   }
// }
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../providers/api_provider.dart';

class MediaRepository {
  final _api = ApiProvider().dio;

  /// Takes an XFile (from image_picker) rather than dart:io File — File
  /// paths don't exist on web (XFile there wraps a blob URL), so we always
  /// upload via bytes, which works identically on mobile, desktop, and web.
  Future<ProductMedia> upload(XFile file) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
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
