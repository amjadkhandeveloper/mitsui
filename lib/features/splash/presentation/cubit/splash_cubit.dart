import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_init_state.dart';
import '../../data/datasources/local_storage_data_source.dart';

// Splash State
class SplashState extends Equatable {
  final bool isLogoVisible;
  final bool isLoading;
  final AppInitStatus initStatus;
  final String? errorMessage;

  const SplashState({
    this.isLogoVisible = false,
    this.isLoading = false,
    this.initStatus = AppInitStatus.initial,
    this.errorMessage,
  });

  SplashState copyWith({
    bool? isLogoVisible,
    bool? isLoading,
    AppInitStatus? initStatus,
    String? errorMessage,
  }) {
    return SplashState(
      isLogoVisible: isLogoVisible ?? this.isLogoVisible,
      isLoading: isLoading ?? this.isLoading,
      initStatus: initStatus ?? this.initStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLogoVisible, isLoading, initStatus, errorMessage];
}

// Splash Cubit
class SplashCubit extends Cubit<SplashState> {
  final LocalStorageDataSource localStorageDataSource;

  SplashCubit({
    required this.localStorageDataSource,
  }) : super(const SplashState());

  /// Show logo animation
  void showLogo() {
    emit(state.copyWith(isLogoVisible: true));
  }

  /// Initialize app - check auth and load config
  Future<void> initializeApp() async {
    emit(state.copyWith(
        isLoading: true, initStatus: AppInitStatus.checkingAuth));

    try {
      // Wait for minimum splash duration (2 seconds)
      await Future.delayed(const Duration(milliseconds: 2000));

      // Check authentication token
      final authToken = await localStorageDataSource.getAuthToken();

      if (authToken != null && authToken.isNotEmpty) {
        // User is authenticated
        emit(state.copyWith(
          isLoading: false,
          initStatus: AppInitStatus.authenticated,
        ));
      } else {
        // User is not authenticated
        emit(state.copyWith(
          isLoading: false,
          initStatus: AppInitStatus.unauthenticated,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        initStatus: AppInitStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Handle timeout - navigate anyway
  void handleTimeout() {
    if (state.initStatus == AppInitStatus.checkingAuth) {
      // Default to unauthenticated if timeout occurs
      emit(state.copyWith(
        isLoading: false,
        initStatus: AppInitStatus.unauthenticated,
      ));
    }
  }
}
