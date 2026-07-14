import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

/// Prints full API URL, method, request payload, and response for every call.
class ApiTraceInterceptor extends Interceptor {
  static const _tag = 'API_TRACE';
  static const _chunkSize = 900;

  bool get _enabled => ApiConstants.enableApiTrace || kDebugMode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_enabled) {
      options.extra['api_trace_started_at'] = DateTime.now();
      _printBlock(
        title: 'REQUEST',
        lines: _requestLines(options),
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_enabled) {
      _printBlock(
        title: 'RESPONSE',
        lines: _responseLines(response),
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_enabled) {
      _printBlock(
        title: 'ERROR',
        lines: _errorLines(err),
      );
    }
    handler.next(err);
  }

  List<String> _requestLines(RequestOptions options) {
    return [
      'METHOD: ${options.method.toUpperCase()}',
      'URL: ${options.uri}',
      if (options.queryParameters.isNotEmpty)
        'QUERY: ${_formatPayload(options.queryParameters)}',
      'REQUEST: ${_formatPayload(options.data)}',
      if (options.headers.containsKey('Authorization'))
        'AUTHORIZATION: Bearer ***',
    ];
  }

  List<String> _responseLines(Response response) {
    final startedAt = response.requestOptions.extra['api_trace_started_at'];
    final durationMs = startedAt is DateTime
        ? DateTime.now().difference(startedAt).inMilliseconds
        : null;

    return [
      'METHOD: ${response.requestOptions.method.toUpperCase()}',
      'URL: ${response.requestOptions.uri}',
      'STATUS: ${response.statusCode}',
      if (durationMs != null) 'DURATION_MS: $durationMs',
      'RESPONSE: ${_formatPayload(response.data)}',
    ];
  }

  List<String> _errorLines(DioException err) {
    final startedAt = err.requestOptions.extra['api_trace_started_at'];
    final durationMs = startedAt is DateTime
        ? DateTime.now().difference(startedAt).inMilliseconds
        : null;

    final lines = <String>[
      'METHOD: ${err.requestOptions.method.toUpperCase()}',
      'URL: ${err.requestOptions.uri}',
      'DIO_TYPE: ${err.type}',
      if (durationMs != null) 'DURATION_MS: $durationMs',
      'REQUEST: ${_formatPayload(err.requestOptions.data)}',
    ];

    final response = err.response;
    if (response != null) {
      lines.addAll([
        'STATUS: ${response.statusCode}',
        'RESPONSE: ${_formatPayload(response.data)}',
      ]);
    } else {
      lines.add('MESSAGE: ${err.message ?? 'n/a'}');
      if (err.error != null) {
        lines.add('ERROR: ${err.error}');
      }
    }

    return lines;
  }

  String _formatPayload(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      if (data is FormData) {
        final fields = data.fields
            .map((entry) => '${entry.key}=${entry.value}')
            .join(', ');
        final files = data.files
            .map((entry) => '${entry.key}=${entry.value.filename ?? 'file'}')
            .join(', ');
        return 'FormData(fields: [$fields], files: [$files])';
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  void _printBlock({
    required String title,
    required List<String> lines,
  }) {
    final buffer = StringBuffer()
      ..writeln('')
      ..writeln('┌─ $_tag ─ $title ${'─' * math.max(1, 42 - title.length)}');

    for (final line in lines) {
      buffer.writeln('│ $line');
    }

    buffer.writeln('└${'─' * 48}');
    _printLong(buffer.toString());
  }

  void _printLong(String message) {
    if (message.length <= _chunkSize) {
      debugPrint(message);
      return;
    }

    var index = 0;
    var part = 1;
    while (index < message.length) {
      final end = math.min(index + _chunkSize, message.length);
      debugPrint('[$_tag part $part] ${message.substring(index, end)}');
      index = end;
      part++;
    }
  }
}
