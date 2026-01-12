import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/repository_impl.dart';
import '../../domain/repositories/repository.dart';
import '../../features/splash/data/datasources/local_storage_data_source.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/login/data/datasources/auth_remote_data_source.dart';
import '../../features/login/data/repositories/auth_repository_impl.dart';
import '../../features/login/domain/repositories/auth_repository.dart';
import '../../features/login/domain/usecases/login_usecase.dart';
import '../../features/login/presentation/cubit/login_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/attendance/data/datasources/attendance_remote_data_source.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/get_attendance_records_usecase.dart';
import '../../features/attendance/domain/usecases/get_drivers_usecase.dart';
import '../../features/attendance/presentation/cubit/attendance_cubit.dart';
import '../../features/leave/data/datasources/leave_remote_data_source.dart';
import '../../features/leave/data/repositories/leave_repository_impl.dart';
import '../../features/leave/domain/repositories/leave_repository.dart';
import '../../features/leave/domain/usecases/get_leave_requests_usecase.dart';
import '../../features/leave/domain/usecases/apply_leave_usecase.dart';
import '../../features/leave/domain/usecases/update_leave_status_usecase.dart';
import '../../features/leave/presentation/cubit/leave_cubit.dart';
import '../../features/vehicle_schedule/data/datasources/vehicle_schedule_remote_data_source.dart';
import '../../features/vehicle_schedule/data/repositories/vehicle_schedule_repository_impl.dart';
import '../../features/vehicle_schedule/domain/repositories/vehicle_schedule_repository.dart';
import '../../features/vehicle_schedule/domain/usecases/get_trips_usecase.dart';
import '../../features/vehicle_schedule/domain/usecases/update_trip_status_usecase.dart';
import '../../features/vehicle_schedule/domain/usecases/create_free_slot_usecase.dart';
import '../../features/vehicle_schedule/presentation/cubit/vehicle_schedule_cubit.dart';
import '../../features/attendance_report/data/datasources/attendance_report_remote_data_source.dart';
import '../../features/attendance_report/data/repositories/attendance_report_repository_impl.dart';
import '../../features/attendance_report/domain/repositories/attendance_report_repository.dart';
import '../../features/attendance_report/domain/usecases/get_attendance_report_usecase.dart';
import '../../features/attendance_report/presentation/cubit/attendance_report_cubit.dart';
import '../../features/trip/data/datasources/trip_remote_data_source.dart';
import '../../features/trip/data/repositories/trip_repository_impl.dart';
import '../../features/trip/domain/repositories/trip_repository.dart';
import '../../features/trip/domain/usecases/get_trips_usecase.dart'
    as trip_usecase;
import '../../features/trip/domain/usecases/get_trip_detail_usecase.dart';
import '../../features/trip/domain/usecases/start_trip_usecase.dart';
import '../../features/trip/domain/usecases/end_trip_usecase.dart';
import '../../features/trip/presentation/cubit/trip_cubit.dart';
import '../../features/receipt/data/datasources/receipt_remote_data_source.dart';
import '../../features/receipt/data/repositories/receipt_repository_impl.dart';
import '../../features/receipt/domain/repositories/receipt_repository.dart';
import '../../features/receipt/domain/usecases/get_receipts_usecase.dart';
import '../../features/receipt/domain/usecases/create_receipt_usecase.dart';
import '../../features/receipt/presentation/cubit/receipt_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External - SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  //! Features - Register your features here

  //! Splash Feature
  sl.registerFactory<LocalStorageDataSource>(
    () =>
        LocalStorageDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(localStorageDataSource: sl<LocalStorageDataSource>()),
  );

  //! Login Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => LoginCubit(loginUseCase: sl<LoginUseCase>()));

  //! Dashboard Feature
  sl.registerFactory(() => DashboardCubit());

  //! Attendance Feature
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl<AttendanceRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetAttendanceRecordsUseCase(repository: sl<AttendanceRepository>()),
  );
  sl.registerLazySingleton(
    () => GetDriversUseCase(repository: sl<AttendanceRepository>()),
  );
  sl.registerFactory(
    () => AttendanceCubit(
      getAttendanceRecordsUseCase: sl<GetAttendanceRecordsUseCase>(),
      getDriversUseCase: sl<GetDriversUseCase>(),
    ),
  );

  //! Leave Feature
  sl.registerLazySingleton<LeaveRemoteDataSource>(
    () => LeaveRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<LeaveRepository>(
    () => LeaveRepositoryImpl(
      remoteDataSource: sl<LeaveRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetLeaveRequestsUseCase(repository: sl<LeaveRepository>()),
  );
  sl.registerLazySingleton(
    () => ApplyLeaveUseCase(repository: sl<LeaveRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateLeaveStatusUseCase(repository: sl<LeaveRepository>()),
  );
  sl.registerFactory(
    () => LeaveCubit(
      getLeaveRequestsUseCase: sl<GetLeaveRequestsUseCase>(),
      applyLeaveUseCase: sl<ApplyLeaveUseCase>(),
      updateLeaveStatusUseCase: sl<UpdateLeaveStatusUseCase>(),
    ),
  );

  //! Vehicle Schedule Feature
  sl.registerLazySingleton<VehicleScheduleRemoteDataSource>(
    () => VehicleScheduleRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<VehicleScheduleRepository>(
    () => VehicleScheduleRepositoryImpl(
      remoteDataSource: sl<VehicleScheduleRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetTripsUseCase(repository: sl<VehicleScheduleRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateTripStatusUseCase(repository: sl<VehicleScheduleRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateFreeSlotUseCase(repository: sl<VehicleScheduleRepository>()),
  );
  sl.registerFactory(
    () => VehicleScheduleCubit(
      getTripsUseCase: sl<GetTripsUseCase>(),
      updateTripStatusUseCase: sl<UpdateTripStatusUseCase>(),
      createFreeSlotUseCase: sl<CreateFreeSlotUseCase>(),
    ),
  );

  //! Attendance Report Feature
  sl.registerLazySingleton<AttendanceReportRemoteDataSource>(
    () => AttendanceReportRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AttendanceReportRepository>(
    () => AttendanceReportRepositoryImpl(
      remoteDataSource: sl<AttendanceReportRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetAttendanceReportUseCase(
      repository: sl<AttendanceReportRepository>(),
    ),
  );
  sl.registerFactory(
    () => AttendanceReportCubit(
      getAttendanceReportUseCase: sl<GetAttendanceReportUseCase>(),
    ),
  );

  //! Trip Feature
  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(
      remoteDataSource: sl<TripRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => trip_usecase.GetTripDetailsUseCase(repository: sl<TripRepository>()),
  );
  sl.registerLazySingleton(
    () => GetTripDetailUseCase(repository: sl<TripRepository>()),
  );
  sl.registerLazySingleton(
    () => StartTripUseCase(repository: sl<TripRepository>()),
  );
  sl.registerLazySingleton(
    () => EndTripUseCase(repository: sl<TripRepository>()),
  );
  sl.registerFactory(
    () => TripCubit(
      getTripsUseCase: sl<trip_usecase.GetTripDetailsUseCase>(),
      getTripDetailUseCase: sl<GetTripDetailUseCase>(),
      startTripUseCase: sl<StartTripUseCase>(),
      endTripUseCase: sl<EndTripUseCase>(),
    ),
  );

  //! Receipt Feature
  sl.registerLazySingleton<ReceiptRemoteDataSource>(
    () => ReceiptRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ReceiptRepository>(
    () => ReceiptRepositoryImpl(
      remoteDataSource: sl<ReceiptRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetReceiptsUseCase(repository: sl<ReceiptRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateReceiptUseCase(repository: sl<ReceiptRepository>()),
  );
  sl.registerFactory(
    () => ReceiptCubit(
      getReceiptsUseCase: sl<GetReceiptsUseCase>(),
      createReceiptUseCase: sl<CreateReceiptUseCase>(),
    ),
  );

  //! Core
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Dio>()));

  //! Data sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(),
  );

  //! Repository
  sl.registerLazySingleton<Repository>(
    () => RepositoryImpl(
      networkInfo: sl<NetworkInfo>(),
      // remoteDataSource: sl<RemoteDataSource>(),
      // localDataSource: sl<LocalDataSource>(),
    ),
  );

  //! Use cases - Register your use cases here
  // sl.registerLazySingleton(() => GetUserUseCase(sl<Repository>()));

  //! Bloc - Register your BLoCs/Cubits here
  // sl.registerFactory(() => UserCubit(sl<GetUserUseCase>()));
}
