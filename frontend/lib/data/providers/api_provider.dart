import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

// Point this at your deployed/local backend. For Android emulator use
// http://10.0.2.2:5000 to reach your machine's localhost.
const String kBackendUrl = 'https://your-backend-url.com';

class ApiProvider {
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;

  late final Dio dio;
  final _box = GetStorage();
  Future<Response>? _refreshing;

  ApiProvider._internal() {
    dio = Dio(BaseOptions(
      baseUrl: '$kBackendUrl/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _box.read('accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;
        final refreshToken = _box.read('refreshToken');

        if (isUnauthorized && !alreadyRetried && refreshToken != null) {
          try {
            _refreshing ??= Dio().post(
              '$kBackendUrl/api/auth/refresh',
              data: {'refreshToken': refreshToken},
            );
            final refreshResponse = await _refreshing!;
            _refreshing = null;

            final newAccessToken = refreshResponse.data['accessToken'];
            final newRefreshToken = refreshResponse.data['refreshToken'];
            await _box.write('accessToken', newAccessToken);
            await _box.write('refreshToken', newRefreshToken);

            final retryOptions = error.requestOptions;
            retryOptions.extra['retried'] = true;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            _refreshing = null;
            await _box.remove('accessToken');
            await _box.remove('refreshToken');
          }
        }
        handler.next(error);
      },
    ));
  }
}
