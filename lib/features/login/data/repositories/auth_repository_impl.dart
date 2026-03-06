import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  FutureResult<User> login(String username, String password, [int? selectedRoleId]) async {
    try {
      // Determine effective roleId to send to API
      // UI passes 1 (expat) or 2 (driver). If null (e.g. auto-login), infer from stored data.
      int effectiveRoleId;
      if (selectedRoleId != null) {
        effectiveRoleId = selectedRoleId;
      } else {
        // Try to infer from stored roleid (4 = expat, 7 = driver)
        final storedRoleId = sharedPreferences.getString('roleid');
        if (storedRoleId == '4') {
          effectiveRoleId = 1; // expat
        } else if (storedRoleId == '7') {
          effectiveRoleId = 2; // driver
        } else {
          // Fallback to stored role string
          final storedRole = sharedPreferences.getString('role');
          if (storedRole == 'expat') {
            effectiveRoleId = 1;
          } else {
            effectiveRoleId = 2; // default to driver
          }
        }
      }

      final userModel = await remoteDataSource.login(
        username,
        password,
        effectiveRoleId,
      );
      
      // Save token to local storage
      if (userModel.token != null) {
        await sharedPreferences.setString('auth_token', userModel.token!);
      }
      if (userModel.refreshToken != null) {
        await sharedPreferences.setString(
          'refresh_token',
          userModel.refreshToken!,
        );
      }
      
      // Save individual user fields for easy access
      await sharedPreferences.setString('userid', userModel.id);
      // Store driverid separately when available (driver login)
      if (userModel.driverId != null && userModel.driverId!.isNotEmpty) {
        await sharedPreferences.setString('driverid', userModel.driverId!);
      }
      await sharedPreferences.setString('username', userModel.username);
      await sharedPreferences.setString('email', userModel.email);
      await sharedPreferences.setString('role', userModel.role.toString().split('.').last); // Convert enum to string
      // Store RoleId: expat = 4 (from API), driver = 7 (from API)
      // If role is expat, store '4', otherwise store '7' (or check user_data JSON for actual roleId)
      final storedApiRoleId = userModel.role == UserRole.expat ? '4' : '7';
      await sharedPreferences.setString('roleid', storedApiRoleId);
      if (userModel.name != null) {
        await sharedPreferences.setString('name', userModel.name!);
      }
      // Store clientid as int
      if (userModel.clientId != null) {
        await sharedPreferences.setInt('clientid', userModel.clientId!);
      }
      // Store zoneid as int (if provided by backend)
      if (userModel.zoneId != null) {
        await sharedPreferences.setInt('zoneid', userModel.zoneId!);
      }
      
      // Save user data as JSON for backward compatibility
      await sharedPreferences.setString(
        'user_data',
        jsonEncode(userModel.toJson()),
      );

      // Save login status
      await sharedPreferences.setBool('is_logged_in', true);
      
      // Save login credentials for auto-login
      // Note: In production, password should be encrypted before storing
      await sharedPreferences.setString('saved_username', username);
      await sharedPreferences.setString('saved_password', password);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<void> logout() async {
    try {
      // Remove tokens
      await sharedPreferences.remove('auth_token');
      await sharedPreferences.remove('refresh_token');
      
      // Remove individual user fields
      await sharedPreferences.remove('userid');
      await sharedPreferences.remove('driverid');
      await sharedPreferences.remove('username');
      await sharedPreferences.remove('email');
      await sharedPreferences.remove('role');
      await sharedPreferences.remove('roleid');
      await sharedPreferences.remove('name');
      await sharedPreferences.remove('clientid');
      
      // Remove user data JSON
      await sharedPreferences.remove('user_data');
      
      // Clear saved login credentials
      await sharedPreferences.remove('saved_username');
      await sharedPreferences.remove('saved_password');
      
      // Clear login status
      await sharedPreferences.setBool('is_logged_in', false);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout: $e'));
    }
  }

  @override
  FutureResult<User?> getCurrentUser() async {
    try {
      final userDataJson = sharedPreferences.getString('user_data');
      if (userDataJson != null) {
        final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
        final userModel = UserModel.fromJson(userData);
        return Right(userModel.toEntity());
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to get current user: $e'));
    }
  }
}

