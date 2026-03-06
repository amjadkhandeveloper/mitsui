import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/mock/mock_data_service.dart';
import '../models/attendance_record_model.dart';
import '../models/driver_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceRecordModel>> getAttendanceRecords({
    required int? driverId,
    required int? userId,
  });

  Future<List<DriverModel>> getDrivers();
  
  Future<void> approveCheckIn({
    required int attendanceId,
    required int userId,
    required String remark,
  });
  
  Future<void> approveCheckOut({
    required int attendanceId,
    required int userId,
    required String remark,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AttendanceRecordModel>> getAttendanceRecords({
    required int? driverId,
    required int? userId,
  }) async {
    // Use mock data if enabled for attendance
    if (AppConfig.USE_MOCK_DATA || AppConfig.USE_MOCK_DATA_ATTENDANCE) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return MockDataService.getMockAttendanceRecords(driverId: driverId?.toString());
    }

    try {
      final requestBody = <String, dynamic>{
        'driverId': driverId ?? 0,
        'userId': userId ?? 0,
      };

      final response = await dio.post(
        '/DriverAttendanceList',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        // Handle response with status and message fields
        final responseData = response.data;
        
        // Check if response has status and message
        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'];
          final message = responseData['message'];
          
          // Extract data array from response
          final List<dynamic> data = responseData['data'] ?? [];
          
          if (status != null &&
              status != 'success' &&
              status != 200 &&
              status != 1) {
            throw ServerException(message ?? 'Failed to fetch attendance records');
          }
          
          return data
              .map((json) => AttendanceRecordModel.fromJson(json))
              .toList();
        } else if (responseData is List) {
          // Handle case where response is directly an array
          return responseData
              .map((json) => AttendanceRecordModel.fromJson(json))
              .toList();
        } else {
          throw ServerException('Invalid response format');
        }
      } else {
        throw ServerException('Failed to fetch attendance records');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch attendance records',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
  
  @override
  Future<void> approveCheckIn({
    required int attendanceId,
    required int userId,
    required String remark,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'attendanceId': attendanceId,
        'approveType': 1, // 1 = check-in
        'approvedByUserId': userId,
        'driverId': 0,
        'remarks': remark,
      };

      final response = await dio.post(
        ApiConstants.driverAttendanceApproveStatus,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'];
          if (status != null &&
              status != 200 &&
              status != 1 &&
              status != 'success') {
            throw ServerException(responseData['message'] ?? 'Failed to approve check-in');
          }
        }
      } else {
        throw ServerException('Failed to approve check-in');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to approve check-in',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
  
  @override
  Future<void> approveCheckOut({
    required int attendanceId,
    required int userId,
    required String remark,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'attendanceId': attendanceId,
        'approveType': 2, // 2 = check-out
        'approvedByUserId': userId,
        'driverId': 0,
        'remarks': remark,
      };

      final response = await dio.post(
        ApiConstants.driverAttendanceApproveStatus,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'];
          if (status != null &&
              status != 200 &&
              status != 1 &&
              status != 'success') {
            throw ServerException(responseData['message'] ?? 'Failed to approve check-out');
          }
        }
      } else {
        throw ServerException('Failed to approve check-out');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to approve check-out',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<DriverModel>> getDrivers() async {
    // Use mock data if enabled for attendance
    if (AppConfig.USE_MOCK_DATA || AppConfig.USE_MOCK_DATA_ATTENDANCE) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return MockDataService.getMockDrivers();
    }

    try {
      final response = await dio.get('/drivers');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => DriverModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch drivers');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch drivers',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}

