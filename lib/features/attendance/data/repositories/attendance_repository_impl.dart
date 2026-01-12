import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResult<List<AttendanceRecord>> getAttendanceRecords({
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final records = await remoteDataSource.getAttendanceRecords(
        driverId: driverId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(records.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<List<Driver>> getDrivers() async {
    try {
      final drivers = await remoteDataSource.getDrivers();
      return Right(drivers.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }
}

