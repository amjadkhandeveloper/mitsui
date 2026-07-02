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
      debugPrint('ForceUpdate: check failed silently: $e\n$stack');
      return false;
    }
  }

  Future<ForceUpdatePolicy?> fetchPolicy() async {
    final loggedIn = await localStorage.isLoggedIn();
    if (!loggedIn) {
      return null;
    }

    final clientId =
        await localStorage.getClientId() ?? ApiConstants.defaultClientId;

    final response = await dio.post(
      ApiConstants.forceUpdateClient,
      data: {'clientId': clientId},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      return null;
    }

    final status = body['status'];
    if (status != 1 && status != 200) {
      return null;
    }

    final remoteVersion = _parseRemoteAppVersion(body['data']);
    if (remoteVersion == null) {
      return null;
    }

    final forceLogout = _parseForceLogout(body['data']) ?? false;

    debugPrint(
      'ForceUpdate: local=${ApiConstants.localAppVersion} remote=$remoteVersion '
      'updateRequired=${ApiConstants.localAppVersion < remoteVersion} '
      'forceLogout=$forceLogout',
    );

    return ForceUpdatePolicy(
      remoteAppVersion: remoteVersion,
      forceLogout: forceLogout,
    );
  }

  Future<bool> shouldForceLogoutOncePerVersion({
    required int remoteAppVersion,
    required bool forceLogout,
  }) async {
    if (!forceLogout) return false;
    final alreadyDone = await localStorage.getForceLogoutDoneAppVersion();
    return alreadyDone != remoteAppVersion;
  }

  int? _parseRemoteAppVersion(dynamic data) {
    if (data is! List || data.isEmpty) {
      return null;
    }

    final first = data.first;
    if (first is! Map) {
      return null;
    }

    final version = first['appversion'] ?? first['AppVersion'] ?? first['appVersion'];
    if (version is int) {
      return version;
    }
    if (version is num) {
      return version.toInt();
    }
    if (version is String) {
      return int.tryParse(version.trim());
    }

    return null;
  }

  bool? _parseForceLogout(dynamic data) {
    if (data is! List || data.isEmpty) {
      return null;
    }

    final first = data.first;
    if (first is! Map) {
      return null;
    }

    final v = first['ForceLogout'] ??
        first['forceLogout'] ??
        first['force_logout'] ??
        first['FORCELOGOUT'];

    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is num) return v.toInt() == 1;
    if (v is String) return v.trim() == '1' || v.trim().toLowerCase() == 'true';
    return null;
  }
}
