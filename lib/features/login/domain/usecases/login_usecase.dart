import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  FutureResult<User> call(LoginParams params) async {
    return await repository.login(
      params.username,
      params.password,
      params.roleId,
    );
  }
}

class LoginParams {
  final String username;
  final String password;
  /// UI value sent to UserLogin: `1` = expat, `2` = driver.
  /// Distinct from stored API RoleId (`4` / `7`).
  final int roleId;

  LoginParams({
    required this.username,
    required this.password,
    required this.roleId,
  });
}


