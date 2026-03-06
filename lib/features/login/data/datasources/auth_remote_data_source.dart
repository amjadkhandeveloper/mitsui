import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password, int roleId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(
    String username,
    String password,
    int roleId,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
          'userid': 0,
          // 1 = expat, 2 = driver (as per requirement)
          'roleId': roleId,
        },
      );

      final statusCode = response.statusCode;
      final data = response.data;

      if (statusCode == 200 && data is Map<String, dynamic>) {
        final apiStatus = data['status'] as int?;
        final apiMessage = data['message'] as String?;

        if (apiStatus != 1) {
          throw ServerException(apiMessage ?? 'Login failed');
        }

        // API may return `data` as either a list (old) or a single object (new)
        final dynamic rawData = data['data'];
        Map<String, dynamic> userJson;
        if (rawData is List && rawData.isNotEmpty) {
          userJson = rawData.first as Map<String, dynamic>;
        } else if (rawData is Map<String, dynamic>) {
          userJson = rawData;
        } else {
          throw const ServerException('Invalid login response from server');
        }

        // Map API response fields to our internal UserModel JSON structure
        // Handle RoleId: expat = 4, driver = 7 (as per backend)
        final roleId = userJson['roleId']?.toString() ??
            userJson['roleid']?.toString() ??
            '';
        String roleString = 'driver'; // default
        if (roleId == '4') {
          roleString = 'expat';
        } else if (userJson['role'] != null) {
          // Fallback to role field if RoleId is not available
          final rawRole = (userJson['role'] ?? '').toString().toLowerCase();
          // Backend may send "Except" for expat users
          roleString = (rawRole == 'except' || rawRole == 'expat')
              ? 'expat'
              : 'driver';
        }
        
        // Extract clientid as int (handle various field name variations)
        int? clientId;
        if (userJson['clientid'] != null) {
          clientId = userJson['clientid'] is int 
              ? userJson['clientid'] as int
              : int.tryParse(userJson['clientid'].toString());
        } else if (userJson['clientId'] != null) {
          clientId = userJson['clientId'] is int 
              ? userJson['clientId'] as int
              : int.tryParse(userJson['clientId'].toString());
        } else if (userJson['ClientId'] != null) {
          clientId = userJson['ClientId'] is int 
              ? userJson['ClientId'] as int
              : int.tryParse(userJson['ClientId'].toString());
        }

        // Extract ZoneId as int (handle various field name variations)
        int? zoneId;
        if (userJson['zoneid'] != null) {
          zoneId = userJson['zoneid'] is int
              ? userJson['zoneid'] as int
              : int.tryParse(userJson['zoneid'].toString());
        } else if (userJson['zoneId'] != null) {
          zoneId = userJson['zoneId'] is int
              ? userJson['zoneId'] as int
              : int.tryParse(userJson['zoneId'].toString());
        } else if (userJson['ZoneId'] != null) {
          zoneId = userJson['ZoneId'] is int
              ? userJson['ZoneId'] as int
              : int.tryParse(userJson['ZoneId'].toString());
        }
        
        final mappedJson = <String, dynamic>{
          'id': (userJson['userid'] ?? '').toString(),
          // Map backend driverid separately so we can use it for driver flows
          'driverId': (userJson['driverid'] ?? userJson['driverId'] ?? '').toString(),
          'username': userJson['username'] ?? '',
          'email': userJson['email'] ?? '',
          'token': userJson['token'] ?? '',
          'refreshToken': userJson['refresh_token'] ?? '',
          'role': roleString,
          'name': userJson['name'] ?? '',
          'clientId': clientId,
          'zoneId': zoneId,
        };

        return UserModel.fromJson(mappedJson);
      }

      throw const ServerException('Login failed');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Login failed',
        );
      } else {
        print(e.toString());
        throw const NetworkException('Network error occurred');
      }
    }
  }
}

