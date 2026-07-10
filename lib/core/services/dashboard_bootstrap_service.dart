import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../../utils/app_globals.dart';
import '../../features/dashboard/domain/entities/dashboard_summary.dart';
import '../../features/splash/data/datasources/local_storage_data_source.dart';
import 'fcm_token_service.dart';
import 'force_update_service.dart';

/// Result of the dashboard session bootstrap (3 APIs + policy checks).
class DashboardBootstrapResult {
  final ForceUpdatePolicy? policy;
  final bool shouldForceLogout;
  final bool shouldForceUpdate;
  final DashboardSummary? dashboardSummary;
  final bool fcmAttempted;
  final bool dashboardAttempted;

  const DashboardBootstrapResult({
    this.policy,
    this.shouldForceLogout = false,
    this.shouldForceUpdate = false,
    this.dashboardSummary,
    this.fcmAttempted = false,
    this.dashboardAttempted = false,
  });

  bool get shouldBlockSession => shouldForceLogout || shouldForceUpdate;
}

/// Runs the standard dashboard startup APIs for both driver and expat users:
/// 1. ForceUpdateClient
/// 2. FcmToken RegisterToken (always, except on force logout)
/// 3. DriverDashboard (skipped when force update blocks the session)
class DashboardBootstrapService {
  final Dio dio;
  final LocalStorageDataSource localStorage;
  final FcmTokenService fcmTokenService;
  final ForceUpdateService forceUpdateService;

  DashboardBootstrapService({
    required this.dio,
    required this.localStorage,
    required this.fcmTokenService,
    required this.forceUpdateService,
  });

  /// Step 1: force-update policy.
  /// Step 2: FCM (skipped only on force logout).
  /// Step 3: dashboard (skipped when force update is required).
  Future<DashboardBootstrapResult> initializeSession() async {
    debugPrint('DashboardBootstrap: session init started');

    final hasSession = await localStorage.hasActiveSession();
    if (!hasSession) {
      debugPrint('DashboardBootstrap: skipped (no active session)');
      return const DashboardBootstrapResult();
    }

    final policy = await forceUpdateService.fetchPolicy();

    var shouldForceLogout = false;
    var shouldForceUpdate = false;

    if (policy != null) {
      shouldForceLogout =
          await forceUpdateService.shouldForceLogoutOncePerAppVersion(
        forceLogout: policy.forceLogout,
      );
      shouldForceUpdate =
          ApiConstants.localAppVersion < policy.remoteAppVersion;
    } else {
      debugPrint(
        'DashboardBootstrap: force-update policy unavailable, '
        'continuing with FCM + dashboard',
      );
    }

    if (shouldForceLogout) {
      debugPrint(
        'DashboardBootstrap: session blocked (force logout) — '
        'skipping FCM + dashboard',
      );
      return DashboardBootstrapResult(
        policy: policy,
        shouldForceLogout: true,
      );
    }

    var fcmAttempted = false;
    try {
      if (shouldForceUpdate) {
        debugPrint(
          'DashboardBootstrap: force update required — '
          'running FCM only (dashboard skipped)',
        );
      } else {
        debugPrint('DashboardBootstrap: running FCM + Dashboard APIs');
      }
      await _registerFcmToken();
      fcmAttempted = true;
    } catch (e, stack) {
      debugPrint('DashboardBootstrap: FCM init failed: $e\n$stack');
    }

    if (shouldForceUpdate) {
      debugPrint('DashboardBootstrap: session init finished (force update)');
      return DashboardBootstrapResult(
        policy: policy,
        shouldForceUpdate: true,
        fcmAttempted: fcmAttempted,
      );
    }

    DashboardSummary? summary;
    var dashboardAttempted = false;

    try {
      summary = await fetchDashboardSummary();
      dashboardAttempted = true;
    } catch (e, stack) {
      debugPrint('DashboardBootstrap: dashboard init failed: $e\n$stack');
    }

    debugPrint('DashboardBootstrap: session init finished');
    return DashboardBootstrapResult(
      policy: policy,
      dashboardSummary: summary,
      fcmAttempted: fcmAttempted,
      dashboardAttempted: dashboardAttempted,
    );
  }

  Future<void> _registerFcmToken() async {
    final role = await localStorage.getUserRole();
    final userId = int.tryParse((await localStorage.getUserId()) ?? '') ?? 0;
    final driverId =
        int.tryParse((await localStorage.getDriverId()) ?? '') ?? 0;
    final token =
        Global.fcmToken ?? await localStorage.getFcmToken();

    final isExpat = role == 'expat';

    debugPrint(
      'DashboardBootstrap: POST ${ApiConstants.registerFcmToken} '
      'role=$role userId=${isExpat ? userId : 0} '
      'driverId=${isExpat ? 0 : driverId}',
    );

    await fcmTokenService.registerTokenIfNeeded(
      token: token,
      appVersion: ApiConstants.appVersion,
      userId: isExpat ? userId : 0,
      driverId: isExpat ? 0 : driverId,
    );
  }

  /// POST /DriverDashboard — used for both driver and expat after login.
  Future<DashboardSummary?> fetchDashboardSummary() async {
    try {
      final driverId =
          int.tryParse((await localStorage.getDriverId()) ?? '') ?? 0;
      final userId = int.tryParse((await localStorage.getUserId()) ?? '') ?? 0;

      if (driverId <= 0 && userId <= 0) {
        debugPrint('DashboardBootstrap: dashboard skipped (no user/driver id)');
        return null;
      }

      debugPrint(
        'DashboardBootstrap: POST ${ApiConstants.driverDashboard} '
        'driverId=$driverId userId=$userId',
      );

      final response = await dio.post(
        ApiConstants.driverDashboard,
        data: {
          'driverId': driverId,
          'userId': userId,
        },
      );

      debugPrint(
        'DashboardBootstrap: dashboard response '
        'statusCode=${response.statusCode} body=${response.data}',
      );

      if (response.statusCode != 200) return null;
      return _parseDashboardSummary(response.data);
    } catch (e, stack) {
      debugPrint('DashboardBootstrap: dashboard failed: $e\n$stack');
      return null;
    }
  }

  DashboardSummary? _parseDashboardSummary(dynamic data) {
    final body = _asMap(data);
    if (body == null) return null;

    final list = body['data'];
    if (list is! List || list.isEmpty) return null;

    final first = _asMap(list.first);
    if (first == null) return null;

    final checkStatus = _parseInt(first['CheckStatus'] ?? first['checkStatus']);
    final odometerIn = _parseDouble(first['OdometerIN'] ?? first['odometerIn']);
    final odometerOut =
        _parseDouble(first['OdometerOUT'] ?? first['odometerOut']);

    return DashboardSummary(
      checkStatus: checkStatus,
      checkInTime: _parseDateTime(first['CheckInTime']),
      checkOutTime: _parseDateTime(first['CheckOutTime']),
      odometerIn: odometerIn,
      odometerOut: odometerOut,
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is Map && value.isEmpty) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0;
    return 0;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Map && value.isEmpty) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}
