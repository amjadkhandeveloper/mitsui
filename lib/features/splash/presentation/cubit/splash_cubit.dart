import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_init_state.dart';
import '../../data/datasources/local_storage_data_source.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../../core/di/injection_container.dart' as di;

// Splash State
class SplashState extends Equatable {
  final bool isLoading;
  final AppInitStatus initStatus;
  final String? errorMessage;

  const SplashState({
    this.isLoading = false,
    this.initStatus = AppInitStatus.initial,
    this.errorMessage,
  });

  SplashState copyWith({
    bool? isLoading,
    AppInitStatus? initStatus,
    String? errorMessage,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      initStatus: initStatus ?? this.initStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, initStatus, errorMessage];
}

// Splash Cubit
class SplashCubit extends Cubit<SplashState> {
  final LocalStorageDataSource localStorageDataSource;

  SplashCubit({
    required this.localStorageDataSource,
  }) : super(const SplashState());

  /// Initialize app - check auth and load config
  Future<void> initializeApp() async {
    emit(state.copyWith(
        isLoading: true, initStatus: AppInitStatus.checkingAuth));

    try {
      // Brief delay so native splash transitions smoothly into Flutter UI
      await Future.delayed(const Duration(milliseconds: 800));

      // Check if introduction is completed
      final isIntroductionCompleted = await localStorageDataSource.isIntroductionCompleted();

      if (!isIntroductionCompleted) {
        // Show introduction screens on first launch
        emit(state.copyWith(
          isLoading: false,
          initStatus: AppInitStatus.showIntroduction,
        ));
        return;
      }

      // Check login status
      final isLoggedIn = await localStorageDataSource.isLoggedIn();

      if (isLoggedIn) {
        // User is authenticated - check if token is valid
        final token = await localStorageDataSource.getAuthToken();
        if (token != null && token.isNotEmpty) {
          // Token exists, user is authenticated
          emit(state.copyWith(
            isLoading: false,
            initStatus: AppInitStatus.authenticated,
          ));
        } else {
          // Token is missing, try auto-login with saved credentials
          await _attemptAutoLogin();
        }
      } else {
        // User is not authenticated - try auto-login with saved credentials
        await _attemptAutoLogin();
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        initStatus: AppInitStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Attempt auto-login with saved credentials
  Future<void> _attemptAutoLogin() async {
    try {
      // Get saved login credentials
      final savedCredentials = await localStorageDataSource.getSavedLoginCredentials();
      
      if (savedCredentials != null && 
          savedCredentials['username'] != null && 
          savedCredentials['password'] != null) {
        // Attempt auto-login (bounded so splash cannot hang indefinitely)
        final authRepository = di.sl<AuthRepository>();
        final result = await authRepository
            .login(
              savedCredentials['username']!,
              savedCredentials['password']!,
            )
            .timeout(const Duration(seconds: 15));
        
        result.fold(
          (failure) {
            // Auto-login failed, go to login screen
            emit(state.copyWith(
              isLoading: false,
              initStatus: AppInitStatus.unauthenticated,
            ));
          },
          (user) {
            // Auto-login successful
            emit(state.copyWith(
              isLoading: false,
              initStatus: AppInitStatus.authenticated,
            ));
          },
        );
      } else {
        // No saved credentials, go to login screen
        emit(state.copyWith(
          isLoading: false,
          initStatus: AppInitStatus.unauthenticated,
        ));
      }
    } on TimeoutException {
      emit(state.copyWith(
        isLoading: false,
        initStatus: AppInitStatus.unauthenticated,
      ));
    } catch (e) {
      // Error during auto-login, go to login screen
      emit(state.copyWith(
        isLoading: false,
        initStatus: AppInitStatus.unauthenticated,
      ));
    }
  }

  /// Handle timeout - navigate anyway
  void handleTimeout() {
    if (state.initStatus == AppInitStatus.initial ||
        state.initStatus == AppInitStatus.checkingAuth) {
      // Default to unauthenticated if timeout occurs
      emit(state.copyWith(
        isLoading: false,
        initStatus: AppInitStatus.unauthenticated,
      ));
    }
  }
}
