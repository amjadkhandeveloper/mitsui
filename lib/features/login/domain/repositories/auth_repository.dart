import '../../../../core/utils/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  FutureResult<User> login(String username, String password);
  FutureResult<void> logout();
  FutureResult<User?> getCurrentUser();
}

