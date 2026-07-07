import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../../features/splash/data/datasources/local_storage_data_source.dart';

class FcmTokenService {
  final Dio dio;
  final LocalStorageDataSource localStorage;

  FcmTokenService({
    required this.dio,
    required this.localStorage,
  });

  /// Registers FCM token with backend. Pass userId and driverId based on login:
  /// - Driver login: userId = 0, driverId = actual driver id
  /// - User/Expat login: userId = actual user id, driverId = 0
  Future<void> registerTokenIfNeeded({
    required String? token,
    required String appVersion,
    int userId = 0,
    int driverId = 0,
  }) async {
    final trimmed = token?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      debugPrint('FCM registerToken: skipped (token empty)');
      return;
    }

    if (userId <= 0 && driverId <= 0) {
      final hasSession = await localStorage.hasActiveSession();
      if (!hasSession) {
        debugPrint('FCM registerToken: skipped (not logged in, no userId/driverId)');
        return;
      }
      // Fallback from storage if caller did not pass ids
      final userIdStr = await localStorage.getUserId();
      final driverIdStr = await localStorage.getDriverId();
      if ((int.tryParse(userIdStr ?? '') ?? 0) <= 0 &&
          (int.tryParse(driverIdStr ?? '') ?? 0) <= 0) {
        debugPrint('FCM registerToken: skipped (userId and driverId both 0)');
        return;
      }
    }

    final lastRegistered = await localStorage.getLastRegisteredFcmToken();
    if (lastRegistered != null && lastRegistered.trim() == trimmed) {
      debugPrint('FCM registerToken: skipped (already registered)');
      return;
    }

    final clientId = await localStorage.getClientId();
    final zoneId = await localStorage.getZoneId();

    final int payloadUserId = userId > 0 ? userId : (int.tryParse((await localStorage.getUserId()) ?? '') ?? 0);
    final int payloadDriverId = driverId > 0 ? driverId : (int.tryParse((await localStorage.getDriverId()) ?? '') ?? 0);

    if (payloadUserId <= 0 && payloadDriverId <= 0) {
      debugPrint('FCM registerToken: skipped (userId and driverId both 0)');
      return;
    }

    final deviceId = await _getDeviceId();
    final platform = _platformString();

    final payload = {
      "clientId": clientId ?? 0,
      "zoneId": zoneId ?? 0,
      "userId": payloadUserId,
      "driverId": payloadDriverId,
      "fcmToken": trimmed,
      "deviceId": deviceId,
      "platform": platform,
      "appVersion": appVersion,
    };

    debugPrint(
      'FCM registerToken: calling '
      '${ApiConstants.baseUrl}${ApiConstants.registerFcmToken} '
      'payload=$payload',
    );
    final res = await dio.post(ApiConstants.registerFcmToken, data: payload);
    final data = res.data;
    final status = (data is Map<String, dynamic>) ? data["status"] : null;

    if (res.statusCode == 200 || status == 200) {
      await localStorage.setLastRegisteredFcmToken(trimmed);
      debugPrint(
        'FCM registerToken: success '
        'url=${ApiConstants.baseUrl}${ApiConstants.registerFcmToken} '
        'statusCode=${res.statusCode} body=${res.data}',
      );
    } else {
      debugPrint(
        'FCM registerToken: failed '
        'url=${ApiConstants.baseUrl}${ApiConstants.registerFcmToken} '
        'statusCode=${res.statusCode} body=${res.data}',
      );
    }
  }

  /// Logs out FCM token on backend.
  /// Driver login: driverId set, userId = 0.
  /// User/expat login: userId set, driverId = 0.
  Future<bool> logoutFromServer({
    int userId = 0,
    int driverId = 0,
  }) async {
    try {
      final role = await localStorage.getUserRole();
      final storedUserId = int.tryParse((await localStorage.getUserId()) ?? '') ?? 0;
      final storedDriverId =
          int.tryParse((await localStorage.getDriverId()) ?? '') ?? 0;

      final int payloadUserId;
      final int payloadDriverId;

      if (userId > 0 || driverId > 0) {
        payloadUserId = userId;
        payloadDriverId = driverId;
      } else if (role == 'expat' || (storedUserId > 0 && storedDriverId <= 0)) {
        payloadUserId = storedUserId;
        payloadDriverId = 0;
      } else {
        payloadUserId = 0;
        payloadDriverId = storedDriverId;
      }

      if (payloadUserId <= 0 && payloadDriverId <= 0) {
        debugPrint('FCM logout: skipped (userId and driverId both 0)');
        return false;
      }

      final payload = {
        'driverId': payloadDriverId,
        'userId': payloadUserId,
      };

      debugPrint(
        'FCM logout: calling '
        '${ApiConstants.baseUrl}${ApiConstants.logoutFcmToken} '
        'payload=$payload',
      );

      final res = await dio.post(ApiConstants.logoutFcmToken, data: payload);
      final data = res.data;
      final status = (data is Map<String, dynamic>) ? data['status'] : null;
      final success = res.statusCode == 200 || status == 200 || status == 1;

      if (success) {
        await localStorage.setLastRegisteredFcmToken(null);
        debugPrint(
          'FCM logout: success '
          'url=${ApiConstants.baseUrl}${ApiConstants.logoutFcmToken} '
          'statusCode=${res.statusCode} body=${res.data}',
        );
      } else {
        debugPrint(
          'FCM logout: failed '
          'url=${ApiConstants.baseUrl}${ApiConstants.logoutFcmToken} '
          'statusCode=${res.statusCode} body=${res.data}',
        );
      }

      return success;
    } catch (e, stack) {
      debugPrint('FCM logout: failed: $e\n$stack');
      return false;
    }
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return (info.id).toString();
      }
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return (info.identifierForVendor ?? 'ios').toString();
      }
      if (Platform.isWindows) {
        final info = await deviceInfo.windowsInfo;
        return (info.deviceId).toString();
      }
      if (Platform.isMacOS) {
        final info = await deviceInfo.macOsInfo;
        return (info.systemGUID ?? 'macos').toString();
      }
      if (Platform.isLinux) {
        final info = await deviceInfo.linuxInfo;
        return (info.machineId ?? 'linux').toString();
      }
      return 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }

  String _platformString() {
    try {
      return Platform.operatingSystem;
    } catch (_) {
      return 'unknown';
    }
  }
}

