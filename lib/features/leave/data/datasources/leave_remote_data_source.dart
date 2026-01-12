import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_data_service.dart';
import '../../domain/entities/leave_request.dart';
import '../models/leave_request_model.dart';

abstract class LeaveRemoteDataSource {
  Future<List<LeaveRequestModel>> getLeaveRequests({String? userId});
  Future<LeaveRequestModel> applyLeave(Map<String, dynamic> leaveData);
  Future<LeaveRequestModel> updateLeaveStatus(
    String leaveId,
    LeaveStatus status,
    String? adminNote,
  );
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final Dio dio;

  LeaveRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LeaveRequestModel>> getLeaveRequests({String? userId}) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return MockDataService.getMockLeaveRequests(userId: userId);
    }

    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['user_id'] = userId;

      final response = await dio.get(
        '/leave-requests',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => LeaveRequestModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch leave requests');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch leave requests',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<LeaveRequestModel> applyLeave(Map<String, dynamic> leaveData) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      final now = DateTime.now();
      final startDate = DateTime.parse(leaveData['start_date']);
      final endDate = DateTime.parse(leaveData['end_date']);
      return LeaveRequestModel(
        id: 'leave_new_${now.millisecondsSinceEpoch}',
        userId: leaveData['user_id'] ?? '1',
        userName: 'John Doe',
        startDate: startDate,
        endDate: endDate,
        startTime: DateTime(startDate.year, startDate.month, startDate.day, 9, 0),
        endTime: DateTime(endDate.year, endDate.month, endDate.day, 18, 0),
        reason: leaveData['reason'] ?? '',
        status: LeaveStatus.pending,
        createdAt: now,
      );
    }

    try {
      final response = await dio.post(
        '/leave-requests',
        data: leaveData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LeaveRequestModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw ServerException('Failed to apply leave');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to apply leave',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<LeaveRequestModel> updateLeaveStatus(
    String leaveId,
    LeaveStatus status,
    String? adminNote,
  ) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      final now = DateTime.now();
      return LeaveRequestModel(
        id: leaveId,
        userId: '1',
        userName: 'John Doe',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 7)),
        startTime: DateTime(now.year, now.month, now.day + 5, 9, 0),
        endTime: DateTime(now.year, now.month, now.day + 7, 18, 0),
        reason: 'Mock leave',
        status: status,
        adminNote: adminNote,
        createdAt: now.subtract(const Duration(days: 2)),
      );
    }

    try {
      final response = await dio.patch(
        '/leave-requests/$leaveId/status',
        data: {
          'status': status.name,
          if (adminNote != null) 'admin_note': adminNote,
        },
      );

      if (response.statusCode == 200) {
        return LeaveRequestModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw ServerException('Failed to update leave status');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to update leave status',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}

