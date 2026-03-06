import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/free_slot.dart';
import '../../domain/usecases/get_trips_usecase.dart';
import '../../domain/usecases/update_trip_status_usecase.dart';
import '../../domain/usecases/create_free_slot_usecase.dart';

part 'vehicle_schedule_state.dart';

class VehicleScheduleCubit extends Cubit<VehicleScheduleState> {
  final GetTripsUseCase getTripsUseCase;
  final UpdateTripStatusUseCase updateTripStatusUseCase;
  final CreateFreeSlotUseCase createFreeSlotUseCase;

  VehicleScheduleCubit({
    required this.getTripsUseCase,
    required this.updateTripStatusUseCase,
    required this.createFreeSlotUseCase,
  }) : super(VehicleScheduleInitial());

  String? _userId;
  String? _driverId;

  void selectDate(DateTime date, {String? userId, String? driverId}) {
    // Store latest IDs for subsequent reloads if needed
    _userId = userId ?? _userId;
    _driverId = driverId ?? _driverId;
    if (state is VehicleScheduleLoaded) {
      final currentState = state as VehicleScheduleLoaded;
      emit(VehicleScheduleLoaded(
        trips: currentState.trips,
        selectedDate: date,
      ));
      loadTripsForDate(date, userId: _userId, driverId: _driverId);
    } else {
      emit(VehicleScheduleLoaded(selectedDate: date));
      loadTripsForDate(date, userId: _userId, driverId: _driverId);
    }
  }

  Future<void> loadTripsForDate(
    DateTime date, {
    String? userId,
    String? driverId,
  }) async {
    // Update stored IDs if provided
    _userId = userId ?? _userId;
    _driverId = driverId ?? _driverId;

    emit(VehicleScheduleLoading());
    // Backend returns all trips for the user; keep all trips in state so the calendar
    // can enable navigation to dates that have trips.
    final result = await getTripsUseCase(
      userId: _userId,
      driverId: _driverId,
    );
    result.fold(
      (failure) => emit(VehicleScheduleError(failure.message)),
      (trips) {
        // Keep all trips; UI will filter by selected date for list display.
        emit(VehicleScheduleLoaded(trips: trips, selectedDate: date));
      },
    );
  }

  Future<void> updateStatus(String tripId, TripStatus status) async {
    final result = await updateTripStatusUseCase(tripId, status);
    result.fold(
      (failure) => emit(VehicleScheduleError(failure.message)),
      (trip) {
        if (state is VehicleScheduleLoaded) {
          final currentState = state as VehicleScheduleLoaded;
          final updatedTrips = currentState.trips.map((t) {
            return t.id == tripId ? trip : t;
          }).toList();
          emit(VehicleScheduleLoaded(
            trips: updatedTrips,
            selectedDate: currentState.selectedDate,
          ));
        }
      },
    );
  }

  Future<void> createFreeSlot(Map<String, dynamic> slotData) async {
    emit(VehicleScheduleSubmitting());
    final result = await createFreeSlotUseCase(slotData);
    result.fold(
      (failure) => emit(VehicleScheduleError(failure.message)),
      (slot) {
        emit(VehicleScheduleFreeSlotCreated(slot: slot));
        // Reload trips for the selected date
        if (state is VehicleScheduleLoaded) {
          final currentState = state as VehicleScheduleLoaded;
          if (currentState.selectedDate != null) {
            loadTripsForDate(
              currentState.selectedDate!,
              userId: _userId,
              driverId: _driverId,
            );
          }
        }
      },
    );
  }
}

