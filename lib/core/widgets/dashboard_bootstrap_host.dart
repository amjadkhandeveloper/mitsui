import 'package:flutter/material.dart';

import '../../features/dashboard/domain/entities/dashboard_summary.dart';
import '../di/injection_container.dart' as di;
import '../services/dashboard_bootstrap_service.dart';
import 'force_update_helper.dart';

/// Provides dashboard bootstrap data to child screens after session APIs complete.
class DashboardBootstrapScope extends InheritedNotifier<DashboardBootstrapController> {
  const DashboardBootstrapScope({
    super.key,
    required DashboardBootstrapController controller,
    required super.child,
  }) : super(notifier: controller);

  static DashboardBootstrapController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DashboardBootstrapScope>();
    assert(scope != null, 'DashboardBootstrapScope not found');
    return scope!.notifier!;
  }

  static DashboardBootstrapController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DashboardBootstrapScope>()
        ?.notifier;
  }
}

class DashboardBootstrapController extends ChangeNotifier {
  DashboardSummary? summary;
  bool isBootstrapping = true;

  /// Bound by [DashboardBootstrapHost]; re-runs the full fresh-load sequence
  /// (ForceUpdate -> FCM -> Dashboard), identical to opening the dashboard anew.
  Future<void> Function()? _onFullRefresh;

  void bindFullRefresh(Future<void> Function() onFullRefresh) {
    _onFullRefresh = onFullRefresh;
  }

  void setBootstrapping(bool value) {
    isBootstrapping = value;
    notifyListeners();
  }

  void setSummary(DashboardSummary? value) {
    summary = value;
    notifyListeners();
  }

  /// Re-runs the complete dashboard bootstrap (all startup APIs).
  Future<void> refresh() async {
    final callback = _onFullRefresh;
    if (callback != null) {
      await callback();
      return;
    }
    // Fallback: refresh dashboard summary only.
    await refreshDashboard();
  }

  /// Lightweight refresh of just the dashboard summary (e.g. after check-in/out).
  Future<void> refreshDashboard() async {
    final service = di.sl<DashboardBootstrapService>();
    summary = await service.fetchDashboardSummary();
    notifyListeners();
  }
}

/// Runs force-update, FCM register, and dashboard APIs once when dashboard opens.
class DashboardBootstrapHost extends StatefulWidget {
  final Widget child;

  const DashboardBootstrapHost({super.key, required this.child});

  @override
  State<DashboardBootstrapHost> createState() => _DashboardBootstrapHostState();
}

class _DashboardBootstrapHostState extends State<DashboardBootstrapHost> {
  final _controller = DashboardBootstrapController();
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller.bindFullRefresh(() => _runBootstrap(isRefresh: true));
    WidgetsBinding.instance.addPostFrameCallback((_) => _runBootstrap());
  }

  /// Runs the full startup sequence.
  /// [isRefresh] = true when triggered manually (refresh button / pull-to-refresh)
  /// so it can run again after the initial load.
  Future<void> _runBootstrap({bool isRefresh = false}) async {
    if (!isRefresh) {
      if (_started || !mounted) return;
      _started = true;
    }
    if (!mounted) return;

    if (!isRefresh) {
      _controller.setBootstrapping(true);
    }

    try {
      final service = di.sl<DashboardBootstrapService>();
      final result = await service.initializeSession();

      if (!mounted) return;

      if (result.shouldForceLogout) {
        await ForceUpdateHelper.forceLogoutFromPolicy(context);
        return;
      }

      if (result.shouldForceUpdate) {
        await ForceUpdateHelper.showForceUpdateDialog(context);
        return;
      }

      _controller.setSummary(result.dashboardSummary);
    } finally {
      if (mounted && !isRefresh) {
        _controller.setBootstrapping(false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardBootstrapScope(
      controller: _controller,
      child: widget.child,
    );
  }
}
