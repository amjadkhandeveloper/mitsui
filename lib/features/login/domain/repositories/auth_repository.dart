import '../../../../core/utils/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  // [roleId] is optional:
  // 1 = expat, 2 = driver. If null, repository will infer from stored role info.
  FutureResult<User> login(String username, String password, [int? roleId]);
  FutureResult<void> logout();
  FutureResult<User?> getCurrentUser();
}

