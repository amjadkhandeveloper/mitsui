import 'package:equatable/equatable.dart';
import '../../../attendance/domain/entities/attendance_record.dart';

class AttendanceReport extends Equatable {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final double attendanceRate;
  final Duration totalHours;
  final List<DailyAttendanceRecord> dailyRecords;

  const AttendanceReport({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.attendanceRate,
    required this.totalHours,
    required this.dailyRecords,
  });

  @override
  List<Object?> get props => [
        totalDays,
        presentDays,
        absentDays,
        leaveDays,
        attendanceRate,
        totalHours,
        dailyRecords,
      ];
}

class DailyAttendanceRecord extends Equatable {
  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final Duration? totalHours;
  final Duration? overtime;

  const DailyAttendanceRecord({
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours,
    this.overtime,
  });

  @override
  List<Object?> get props => [
        date,
        status,
        checkInTime,
        checkOutTime,
        totalHours,
        overtime,
      ];
}

