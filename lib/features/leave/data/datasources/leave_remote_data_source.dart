import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/extensions/json_extensions.dart';
import '../../../../core/mock/mock_data_service.dart';
import '../../domain/entities/leave_request.dart';
import '../models/leave_request_model.dart';
import '../models/leave_type_model.dart';

abstract class LeaveRemoteDataSource {
  Future<List<LeaveRequestModel>> getLeaveRequests({String? userId, String? driverId});
  Future<String> applyLeave(Map<String, dynamic> leaveData);
  Future<String> updateLeaveStatus({
    required LeaveRequest request,
    required LeaveStatus status,
    required String currentUserId,
    String? remark,
    int? clientId,
  });
  Future<List<LeaveTypeModel>> getLeaveTypes();
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final Dio dio;

  LeaveRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LeaveRequestModel>> getLeaveRequests({String? userId, String? driverId}) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return MockDataService.getMockLeaveRequests(userId: userId);
    }

    try {
      // Build request body for LeaveList API
      // - Driver login: send driverId=<login userId>, userId=<login userId> (both same)
      // - Expat login:  send driverId=0, userId=<login userId>
      // - If both missing: driverId=0, userId=0 (admin/all)
      final parsedUserId = userId != null ? int.tryParse(userId) ?? 0 : 0;
      final parsedDriverId = driverId != null ? int.tryParse(driverId) ?? 0 : 0;
      
      // For driver login: driverId and userId are both the login userId
      // For expat login: driverId=0, userId=login userId
      final requestBody = <String, dynamic>{
        'driverId': parsedDriverId,
        'userId': parsedUserId,
      };

      final response = await dio.post(
        ApiConstants.leaveList,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Expected format:
        // {
        //   "status": 200,
        //   "message": "successfully",
        //   "data": [ { ... } ]
        // }
        if (responseData is! Map<String, dynamic>) {
          throw ServerException('Invalid response format for leave list');
        }

        final apiStatus = responseData['status'];
        final apiMessage = responseData['message'] as String?;

        if ((apiStatus == 200 || apiStatus == 1 || apiStatus == 'success') &&
            responseData['data'] != null) {
          final List<dynamic> data = responseData['data'] is List
              ? responseData['data'] as List<dynamic>
              : [responseData['data']];

          return data.map((raw) {
            final json = raw as Map<String, dynamic>;

            // Example payload:
            // {
            //   "LeaveRequestId": 1,
            //   "Driver Name": "Raman dvr",
            //   "LeaveType": "Full Day",
            //   "LeaveFromDate": "2026-02-20T09:00:00",
            //   "StartTime": "09:00:00",
            //   "LeaveToDate": "2026-02-20T18:00:00",
            //   "EndTime": "18:00:00",
            //   "LeaveReason": "personal",
            //   "LeaveStatus": "Leave Requested",
            //   "RequestedBy": "commandcentre",
            //   "RequestedDateTime": "2026-02-19T15:20:31.227",
            //   "ApprovedBy": "",
            //   "ApproverName": "",
            //   "ApprovedDateTime": "1900-01-01T00:00:00",
            //   "DriverID": 31,
            //   "LeaveTypeId": 1,
            //   "LeaveStatusId": 1,
            //   "Remark": ""
            // }

            final leaveRequestId = json.getIntSafe('LeaveRequestId') ?? 0;
            final driverId = json.getIntSafe('DriverID') ?? 0;
            final driverName = json.getStringSafe('Driver Name') ?? '';

            final fromDate = json.getDateTimeSafe('LeaveFromDate') ?? DateTime.now();
            final toDate = json.getDateTimeSafe('LeaveToDate') ?? fromDate;

            final fromDateStr = fromDate.toIso8601String();
            final toDateStr = toDate.toIso8601String();

            final startTimeRaw = json.getStringSafe('StartTime') ?? '09:00:00';
            final endTimeRaw = json.getStringSafe('EndTime') ?? '18:00:00';

            // Map leave status string to our enum string values
            final statusStrRaw = (json.getStringSafe('LeaveStatus') ?? '').toLowerCase();
            String statusEnumString;
            if (statusStrRaw.contains('approved')) {
              statusEnumString = 'approved';
            } else if (statusStrRaw.contains('rejected')) {
              statusEnumString = 'rejected';
            } else {
              // "Leave Requested" and others → pending
              statusEnumString = 'pending';
            }

            // Map leave type text to enum string
            final leaveTypeRaw = (json.getStringSafe('LeaveType') ?? '').toLowerCase();
            String? leaveTypeEnumString;
            if (leaveTypeRaw.contains('half')) {
              leaveTypeEnumString = 'half';
            } else if (leaveTypeRaw.contains('full')) {
              leaveTypeEnumString = 'full';
            }

            final createdAtStr =
                json.getStringSafe('RequestedDateTime') ?? fromDateStr;

            final approvedDateStr = json.getStringSafe('ApprovedDateTime');
            // Treat 1900-01-01 as "no update"
            final updatedAtStr = (approvedDateStr != null &&
                    !approvedDateStr.startsWith('1900-01-01'))
                ? approvedDateStr
                : null;

            // Build JSON exactly in the shape LeaveRequestModelFromJson expects
            final normalized = <String, dynamic>{
              // Required fields
              'id': leaveRequestId.toString(),
              'userId': driverId.toString(),
              'userName': driverName,
              'startDate': fromDateStr,
              'endDate': toDateStr,
              // Use the full DateTime for startTime/endTime as well
              'startTime': fromDateStr,
              'endTime': toDateStr,

              // Optional mapping
              'leaveTypeId': json.getIntSafe('LeaveTypeId'),

              // Raw values for display (times from API)
              'rawLeaveDate': fromDateStr,
              'rawStartTime': startTimeRaw,
              'rawEndTime': endTimeRaw,

              // Status & type enums as strings
              'status': statusEnumString,
              if (leaveTypeEnumString != null) 'leaveType': leaveTypeEnumString,

              // Reason / remarks / document
              'reason': json.getStringSafe('LeaveReason'),
              'remark': json.getStringSafe('Remark'),
              'adminNote': json.getStringSafe('ApproverName'),
              'documentUrl': json.getStringSafe('Document') ?? json.getStringSafe('DocumentUrl'),

              // Created / updated timestamps
              'createdAt': createdAtStr,
              'updatedAt': updatedAtStr,
            };

            return LeaveRequestModel.fromJson(normalized);
          }).toList();
        } else {
          throw ServerException(apiMessage ?? 'Failed to fetch leave requests');
        }
      } else {
        throw ServerException('Failed to fetch leave requests');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        final responseData = e.response?.data;
        final message = responseData is Map
            ? (responseData['message'] ?? 'Failed to fetch leave requests')
            : 'Failed to fetch leave requests';
        throw ServerException(message);
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<String> applyLeave(Map<String, dynamic> leaveData) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return 'Leave request submitted successfully';
    }

    try {
      final response = await dio.post(
        ApiConstants.leaveRequests,
        data: leaveData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        // Handle response format: { "status": 200, "message": "Success", "leaveRequestId": null, "data": null }
        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'];
          final message = responseData['message'] as String?;
          
          // Check if status indicates success (200, 1, or success string)
          if (status == 200 ||
              status == 1 ||
              status == 'success' ||
              status == 'Success') {
            return message ?? 'Leave request submitted successfully';
          } else {
            throw ServerException(message ?? 'Failed to apply leave');
          }
        } else {
          // Fallback for other response formats
          return 'Leave request submitted successfully';
        }
      } else {
        throw ServerException('Failed to apply leave');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] as String?;
          throw ServerException(message ?? 'Failed to apply leave');
        }
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to apply leave',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<String> updateLeaveStatus({
    required LeaveRequest request,
    required LeaveStatus status,
    required String currentUserId,
    String? remark,
    int? clientId,
  }) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return 'Leave status updated successfully';
    }

    try {
      final leaveRequestId = int.tryParse(request.id) ?? 0;
      final driverId = int.tryParse(request.userId) ?? 0;
      final requestedUserId = int.tryParse(request.userId) ?? 0;
      final approveUserId = int.tryParse(currentUserId) ?? 0;
      
      // Convert LeaveStatus enum to API status code (2 = approved, 3 = rejected, 0 = pending)
      final leaveStatusValue = status == LeaveStatus.approved 
          ? 2 
          : (status == LeaveStatus.rejected ? 3 : 0);

      // Combine date and time into full DateTime objects
      final fromDateTime = DateTime(
        request.startDate.year,
        request.startDate.month,
        request.startDate.day,
        request.startTime.hour,
        request.startTime.minute,
      );

      final toDateTime = DateTime(
        request.endDate.year,
        request.endDate.month,
        request.endDate.day,
        request.endTime.hour,
        request.endTime.minute,
      );

      // For approval: use original request reason if remark is null/empty
      // For rejection: use the provided remark
      final finalRemark = (remark == null || remark.isEmpty) 
          ? (request.reason ?? request.remark ?? '')
          : remark;

      // Build complete request body with all required fields
      final body = {
        'leaveRequestId': leaveRequestId,
        'driverId': driverId,
        'clientId': clientId ?? 0, // Always include clientId
        'leaveTypeId': request.leaveTypeId ?? 0,
        'leaveFromDate': fromDateTime.toIso8601String(),
        'leaveToDate': toDateTime.toIso8601String(),
        'leaveReason': finalRemark,
        'remark': finalRemark,
        'leaveStatus': leaveStatusValue,
        'requestedUserId': requestedUserId,
        'approveId': approveUserId,
        'insertMode': 2, // 2 = update
      };

      final response = await dio.post(
        ApiConstants.leaveStatusUpdate,
        data: body,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final apiStatus = data['status'];
          final message = data['message']?.toString() ?? 'Leave status updated successfully';
          // API returns status: 200 for success, or status: 1 (legacy)
          if (apiStatus == 200 || apiStatus == 1) {
            return message;
          }
          throw ServerException(message);
        }
        return 'Leave status updated successfully';
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
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return [
        const LeaveTypeModel(leaveTypeId: 1, leaveTypeName: 'Full Day'),
        const LeaveTypeModel(leaveTypeId: 2, leaveTypeName: 'First Half'),
        const LeaveTypeModel(leaveTypeId: 3, leaveTypeName: 'Second Half'),
      ];
    }

    try {
      final response = await dio.post(
        ApiConstants.leaveTypes,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle response with status and message fields
        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'];
          final message = responseData['message'];
          
          // Extract data array from response
          final List<dynamic> data = responseData['data'] ?? [];
          
          if (status != null &&
              status != 200 &&
              status != 1 &&
              status != 'success') {
            throw ServerException(message ?? 'Failed to fetch leave types');
          }
          
          return data
              .map((json) => LeaveTypeModel.fromJson(json))
              .toList();
        } else if (responseData is List) {
          // Handle case where response is directly an array
          return responseData
              .map((json) => LeaveTypeModel.fromJson(json))
              .toList();
        } else {
          throw ServerException('Invalid response format');
        }
      } else {
        throw ServerException('Failed to fetch leave types');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch leave types',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}

