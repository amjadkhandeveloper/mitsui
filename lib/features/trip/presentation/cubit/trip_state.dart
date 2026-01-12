part of 'trip_cubit.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripSubmitting extends TripState {}

class TripsLoaded extends TripState {
  final List<TripDetail> trips;

  const TripsLoaded({required this.trips});

  @override
  List<Object?> get props => [trips];
}

class TripDetailLoaded extends TripState {
  final TripDetail trip;

  const TripDetailLoaded({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripStarted extends TripState {
  final TripDetail trip;

  const TripStarted({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripEnded extends TripState {
  final TripDetail trip;

  const TripEnded({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripError extends TripState {
  final String message;

  const TripError(this.message);

  @override
  List<Object?> get props => [message];
}

