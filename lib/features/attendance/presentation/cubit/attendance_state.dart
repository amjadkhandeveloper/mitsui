part of 'attendance_cubit.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecord> records;
  final Driver? selectedDriver;

  const AttendanceLoaded({
    required this.records,
    this.selectedDriver,
  });

  @override
  List<Object?> get props => [records, selectedDriver];
}

class DriversLoaded extends AttendanceState {
  final List<Driver> drivers;
  final Driver? selectedDriver;

  const DriversLoaded({
    required this.drivers,
    this.selectedDriver,
  });

  @override
  List<Object?> get props => [drivers, selectedDriver];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class CheckInApproved extends AttendanceState {
  final int attendanceId;

  const CheckInApproved({required this.attendanceId});

  @override
  List<Object?> get props => [attendanceId];
}

class CheckOutApproved extends AttendanceState {
  final int attendanceId;

  const CheckOutApproved({required this.attendanceId});

  @override
  List<Object?> get props => [attendanceId];
}

