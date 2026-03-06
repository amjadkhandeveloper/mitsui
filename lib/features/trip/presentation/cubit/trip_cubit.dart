import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_detail.dart';
import '../../domain/usecases/get_trips_usecase.dart';
import '../../domain/usecases/get_trip_detail_usecase.dart';
import '../../domain/usecases/start_trip_usecase.dart';
import '../../domain/usecases/end_trip_usecase.dart';
import '../../domain/repositories/trip_repository.dart';

part 'trip_state.dart';

class TripCubit extends Cubit<TripState> {
  final GetTripDetailsUseCase getTripsUseCase;
  final GetTripDetailUseCase getTripDetailUseCase;
  final StartTripUseCase startTripUseCase;
  final EndTripUseCase endTripUseCase;
  final TripRepository tripRepository;

  TripCubit({
    required this.getTripsUseCase,
    required this.getTripDetailUseCase,
    required this.startTripUseCase,
    required this.endTripUseCase,
    required this.tripRepository,
  }) : super(TripInitial());

  Future<void> loadTrips({
    String? userId,
    String? driverId,
    String? status,
  }) async {
    emit(TripLoading());
    final result = await getTripsUseCase(
      userId: userId,
      driverId: driverId,
      status: status,
    );
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trips) => emit(TripsLoaded(trips: trips)),
    );
  }

  Future<void> loadTripDetail(String tripId) async {
    emit(TripLoading());
    final result = await getTripDetailUseCase(tripId);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trip) => emit(TripDetailLoaded(trip: trip)),
    );
  }

  Future<void> startTrip(String tripId, int startOdometer) async {
    emit(TripSubmitting());
    final result = await startTripUseCase(tripId, startOdometer);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trip) {
        emit(TripStarted(trip: trip));
        // Reload trip detail
        loadTripDetail(tripId);
      },
    );
  }

  Future<void> endTrip(String tripId, int endOdometer) async {
    emit(TripSubmitting());
    final result = await endTripUseCase(tripId, endOdometer);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trip) {
        emit(TripEnded(trip: trip));
        // Reload trip detail
        loadTripDetail(tripId);
      },
    );
  }

  Future<void> approveTrip(String tripId, String approvedBy) async {
    emit(TripSubmitting());
    final result = await tripRepository.updateVehicleApproveStatus(
      tripRequestId: tripId,
      approvedStatus: 1, // 1 for approve
      approvedBy: approvedBy,
    );
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (message) {
        // Emit success message so UI can show toast
        emit(TripActionSuccess(
          message.isNotEmpty ? message : 'Trip approved successfully',
        ));
      },
    );
  }

  Future<void> rejectTrip(String tripId, String approvedBy) async {
    emit(TripSubmitting());
    final result = await tripRepository.updateVehicleApproveStatus(
      tripRequestId: tripId,
      approvedStatus: 0, // 0 for reject
      approvedBy: approvedBy,
    );
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (message) {
        // Emit success message so UI can show toast
        emit(TripActionSuccess(
          message.isNotEmpty ? message : 'Trip rejected successfully',
        ));
      },
    );
  }

  Future<void> cancelTrip(String tripId, String userId, {String remarks = ''}) async {
    emit(TripSubmitting());
    final result = await tripRepository.cancelTrip(
      tripId: tripId,
      userId: userId,
      remarks: remarks.isNotEmpty ? remarks : 'Cancelled by user',
    );
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (message) {
        emit(TripActionSuccess(
          message.isNotEmpty ? message : 'Trip cancelled successfully',
        ));
      },
    );
  }

}

