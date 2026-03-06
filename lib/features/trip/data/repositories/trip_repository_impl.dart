import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/trip_detail.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResult<List<TripDetail>> getTrips({
    String? userId,
    String? driverId,
    String? status,
  }) async {
    try {
      final trips = await remoteDataSource.getTrips(
        userId: userId,
        driverId: driverId,
        status: status,
      );
      return Right(trips.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<TripDetail> getTripDetail(String tripId) async {
    try {
      final trip = await remoteDataSource.getTripDetail(tripId);
      return Right(trip.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<TripDetail> startTrip(String tripId, int startOdometer) async {
    try {
      final trip = await remoteDataSource.startTrip(tripId, startOdometer);
      return Right(trip.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<TripDetail> endTrip(String tripId, int endOdometer) async {
    try {
      final trip = await remoteDataSource.endTrip(tripId, endOdometer);
      return Right(trip.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<void> splitTrip(String tripId, TripDetail originalTrip) async {
    try {
      await remoteDataSource.splitTrip(tripId, originalTrip);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<String> updateVehicleApproveStatus({
    required String tripRequestId,
    required int approvedStatus,
    required String approvedBy,
  }) async {
    try {
      final message = await remoteDataSource.updateVehicleApproveStatus(
        tripRequestId: tripRequestId,
        approvedStatus: approvedStatus,
        approvedBy: approvedBy,
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
  FutureResult<String> cancelTrip({
    required String tripId,
    required String userId,
    required String remarks,
  }) async {
    try {
      final message = await remoteDataSource.cancelTrip(
        tripId: tripId,
        userId: userId,
        remarks: remarks,
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
}

