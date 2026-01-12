part of 'vehicle_schedule_cubit.dart';

abstract class VehicleScheduleState extends Equatable {
  const VehicleScheduleState();

  @override
  List<Object?> get props => [];
}

class VehicleScheduleInitial extends VehicleScheduleState {}

class VehicleScheduleLoading extends VehicleScheduleState {}

class VehicleScheduleSubmitting extends VehicleScheduleState {}

class VehicleScheduleLoaded extends VehicleScheduleState {
  final List<Trip> trips;
  final DateTime? selectedDate;

  const VehicleScheduleLoaded({
    this.trips = const [],
    this.selectedDate,
  });

  @override
  List<Object?> get props => [trips, selectedDate];
}

class VehicleScheduleFreeSlotCreated extends VehicleScheduleState {
  final FreeSlot slot;

  const VehicleScheduleFreeSlotCreated({required this.slot});

  @override
  List<Object?> get props => [slot];
}

class VehicleScheduleError extends VehicleScheduleState {
  final String message;

  const VehicleScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

