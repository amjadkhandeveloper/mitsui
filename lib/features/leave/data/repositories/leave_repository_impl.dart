import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/entities/leave_type.dart';
import '../../domain/repositories/leave_repository.dart';
import '../datasources/leave_remote_data_source.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;

  LeaveRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResult<List<LeaveRequest>> getLeaveRequests({String? userId, String? driverId}) async {
    try {
      final requests = await remoteDataSource.getLeaveRequests(
        userId: userId,
        driverId: driverId,
      );
      return Right(requests.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<String> applyLeave(Map<String, dynamic> leaveData) async {
    try {
      final message = await remoteDataSource.applyLeave(leaveData);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<String> updateLeaveStatus({
    required LeaveRequest request,
    required LeaveStatus status,
    required String currentUserId,
    String? remark,
    int? clientId,
  }) async {
    try {
      final message = await remoteDataSource.updateLeaveStatus(
        request: request,
        status: status,
        currentUserId: currentUserId,
        remark: remark,
        clientId: clientId,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<List<LeaveTypeEntity>> getLeaveTypes() async {
    try {
      final leaveTypes = await remoteDataSource.getLeaveTypes();
      // LeaveTypeModel extends LeaveTypeEntity, so we can return them directly
      return Right(leaveTypes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }
}

