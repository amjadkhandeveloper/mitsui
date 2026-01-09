import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageDataSource {
  Future<String?> getAuthToken();
  Future<Map<String, dynamic>?> getUserPreferences();
  Future<Map<String, dynamic>?> getAppConfig();
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchComplete();
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  final SharedPreferences sharedPreferences;

  LocalStorageDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getAuthToken() async {
    try {
      return sharedPreferences.getString('auth_token');
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
}
