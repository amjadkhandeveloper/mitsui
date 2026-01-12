import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
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

  AttendanceReportRemoteDataSourceImpl({required this.dio});

  @override
  Future<AttendanceReportModel> getAttendanceReport({
    String? driverId,
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (driverId != null) queryParams['driver_id'] = driverId;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await dio.get(
        '/attendance-report',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return AttendanceReportModel.fromJson(data);
      } else {
        throw ServerException('Failed to fetch attendance report');
      }
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

