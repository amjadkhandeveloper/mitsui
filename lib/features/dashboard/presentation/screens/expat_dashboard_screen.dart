import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/feature_card.dart';
import '../widgets/dashboard_drawer.dart';
import '../../domain/entities/dashboard_feature.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import '../../../../core/di/injection_container.dart' as di;

class ExpatDashboardScreen extends StatefulWidget {
  const ExpatDashboardScreen({super.key});

  @override
  State<ExpatDashboardScreen> createState() => _ExpatDashboardScreenState();
}

class _ExpatDashboardScreenState extends State<ExpatDashboardScreen> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authRepository = di.sl<AuthRepository>();
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => null,
      (user) {
        if (mounted) {
          setState(() {
            currentUser = user;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'User Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      drawer: DashboardDrawer(
        userName: currentUser?.username ?? currentUser?.name ?? 'User',
        onLogout: () => _showLogoutConfirmation(context),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Expat-specific features - hide Receipts card for release and
          // place Attendance Report on the lower row.
          final expatFeatures = [
            const DashboardFeature(
              id: 'leave_management',
              title: 'Leave Request',
              subtitle: 'Manage leave requests',
              icon: Icons.event_note,
              route: '/leave-list',
            ),
            const DashboardFeature(
              id: 'driver_attendance',
              title: 'Driver Attendance',
              subtitle: 'View all attendance',
              icon: Icons.people,
              route: '/attendance',
            ),
            const DashboardFeature(
              id: 'receipts',
              title: 'Receipts',
              subtitle: 'Approve / reject',
              icon: Icons.receipt_long,
              route: '/receipts',
            ),
            const DashboardFeature(
              id: 'vehicle_schedule',
              title: 'Vehicle Schedule',
              subtitle: 'Manage schedules',
              icon: Icons.schedule,
              route: '/vehicle-schedule',
            ),
            const DashboardFeature(
              id: 'trips',
              title: 'All Trips',
              subtitle: 'View all trips',
              icon: Icons.directions_car,
              route: '/trips',
            ),
            const DashboardFeature(
              id: 'attendance_report',
              title: 'Attendance Report',
              subtitle: 'View reports',
              icon: Icons.bar_chart,
              route: '/attendance-report',
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card
                UserProfileCard(
                  userName: currentUser?.username ??
                      currentUser?.name ??
                      'Expat User',
                  userRole: currentUser?.role ?? UserRole.expat,
                ),
                const SizedBox(height: 8),
                // Features Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Management Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Feature Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.92,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: expatFeatures.length,
                        itemBuilder: (context, index) {
                          final feature = expatFeatures[index];
                          return FeatureCard(
                            feature: feature,
                            index: index,
                            onTap: () {
                              if (feature.route == AppRoutes.attendance) {
                                Navigator.pushNamed(
                                  context,
                                  feature.route,
                                  arguments: currentUser,
                                );
                              } else if (feature.route ==
                                  AppRoutes.vehicleSchedule) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route ==
                                  AppRoutes.attendanceReport) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route == AppRoutes.tripList) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route == AppRoutes.receipts) {
                                Navigator.pushNamed(context, feature.route);
                              } else if (feature.route == AppRoutes.leaveList) {
                                Navigator.pushNamed(
                                  context,
                                  feature.route,
                                  arguments: currentUser,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${feature.title} tapped'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final authRepository = di.sl<AuthRepository>();
              await authRepository.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
