import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
