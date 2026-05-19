import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../constants/api_constants.dart';
import 'auth_service.dart';

/// Main API service — mirrors React's `Api.js` / `apiCall()`.
class ApiService extends GetxService {
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.mgServer,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final auth = Get.find<AuthService>();
        final token = auth.token;
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['ngrok-skip-browser-warning'] = '69420';
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  /// Generic API call matching React's `apiCall(method, endpoint, data)`.
  Future<dynamic> call(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final String url = endpoint.startsWith('/dashboard') 
          ? '${ApiConstants.monitoringServer}$endpoint' 
          : endpoint;

      final Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(url, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await _dio.post(url, data: data);
          break;
        case 'PUT':
          response = await _dio.put(url, data: data);
          break;
        case 'DELETE':
          response = await _dio.delete(url, data: data);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      return response.data;
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map
          ? (e.response!.data['error'] ?? 'Request failed. Please try again.')
          : 'Request failed. Please try again.';
      throw errorMsg;
    }
  }

  /// Upload file with FormData (for Buckets).
  Future<dynamic> upload(
    String endpoint, {
    required FormData formData,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map
          ? (e.response!.data['error'] ?? 'Upload failed.')
          : 'Upload failed.';
      throw errorMsg;
    }
  }
}
