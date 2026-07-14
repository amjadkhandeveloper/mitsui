import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../utils/network_feedback.dart';
import 'api_trace_interceptor.dart';

class DioClient {
  late Dio _dio;
  final SharedPreferences sharedPreferences;
  DateTime? _lastConnectivityCheckAt;
  bool? _lastConnectivityStatus;

  DioClient({required this.sharedPreferences}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Configure SSL certificate handling
    // NOTE: This accepts certificates for the API host - use only for development/testing
    // For production, ensure proper SSL certificates are installed
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Accept certificate for the API host only
        final apiHost = Uri.parse(ApiConstants.baseUrl).host;
        return host == apiHost;
      };
      return client;
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Global network connectivity guard (prevents Dio errors across app)
          final ok = await _hasInternetConnection();
          if (!ok) {
            if (ApiConstants.enableApiTrace || kDebugMode) {
              debugPrint(
                'API_TRACE ─ BLOCKED (no internet)\n'
                'METHOD: ${options.method.toUpperCase()}\n'
                'URL: ${options.uri}\n'
                'REQUEST: ${options.data}',
              );
            }
            NetworkFeedback.showNoInternet();
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.unknown,
                error: const SocketException('No internet'),
              ),
            );
          }

          // Add auth token if available
          final token = sharedPreferences.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (_isNoInternetDioError(error)) {
            NetworkFeedback.showNoInternet();
          }
          return handler.next(error);
        },
      ),
    );

    // Log full URL + request/response after auth header is attached.
    _dio.interceptors.add(ApiTraceInterceptor());
  }

  Dio get dio => _dio;

  Future<bool> _hasInternetConnection() async {
    // Cache result briefly to avoid DNS lookup for every request burst
    final now = DateTime.now();
    if (_lastConnectivityCheckAt != null &&
        now.difference(_lastConnectivityCheckAt!) < const Duration(seconds: 3) &&
        _lastConnectivityStatus != null) {
      return _lastConnectivityStatus!;
    }

    bool ok = false;
    try {
      final host = Uri.parse(ApiConstants.baseUrl).host;
      final results = await InternetAddress.lookup(host).timeout(
        const Duration(seconds: 5),
        onTimeout: () => <InternetAddress>[],
      );
      ok = results.isNotEmpty && results.first.rawAddress.isNotEmpty;
    } catch (_) {
      ok = false;
    }

    _lastConnectivityCheckAt = now;
    _lastConnectivityStatus = ok;
    return ok;
  }

  bool _isNoInternetDioError(DioException error) {
    if (error.error is SocketException) return true;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        return error.error is SocketException ||
            error.message?.toLowerCase().contains('network') == true;
      default:
        return false;
    }
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
            'Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message'] ?? 'Server error occurred';
        if (statusCode != null && statusCode >= 500) {
          return ServerException('Server error: $message');
        } else if (statusCode != null && statusCode >= 400) {
          return ValidationException('Validation error: $message');
        }
        return ServerException(message);

      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');

      case DioExceptionType.unknown:
      default:
        return const NetworkException(
            'No internet connection. Please check your network.');
    }
  }
}
