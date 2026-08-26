import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_feature.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final String? userName;
  final List<DashboardFeature> features;

  const DashboardState({
    this.isLoading = false,
    this.userName,
    this.features = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? userName,
    List<DashboardFeature>? features,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      features: features ?? this.features,
    );
  }

  @override
  List<Object?> get props => [isLoading, userName, features];
}

/// Builds the static feature-card list. User name is still a placeholder.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState()) {
    _initializeDashboard();
  }

  void _initializeDashboard() {
    emit(state.copyWith(isLoading: true));

    // Placeholder — screens load the real name from LocalStorage / AuthRepository.
    final userName = 'LOKESH PUJARI';

    // Initialize features (hide Receipt card for release)
    final features = [
      const DashboardFeature(
        id: 'vehicle_schedule',
        title: 'Vehicle Schedule',
        subtitle: 'View calendar',
        icon: Icons.schedule,
        route: '/vehicle-schedule',
      ),
      const DashboardFeature(
        id: 'driver_attendance',
        title: 'Driver Attendance',
        subtitle: 'View details',
        icon: Icons.people,
        route: '/attendance',
      ),
      const DashboardFeature(
        id: 'trips',
        title: 'Trips',
        subtitle: 'Create or manage trip',
        icon: Icons.directions_car,
        route: '/trips',
      ),
      const DashboardFeature(
        id: 'trip_history',
        title: 'Trip History',
        subtitle: 'View history',
        icon: Icons.history,
        route: '/trip-history',
      ),
      const DashboardFeature(
        id: 'reports',
        title: 'Reports',
        subtitle: 'View reports',
        icon: Icons.bar_chart,
        route: '/attendance-report',
      ),
    ];

    emit(state.copyWith(
      isLoading: false,
      userName: userName,
      features: features,
    ));
  }

  void logout() {
    // Handle logout logic
    // Navigate to login screen
  }
}
