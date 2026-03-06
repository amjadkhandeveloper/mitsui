import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/login/presentation/screens/login_screen.dart';
import '../../features/login/presentation/screens/reset_password_screen.dart';
import '../../features/login/presentation/cubit/login_cubit.dart';
import '../../features/dashboard/presentation/screens/expat_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/driver_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/about_app_screen.dart';
import '../../features/splash/data/datasources/local_storage_data_source.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/cubit/attendance_cubit.dart';
import '../../features/leave/presentation/screens/leave_list_screen.dart';
import '../../features/leave/presentation/screens/apply_leave_screen.dart';
import '../../features/leave/presentation/cubit/leave_cubit.dart';
import '../../features/vehicle_schedule/presentation/screens/vehicle_schedule_screen.dart';
import '../../features/vehicle_schedule/presentation/screens/add_free_slot_screen.dart';
import '../../features/vehicle_schedule/presentation/cubit/vehicle_schedule_cubit.dart';
import '../../features/attendance_report/presentation/screens/attendance_report_screen.dart';
import '../../features/attendance_report/presentation/cubit/attendance_report_cubit.dart';
import '../../features/trip/presentation/screens/trip_list_screen.dart';
import '../../features/trip/presentation/screens/trip_detail_screen.dart';
import '../../features/trip/presentation/cubit/trip_cubit.dart';
import '../../features/receipt/presentation/screens/receipt_history_screen.dart';
import '../../features/receipt/presentation/screens/add_receipt_screen.dart';
import '../../features/receipt/presentation/cubit/receipt_cubit.dart';
import '../../features/introduction/presentation/screens/introduction_screen.dart';
import '../../features/dashboard/presentation/screens/admin_contact_screen.dart';
import '../../features/login/domain/entities/user.dart';
import '../di/injection_container.dart' as di;

class AppRoutes {
  static const String splash = '/';
  static const String introduction = '/introduction';
  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String attendance = '/attendance';
  static const String leaveList = '/leave-list';
  static const String applyLeave = '/apply-leave';
  static const String vehicleSchedule = '/vehicle-schedule';
  static const String addFreeSlot = '/add-free-slot';
  static const String attendanceReport = '/attendance-report';
  static const String tripList = '/trips';
  static const String tripDetail = '/trip-detail';
  static const String receipts = '/receipts';
  static const String addReceipt = '/add-receipt';
  static const String adminContact = '/admin-contact';
  static const String aboutApp = '/about-app';

  static Future<String?> _getUserRole() async {
    try {
      final localStorage = di.sl<LocalStorageDataSource>();
      final role = await localStorage.getUserRole();
      return role;
    } catch (e) {
      return 'driver'; // Default to driver
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<SplashCubit>(
            create: (_) => di.sl<SplashCubit>(),
            child: const SplashScreen(),
          ),
        );
      case introduction:
        return MaterialPageRoute(
          builder: (_) => const IntroductionScreen(),
        );
      case home:
      case dashboard:
        // Determine which dashboard to show based on user role
        return MaterialPageRoute(
          builder: (_) {
            return FutureBuilder<String?>(
              future: _getUserRole(),
              builder: (context, snapshot) {
                final role = snapshot.data ?? 'driver';
                final isExpat = role == 'expat';
                
                return BlocProvider<DashboardCubit>(
                  create: (_) => di.sl<DashboardCubit>(),
                  child: isExpat 
                      ? const ExpatDashboardScreen()
                      : const DriverDashboardScreen(),
                );
              },
            );
          },
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<LoginCubit>(
            create: (_) => di.sl<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );
      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        );
      case attendance:
        final user = settings.arguments as User?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AttendanceCubit>(
            create: (_) => di.sl<AttendanceCubit>(),
            child: AttendanceScreen(currentUser: user),
          ),
        );
      case leaveList:
        final user = settings.arguments as User?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<LeaveCubit>(
            create: (_) => di.sl<LeaveCubit>(),
            child: LeaveListScreen(currentUser: user),
          ),
        );
      case applyLeave:
        final user = settings.arguments as User?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<LeaveCubit>(
            create: (_) => di.sl<LeaveCubit>(),
            child: ApplyLeaveScreen(currentUser: user),
          ),
        );
      case vehicleSchedule:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<VehicleScheduleCubit>(
                create: (_) => di.sl<VehicleScheduleCubit>(),
              ),
              BlocProvider<TripCubit>(
                create: (_) => di.sl<TripCubit>(),
              ),
            ],
            child: const VehicleScheduleScreen(),
          ),
        );
      case addFreeSlot:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<VehicleScheduleCubit>(
            create: (_) => di.sl<VehicleScheduleCubit>(),
            child: const AddFreeSlotScreen(),
          ),
        );
      case attendanceReport:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AttendanceReportCubit>(
            create: (_) => di.sl<AttendanceReportCubit>(),
            child: const AttendanceReportScreen(),
          ),
        );
      case tripList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<TripCubit>(
            create: (_) => di.sl<TripCubit>(),
            child: const TripListScreen(),
          ),
        );
      case tripDetail:
        final tripId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<TripCubit>(
            create: (_) => di.sl<TripCubit>(),
            child: TripDetailScreen(tripId: tripId),
          ),
        );
      case receipts:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReceiptCubit>(
            create: (_) => di.sl<ReceiptCubit>(),
            child: const ReceiptHistoryScreen(),
          ),
        );
      case addReceipt:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReceiptCubit>(
            create: (_) => di.sl<ReceiptCubit>(),
            child: const AddReceiptScreen(),
          ),
        );
      case adminContact:
        return MaterialPageRoute(
          builder: (_) => const AdminContactScreen(),
        );
      case aboutApp:
        return MaterialPageRoute(
          builder: (_) => const AboutAppScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
