import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../../features/splash/data/datasources/local_storage_data_source.dart';

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
      final loggedIn = await localStorage.isLoggedIn();
      if (!loggedIn) {
        return false;
      }

      final clientId =
          await localStorage.getClientId() ?? ApiConstants.defaultClientId;

      final response = await dio.post(
        ApiConstants.forceUpdateClient,
        data: {'clientId': clientId},
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        return false;
      }

      final status = body['status'];
      if (status != 1 && status != 200) {
        return false;
      }

      final remoteVersion = _parseRemoteAppVersion(body['data']);
      if (remoteVersion == null) {
        return false;
      }

      const localVersion = ApiConstants.localAppVersion;
      final updateRequired = localVersion < remoteVersion;

      debugPrint(
        'ForceUpdate: local=$localVersion remote=$remoteVersion '
        'required=$updateRequired',
      );

      return updateRequired;
    } catch (e, stack) {
      debugPrint('ForceUpdate: check failed silently: $e\n$stack');
      return false;
    }
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
}
