import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageDataSource {
  Future<String?> getAuthToken();
  Future<bool> isLoggedIn();
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
}
