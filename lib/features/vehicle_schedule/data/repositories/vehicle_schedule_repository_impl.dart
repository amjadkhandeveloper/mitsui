import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/free_slot.dart';
import '../../domain/repositories/vehicle_schedule_repository.dart';
import '../datasources/vehicle_schedule_remote_data_source.dart';

class VehicleScheduleRepositoryImpl implements VehicleScheduleRepository {
  final VehicleScheduleRemoteDataSource remoteDataSource;

  VehicleScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResult<List<Trip>> getTrips({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final trips = await remoteDataSource.getTrips(
        date: date,
        startDate: startDate,
        endDate: endDate,
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
  FutureResult<Trip> updateTripStatus(String tripId, TripStatus status) async {
    try {
      final trip = await remoteDataSource.updateTripStatus(tripId, status);
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
  FutureResult<FreeSlot> createFreeSlot(Map<String, dynamic> slotData) async {
    try {
      final slot = await remoteDataSource.createFreeSlot(slotData);
      return Right(slot.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<List<FreeSlot>> getFreeSlots({DateTime? date}) async {
    try {
      final slots = await remoteDataSource.getFreeSlots(date: date);
      return Right(slots.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }
}

