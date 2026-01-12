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
  final LeaveRequest request;

  const LeaveSubmitted({required this.request});

  @override
  List<Object?> get props => [request];
}

class LeaveStatusUpdated extends LeaveState {
  final LeaveRequest request;

  const LeaveStatusUpdated({required this.request});

  @override
  List<Object?> get props => [request];
}

class LeaveError extends LeaveState {
  final String message;

  const LeaveError(this.message);

  @override
  List<Object?> get props => [message];
}

