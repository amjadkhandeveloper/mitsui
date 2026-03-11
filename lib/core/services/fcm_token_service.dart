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

  Future<void> registerTokenIfNeeded({
    required String? token,
    required String appVersion,
    int? userIdOverride,
  }) async {
    final trimmed = token?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      debugPrint('FCM registerToken: skipped (token empty)');
      return;
    }

    // If we already have a valid user id (from dashboard role-based storage),
    // allow registration even if is_logged_in/auth_token isn't populated yet.
    final hasValidUserIdOverride = (userIdOverride != null && userIdOverride > 0);
    if (!hasValidUserIdOverride) {
      final loggedIn = await localStorage.isLoggedIn();
      if (!loggedIn) {
        // Fallback: some flows rely on auth token presence rather than is_logged_in flag.
        final authToken = await localStorage.getAuthToken();
        if (authToken == null || authToken.trim().isEmpty) {
          debugPrint('FCM registerToken: skipped (not logged in)');
          return;
        }
      }
    }

    final lastRegistered = await localStorage.getLastRegisteredFcmToken();
    if (lastRegistered != null && lastRegistered.trim() == trimmed) {
      debugPrint('FCM registerToken: skipped (already registered)');
      return;
    }

    String? userIdStr;
    if (userIdOverride == null) {
      userIdStr = await localStorage.getUserId();
    }
    final clientId = await localStorage.getClientId();
    final zoneId = await localStorage.getZoneId();

    final userId = userIdOverride ?? int.tryParse(userIdStr ?? '') ?? 0;
    if (userId <= 0) {
      debugPrint('FCM registerToken: skipped (userId is 0)');
      return;
    }
    final deviceId = await _getDeviceId();
    final platform = _platformString();

    final payload = {
      "clientId": clientId ?? 0,
      "zoneId": zoneId ?? 0,
      "userId": userId,
      "fcmToken": trimmed,
      "deviceId": deviceId,
      "platform": platform,
      "appVersion": appVersion,
    };

    debugPrint('FCM registerToken: calling ${ApiConstants.registerFcmToken}');
    final res = await dio.post(ApiConstants.registerFcmToken, data: payload);
    final data = res.data;
    final status = (data is Map<String, dynamic>) ? data["status"] : null;

    if (res.statusCode == 200 || status == 200) {
      await localStorage.setLastRegisteredFcmToken(trimmed);
      debugPrint('FCM registerToken: success');
    } else {
      debugPrint('FCM registerToken: failed (statusCode=${res.statusCode}, status=$status)');
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

