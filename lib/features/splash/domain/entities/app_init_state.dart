import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

enum AppInitStatus {
  initial,
  checkingAuth,
  authenticated,
  unauthenticated,
  error,
}

class AppInitState extends Equatable {
  final AppInitStatus status;
  final Failure? error;
  final bool isInitialized;

  const AppInitState({
    required this.status,
    this.error,
    this.isInitialized = false,
  });

  AppInitState copyWith({
    AppInitStatus? status,
    Failure? error,
    bool? isInitialized,
  }) {
    return AppInitState(
      status: status ?? this.status,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [status, error, isInitialized];
}
