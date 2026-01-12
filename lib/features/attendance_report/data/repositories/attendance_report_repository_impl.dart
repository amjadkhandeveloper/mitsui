import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/attendance_report.dart';
import '../../domain/repositories/attendance_report_repository.dart';
import '../datasources/attendance_report_remote_data_source.dart';

class AttendanceReportRepositoryImpl
    implements AttendanceReportRepository {
  final AttendanceReportRemoteDataSource remoteDataSource;

  AttendanceReportRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResult<AttendanceReport> getAttendanceReport({
    String? driverId,
    int? month,
    int? year,
  }) async {
    try {
      final report = await remoteDataSource.getAttendanceReport(
        driverId: driverId,
        month: month,
        year: year,
      );
      return Right(report.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }
}

