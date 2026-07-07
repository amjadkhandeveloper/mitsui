import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../../features/splash/data/datasources/local_storage_data_source.dart';

class ForceUpdatePolicy {
  final int remoteAppVersion;
  final bool forceLogout;

  const ForceUpdatePolicy({
    required this.remoteAppVersion,
    required this.forceLogout,
  });
}

class ForceUpdateService {
  final Dio dio;
  final LocalStorageDataSource localStorage;

  ForceUpdateService({
    required this.dio,
    required this.localStorage,
  });

  /// Returns true when the installed build is below the minimum version
  /// required by the backend.
  Future<bool> isUpdateRequired() async {
    try {
      final policy = await fetchPolicy();
      if (policy == null) return false;
      return ApiConstants.localAppVersion < policy.remoteAppVersion;
    } catch (e, stack) {
      debugPrint('ForceUpdate: check failed: $e\n$stack');
      return false;
    }
  }

  Future<ForceUpdatePolicy?> fetchPolicy() async {
    try {
      final hasSession = await localStorage.hasActiveSession();
      if (!hasSession) {
        final userId = await localStorage.getUserId();
        final driverId = await localStorage.getDriverId();
        final authToken = await localStorage.getAuthToken();
        debugPrint(
          'ForceUpdate: skipped (no active session) '
          'userId=$userId driverId=$driverId '
          'authTokenPresent=${authToken != null && authToken.isNotEmpty}',
        );
        return null;
      }

      final clientId =
          await localStorage.getClientId() ?? ApiConstants.defaultClientId;

      debugPrint(
        'ForceUpdate: POST ${ApiConstants.baseUrl}${ApiConstants.forceUpdateClient} '
        'payload={clientId: $clientId}',
      );

      final response = await dio.post(
        ApiConstants.forceUpdateClient,
        data: {'clientId': clientId},
      );

      debugPrint(
        'ForceUpdate: response statusCode=${response.statusCode} '
        'body=${response.data}',
      );

      final body = _asMap(response.data);
      if (body == null) {
        debugPrint('ForceUpdate: invalid response body type: ${response.data.runtimeType}');
        return null;
      }

      final status = body['status'];
      if (!_isSuccessStatus(status)) {
        debugPrint('ForceUpdate: unexpected status=$status body=$body');
        return null;
      }

      final firstItem = _firstDataItem(body['data']);
      if (firstItem == null) {
        debugPrint('ForceUpdate: could not parse data=${body['data']}');
        return null;
      }

      final remoteVersion = _parseRemoteAppVersion(firstItem);
      if (remoteVersion == null) {
        debugPrint('ForceUpdate: missing appversion in $firstItem');
        return null;
      }

      final forceLogout = _parseForceLogout(firstItem) ?? false;

      debugPrint(
        'ForceUpdate: appVersion=${ApiConstants.appVersion} '
        'localAppVersion=${ApiConstants.localAppVersion} remote=$remoteVersion '
        'updateRequired=${ApiConstants.localAppVersion < remoteVersion} '
        'forceLogout=$forceLogout',
      );

      return ForceUpdatePolicy(
        remoteAppVersion: remoteVersion,
        forceLogout: forceLogout,
      );
    } catch (e, stack) {
      debugPrint('ForceUpdate: fetchPolicy failed: $e\n$stack');
      return null;
    }
  }

  /// Force logout once per [ApiConstants.appVersion] when API ForceLogout is 1.
  Future<bool> shouldForceLogoutOncePerAppVersion({
    required bool forceLogout,
  }) async {
    if (!forceLogout) return false;

    const currentAppVersion = ApiConstants.appVersion;
    final doneAppVersion = await localStorage.getForceLogoutDoneAppVersion();
    final shouldLogout = doneAppVersion != currentAppVersion;

    debugPrint(
      'ForceUpdate: forceLogout check current=$currentAppVersion '
      'stored=$doneAppVersion shouldLogout=$shouldLogout',
    );

    return shouldLogout;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  Map<String, dynamic>? _firstDataItem(dynamic data) {
    if (data is List && data.isNotEmpty) {
      return _asMap(data.first);
    }
    return _asMap(data);
  }

  bool _isSuccessStatus(dynamic status) {
    if (status == 1 || status == 200) return true;
    if (status is num) {
      final code = status.toInt();
      return code == 1 || code == 200;
    }
    if (status is String) {
      final normalized = status.trim().toLowerCase();
      return normalized == '1' ||
          normalized == '200' ||
          normalized == 'success';
    }
    return false;
  }

  int? _parseRemoteAppVersion(Map<String, dynamic> item) {
    final version = item['appversion'] ??
        item['AppVersion'] ??
        item['appVersion'] ??
        item['Appversion'];
    if (version is int) return version;
    if (version is num) return version.toInt();
    if (version is String) return int.tryParse(version.trim());
    return null;
  }

  bool? _parseForceLogout(Map<String, dynamic> item) {
    final v = item['ForceLogout'] ??
        item['forceLogout'] ??
        item['force_logout'] ??
        item['FORCELOGOUT'];

    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is num) return v.toInt() == 1;
    if (v is String) {
      return v.trim() == '1' || v.trim().toLowerCase() == 'true';
    }
    return null;
  }
}
