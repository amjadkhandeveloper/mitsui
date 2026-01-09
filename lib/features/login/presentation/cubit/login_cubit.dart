import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/entities/user.dart';

// Login State
class LoginState extends Equatable {
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final User? user;

  const LoginState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    User? user,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [isLoading, isPasswordVisible, errorMessage, user];
}

// Login Cubit
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit({required this.loginUseCase}) : super(const LoginState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please enter both username and password',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await loginUseCase(LoginParams(
      username: username,
      password: password,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (user) {
        emit(state.copyWith(
          isLoading: false,
          user: user,
          errorMessage: null,
        ));
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
