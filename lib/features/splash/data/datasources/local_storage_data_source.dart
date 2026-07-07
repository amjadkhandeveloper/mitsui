import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageDataSource {
  Future<String?> getAuthToken();
  Future<bool> isLoggedIn();
  /// True when user completed login (flag + user/driver id), even if auth token is empty.
  Future<bool> hasActiveSession();
  // User data getters
  Future<String?> getUserId();
  Future<String?> getDriverId();
  Future<String?> getUsername();
  Future<String?> getUserEmail();
  Future<String?> getUserToken();
  Future<String?> getUserRole();
  Future<String?> getUserName();
  Future<int?> getClientId();
   Future<int?> getZoneId();
  Future<Map<String, dynamic>?> getUserPreferences();
  Future<Map<String, dynamic>?> getAppConfig();
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchComplete();
  Future<bool> isIntroductionCompleted();
  Future<void> setIntroductionCompleted();
  // Saved login credentials for auto-login
  Future<void> saveLoginCredentials(String username, String password);
  Future<Map<String, String>?> getSavedLoginCredentials();
  Future<void> clearSavedLoginCredentials();

  // FCM token
  Future<String?> getFcmToken();
  Future<void> setFcmToken(String? token);
  Future<String?> getLastRegisteredFcmToken();
  Future<void> setLastRegisteredFcmToken(String? token);

  // Force logout tracking (per app release version string, e.g. 1.0.1)
  Future<String?> getForceLogoutDoneAppVersion();
  Future<void> setForceLogoutDoneAppVersion(String? appVersion);
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  final SharedPreferences sharedPreferences;

  LocalStorageDataSourceImpl({required this.sharedPreferences});

  static const String _kForceLogoutDoneAppVersion = 'force_logout_done_app_version';

  @override
  Future<String?> getAuthToken() async {
    try {
      return sharedPreferences.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = sharedPreferences.getBool('is_logged_in');
      final authToken = sharedPreferences.getString('auth_token');
      // Check both login status flag and auth token for reliability
      return (isLoggedIn == true) && (authToken != null && authToken.isNotEmpty);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasActiveSession() async {
    try {
      if (await isLoggedIn()) return true;

      final loggedInFlag = sharedPreferences.getBool('is_logged_in');
      if (loggedInFlag != true) return false;

      final userId = sharedPreferences.getString('userid');
      final driverId = sharedPreferences.getString('driverid');
      final hasUserId = userId != null && userId.trim().isNotEmpty;
      final hasDriverId = driverId != null && driverId.trim().isNotEmpty;
      return hasUserId || hasDriverId;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return sharedPreferences.getString('userid');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getDriverId() async {
    try {
      return sharedPreferences.getString('driverid');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getUsername() async {
    try {
      return sharedPreferences.getString('username');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getUserEmail() async {
    try {
      return sharedPreferences.getString('email');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getUserToken() async {
    try {
      return sharedPreferences.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getUserRole() async {
    try {
      return sharedPreferences.getString('role');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getUserName() async {
    try {
      return sharedPreferences.getString('name');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int?> getClientId() async {
    try {
      return sharedPreferences.getInt('clientid');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int?> getZoneId() async {
    try {
      return sharedPreferences.getInt('zoneid');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final prefsJson = sharedPreferences.getString('user_preferences');
      if (prefsJson != null) {
        return jsonDecode(prefsJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getAppConfig() async {
    try {
      final configJson = sharedPreferences.getString('app_config');
      if (configJson != null) {
        return jsonDecode(configJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      final value = sharedPreferences.getBool('first_launch_complete');
      return value == null || value == false;
    } catch (e) {
      return true;
    }
  }

  @override
  Future<void> setFirstLaunchComplete() async {
    try {
      await sharedPreferences.setBool('first_launch_complete', true);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<bool> isIntroductionCompleted() async {
    try {
      final value = sharedPreferences.getBool('introduction_completed');
      return value == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setIntroductionCompleted() async {
    try {
      await sharedPreferences.setBool('introduction_completed', true);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> saveLoginCredentials(String username, String password) async {
    try {
      // Store username and password for auto-login
      // Note: In production, password should be encrypted
      await sharedPreferences.setString('saved_username', username);
      await sharedPreferences.setString('saved_password', password);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<Map<String, String>?> getSavedLoginCredentials() async {
    try {
      final username = sharedPreferences.getString('saved_username');
      final password = sharedPreferences.getString('saved_password');
      if (username != null && password != null && username.isNotEmpty && password.isNotEmpty) {
        return {
          'username': username,
          'password': password,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearSavedLoginCredentials() async {
    try {
      await sharedPreferences.remove('saved_username');
      await sharedPreferences.remove('saved_password');
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<String?> getFcmToken() async {
    try {
      return sharedPreferences.getString('fcm_token');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setFcmToken(String? token) async {
    try {
      if (token == null || token.trim().isEmpty) {
        await sharedPreferences.remove('fcm_token');
      } else {
        await sharedPreferences.setString('fcm_token', token.trim());
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Future<String?> getLastRegisteredFcmToken() async {
    try {
      return sharedPreferences.getString('last_registered_fcm_token');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setLastRegisteredFcmToken(String? token) async {
    try {
      if (token == null || token.trim().isEmpty) {
        await sharedPreferences.remove('last_registered_fcm_token');
      } else {
        await sharedPreferences.setString('last_registered_fcm_token', token.trim());
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Future<String?> getForceLogoutDoneAppVersion() async {
    try {
      final stored = sharedPreferences.getString(_kForceLogoutDoneAppVersion);
      if (stored != null && stored.trim().isNotEmpty) {
        return stored.trim();
      }
      // Legacy: previously stored as int appversion — ignore for string-based tracking.
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setForceLogoutDoneAppVersion(String? appVersion) async {
    try {
      if (appVersion == null || appVersion.trim().isEmpty) {
        await sharedPreferences.remove(_kForceLogoutDoneAppVersion);
        return;
      }
      await sharedPreferences.setString(
        _kForceLogoutDoneAppVersion,
        appVersion.trim(),
      );
    } catch (_) {
      // ignore
    }
  }
}
