import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _token;
          if (token != null && token.isNotEmpty) {
            options.headers['authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  String? _token;

  Dio get dio => _dio;

  void setToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<Object>(
        path,
        queryParameters: query,
      );
      final data = response.data;
      if (data is Map) return data.cast<String, dynamic>();
      throw const ApiException('Unexpected response.');
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
  }) async {
    try {
      final response = await _dio.post<Object>(path, data: body);
      final data = response.data;
      if (data is Map) return data.cast<String, dynamic>();
      throw const ApiException('Unexpected response.');
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Object? body,
  }) async {
    try {
      final response = await _dio.patch<Object>(path, data: body);
      final data = response.data;
      if (data is Map) return data.cast<String, dynamic>();
      throw const ApiException('Unexpected response.');
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  ApiException _mapDioException(DioException e) {
    final response = e.response;
    final status = response?.statusCode;
    final data = response?.data;

    if (data is Map && data['message'] is String) {
      return ApiException(
        (data['message'] as String).trim(),
        statusCode: status,
        cause: e,
      );
    }
    if (status != null) {
      return ApiException(
        'Request failed ($status).',
        statusCode: status,
        cause: e,
      );
    }
    return ApiException(
      'Network error. Check API base URL and connection.',
      cause: e,
    );
  }
}

