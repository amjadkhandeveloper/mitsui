part of 'attendance_report_cubit.dart';

abstract class AttendanceReportState extends Equatable {
  const AttendanceReportState();

  @override
  List<Object?> get props => [];
}

class AttendanceReportInitial extends AttendanceReportState {}

class AttendanceReportLoading extends AttendanceReportState {}

class AttendanceReportLoaded extends AttendanceReportState {
  final AttendanceReport report;
  final Driver? selectedDriver;
  final int? selectedMonth;
  final int? selectedYear;

  const AttendanceReportLoaded({
    required this.report,
    this.selectedDriver,
    this.selectedMonth,
    this.selectedYear,
  });

  @override
  List<Object?> get props => [
        report,
        selectedDriver,
        selectedMonth,
        selectedYear,
      ];
}

class AttendanceReportError extends AttendanceReportState {
  final String message;

  const AttendanceReportError(this.message);

  @override
  List<Object?> get props => [message];
}

