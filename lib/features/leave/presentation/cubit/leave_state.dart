part of 'leave_cubit.dart';

abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveSubmitting extends LeaveState {}

class LeaveLoaded extends LeaveState {
  final List<LeaveRequest> requests;

  const LeaveLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class LeaveSubmitted extends LeaveState {
  final String message;

  const LeaveSubmitted({required this.message});

  @override
  List<Object?> get props => [message];
}

class LeaveStatusUpdated extends LeaveState {
  final String message;

  const LeaveStatusUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}

class LeaveError extends LeaveState {
  final String message;

  const LeaveError(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaveTypesLoaded extends LeaveState {
  final List<LeaveTypeEntity> leaveTypes;

  const LeaveTypesLoaded({required this.leaveTypes});

  @override
  List<Object?> get props => [leaveTypes];
}

