/// Safe JSON parsing extensions for Map<String, dynamic>
/// Prevents null errors and handles various data type conversions
extension JsonX on Map<String, dynamic> {
  /// Safely get a String value, returns null if key doesn't exist or value is null/empty
  String? getStringSafe(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  /// Get a String with a fallback value if null/empty
  String getStringOr(String key, String fallback) {
    return getStringSafe(key) ?? fallback;
  }

  /// Safely get an int value, handles String, int, and num types
  int? getIntSafe(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return int.tryParse(trimmed);
    }
    return null;
  }

  /// Get an int with a fallback value if null
  int getIntOr(String key, int fallback) {
    return getIntSafe(key) ?? fallback;
  }

  /// Safely get a double value, handles String, double, and num types
  double? getDoubleSafe(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }

  /// Get a double with a fallback value if null
  double getDoubleOr(String key, double fallback) {
    return getDoubleSafe(key) ?? fallback;
  }

  /// Safely get a bool value, handles String, bool, and num types
  bool? getBoolSafe(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    if (value is num) return value != 0;
    return null;
  }

  /// Get a bool with a fallback value if null
  bool getBoolOr(String key, bool fallback) {
    return getBoolSafe(key) ?? fallback;
  }

  /// Safely get a DateTime value, handles various date formats
  /// Supports: ISO format, "yyyy-MM-dd HH:mm:ss", and DateTime objects
  DateTime? getDateTimeSafe(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is DateTime) return value;
    
    final str = value.toString().trim();
    if (str.isEmpty) return null;
    
    try {
      // Handle "yyyy-MM-dd HH:mm:ss" format by converting to ISO
      if (str.contains(' ') && !str.contains('T')) {
        return DateTime.parse(str.replaceFirst(' ', 'T'));
      }
      return DateTime.parse(str);
    } catch (_) {
      return null;
    }
  }

  /// Get a DateTime with a fallback value if null
  DateTime getDateTimeOr(String key, DateTime fallback) {
    return getDateTimeSafe(key) ?? fallback;
  }

  /// Safely get a List, returns empty list if null or not a list
  List<T> getListSafe<T>(String key, T Function(dynamic) converter) {
    final value = this[key];
    if (value == null) return [];
    if (value is! List) return [];
    
    try {
      return value.map((item) => converter(item)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Safely get a nested Map
  Map<String, dynamic>? getMapSafe(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  /// Get a nested Map with a fallback
  Map<String, dynamic> getMapOr(String key, Map<String, dynamic> fallback) {
    return getMapSafe(key) ?? fallback;
  }

  /// Check if a value is an empty object {} and return null if so
  /// This handles cases where API returns {} instead of null
  T? getValueOrNullIfEmptyObject<T>(String key) {
    final value = this[key];
    if (value == null) return null;
    // Check if it's an empty Map/object {}
    if (value is Map && value.isEmpty) return null;
    // If it's a Map but not empty, return null (we expect primitive types)
    if (value is Map && !value.isEmpty) return null;
    // Otherwise try to return the value as T
    try {
      return value as T?;
    } catch (_) {
      return null;
    }
  }

  /// Safely get a DateTime, handling empty objects {}
  DateTime? getDateTimeSafeOrEmptyObject(String key) {
    final value = this[key];
    if (value == null) return null;
    // Check if it's an empty Map/object {}
    if (value is Map && value.isEmpty) return null;
    // If it's a Map but not empty, return null
    if (value is Map) return null;
    // Use existing getDateTimeSafe logic
    return getDateTimeSafe(key);
  }

  /// Safely get a double, handling empty objects {}
  double? getDoubleSafeOrEmptyObject(String key) {
    final value = this[key];
    if (value == null) return null;
    // Check if it's an empty Map/object {}
    if (value is Map && value.isEmpty) return null;
    // If it's a Map but not empty, return null
    if (value is Map) return null;
    // Use existing getDoubleSafe logic
    return getDoubleSafe(key);
  }
}

