import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Prints full API URL, request payload, and response body in debug builds.
class ApiTraceInterceptor extends Interceptor {
  static const _tag = 'API_TRACE';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logError(err);
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final buffer = StringBuffer()
      ..writeln('')
      ..writeln('┌─ $_tag ─ REQUEST ─────────────────────────────')
      ..writeln('│ ${options.method.toUpperCase()} ${options.uri}')
      ..writeln('│ Path: ${options.path}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      buffer.writeln('│ Body: ${options.data}');
    }
    if (options.headers.containsKey('Authorization')) {
      buffer.writeln('│ Authorization: Bearer ***');
    }

    buffer.writeln('└──────────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  void _logResponse(Response response) {
    final buffer = StringBuffer()
      ..writeln('')
      ..writeln('┌─ $_tag ─ RESPONSE ────────────────────────────')
      ..writeln(
        '│ ${response.statusCode} '
        '${response.requestOptions.method.toUpperCase()} '
        '${response.requestOptions.uri}',
      )
      ..writeln('│ Body: ${response.data}')
      ..writeln('└──────────────────────────────────────────────');

    debugPrint(buffer.toString());
  }

  void _logError(DioException err) {
    final buffer = StringBuffer()
      ..writeln('')
      ..writeln('┌─ $_tag ─ ERROR ───────────────────────────────')
      ..writeln(
        '│ ${err.requestOptions.method.toUpperCase()} '
        '${err.requestOptions.uri}',
      )
      ..writeln('│ DioExceptionType: ${err.type}');

    final response = err.response;
    if (response != null) {
      buffer
        ..writeln('│ Status: ${response.statusCode}')
        ..writeln('│ Body: ${response.data}');
    } else {
      buffer.writeln('│ Message: ${err.message}');
      if (err.error != null) {
        buffer.writeln('│ Error: ${err.error}');
      }
    }

    buffer.writeln('└──────────────────────────────────────────────');
    debugPrint(buffer.toString());
  }
}
