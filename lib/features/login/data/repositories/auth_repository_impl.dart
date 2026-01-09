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
  FutureResult<User> login(String username, String password) async {
    try {
      final userModel = await remoteDataSource.login(username, password);
      
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
      
      // Save user data
      await sharedPreferences.setString(
        'user_data',
        jsonEncode(userModel.toJson()),
      );

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
      await sharedPreferences.remove('auth_token');
      await sharedPreferences.remove('refresh_token');
      await sharedPreferences.remove('user_data');
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

