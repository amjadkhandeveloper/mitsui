import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_data_service.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../models/attendance_report_model.dart';

abstract class AttendanceReportRemoteDataSource {
  Future<AttendanceReportModel> getAttendanceReport({
    String? driverId,
    int? month,
    int? year,
  });
}

class AttendanceReportRemoteDataSourceImpl
    implements AttendanceReportRemoteDataSource {
  final Dio dio;
  final LocalStorageDataSource localStorageDataSource;

  AttendanceReportRemoteDataSourceImpl({
    required this.dio,
    required this.localStorageDataSource,
  });

  @override
  Future<AttendanceReportModel> getAttendanceReport({
    String? driverId,
    int? month,
    int? year,
  }) async {
    // Use mock data if enabled for attendance
    if (AppConfig.USE_MOCK_DATA || AppConfig.USE_MOCK_DATA_ATTENDANCE) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return MockDataService.getMockAttendanceReport();
    }

    try {
      // Resolve driver/user IDs based on login, similar to other APIs:
      // - If driver login: driverId = <driverId>, userId = 0
      // - If user login:   userId   = <userId>,   driverId = 0
      final storedUserId = await localStorageDataSource.getUserId();
      final storedDriverId = await localStorageDataSource.getDriverId();

      int resolvedUserId = 0;
      int resolvedDriverId = 0;

      // Prefer driver login when driverId is present
      if (storedDriverId != null &&
          storedDriverId.isNotEmpty &&
          storedDriverId != '0') {
        resolvedDriverId = int.tryParse(storedDriverId) ?? 0;
        resolvedUserId = 0;
      } else if (storedUserId != null &&
          storedUserId.isNotEmpty &&
          storedUserId != '0') {
        resolvedUserId = int.tryParse(storedUserId) ?? 0;
        resolvedDriverId = 0;
      }

      final requestBody = <String, dynamic>{
        'driverId': resolvedDriverId,
        'userId': resolvedUserId,
      };

      final response = await dio.post(
        ApiConstants.driverDailySummary,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'];
          final message = responseData['message']?.toString();
          final List<dynamic> dataList = responseData['data'] ?? [];

          if (status != null &&
              status != 200 &&
              status != 'success' &&
              status != 1) {
            throw ServerException(
              message ?? 'Failed to fetch attendance report',
            );
          }

          // Map API list to internal report model
          final dailyRecords = <DailyAttendanceRecordModel>[];
          int presentDays = 0;
          int absentDays = 0;
          int leaveDays = 0;
          Duration totalHours = Duration.zero;

          for (final item in dataList) {
            if (item is! Map<String, dynamic>) continue;

            final attendanceDateStr =
                item['AttendanceDate']?.toString().trim();
            final loginTimeStr = item['LoginTime']?.toString().trim();
            final logoutTimeStr = item['LogoutTime']?.toString().trim();
            final attendanceStatusStr =
                (item['AttendanceStatus'] ?? '').toString().trim();

            DateTime date =
                DateTime.now(); // fallback in case parse fails below
            try {
              if (attendanceDateStr != null && attendanceDateStr.isNotEmpty) {
                date = DateTime.parse(attendanceDateStr);
              }
            } catch (_) {}

            DateTime? checkInTime;
            if (loginTimeStr != null && loginTimeStr.isNotEmpty) {
              try {
                checkInTime = DateTime.parse(loginTimeStr);
              } catch (_) {}
            }

            DateTime? checkOutTime;
            if (logoutTimeStr != null && logoutTimeStr.isNotEmpty) {
              try {
                checkOutTime = DateTime.parse(logoutTimeStr);
              } catch (_) {}
            }

            // Map AttendanceStatus: "P" => present, anything else => absent
            final upperStatus = attendanceStatusStr.toUpperCase();
            final isPresent = upperStatus == 'P';
            final statusEnum =
                isPresent ? AttendanceStatus.present : AttendanceStatus.absent;

            if (isPresent) {
              presentDays++;
            } else {
              // For now, treat non-"P" as absent. You can refine this
              // mapping later if backend adds codes for leave, etc.
              absentDays++;
            }

            // Total hours: compute from LoginTime / LogoutTime difference
            // Fallback to TotalWorkingMin only if times are missing.
            final totalWorkingMin =
                (item['TotalWorkingMin'] as num?)?.toInt() ?? 0;
            final overtimeWorkingMin =
                (item['OvertimeWorkingMin'] as num?)?.toInt() ?? 0;

            Duration dayTotalHours;
            if (checkInTime != null && checkOutTime != null) {
              final diff = checkOutTime.difference(checkInTime);
              dayTotalHours =
                  diff.isNegative ? Duration.zero : diff;
            } else {
              dayTotalHours = Duration(minutes: totalWorkingMin);
            }
            final dayOvertime = Duration(minutes: overtimeWorkingMin);

            totalHours += dayTotalHours;

            dailyRecords.add(
              DailyAttendanceRecordModel(
                date: date,
                status: statusEnum,
                checkInTime: checkInTime,
                checkOutTime: checkOutTime,
                totalHours: dayTotalHours,
                overtime: dayOvertime,
              ),
            );
          }

          final totalDays = dailyRecords.length;
          final attendanceRate = totalDays == 0
              ? 0.0
              : (presentDays / totalDays) * 100.0;

          return AttendanceReportModel(
            totalDays: totalDays,
            presentDays: presentDays,
            absentDays: absentDays,
            leaveDays: leaveDays,
            attendanceRate: attendanceRate,
            totalHours: totalHours,
            dailyRecords: dailyRecords,
          );
        }

        throw ServerException('Invalid attendance report response format');
      }

      throw ServerException('Failed to fetch attendance report');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch attendance report',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}

