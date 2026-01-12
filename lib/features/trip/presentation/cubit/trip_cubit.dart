import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_detail.dart';
import '../../domain/usecases/get_trips_usecase.dart';
import '../../domain/usecases/get_trip_detail_usecase.dart';
import '../../domain/usecases/start_trip_usecase.dart';
import '../../domain/usecases/end_trip_usecase.dart';

part 'trip_state.dart';

class TripCubit extends Cubit<TripState> {
  final GetTripDetailsUseCase getTripsUseCase;
  final GetTripDetailUseCase getTripDetailUseCase;
  final StartTripUseCase startTripUseCase;
  final EndTripUseCase endTripUseCase;

  TripCubit({
    required this.getTripsUseCase,
    required this.getTripDetailUseCase,
    required this.startTripUseCase,
    required this.endTripUseCase,
  }) : super(TripInitial());

  Future<void> loadTrips({String? driverId, String? status}) async {
    emit(TripLoading());
    final result = await getTripsUseCase(driverId: driverId, status: status);
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
}

