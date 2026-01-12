import '../../domain/entities/attendance_report.dart';
import '../../../attendance/domain/entities/attendance_record.dart';

class AttendanceStatusConverter {
  AttendanceStatus fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      default:
        return AttendanceStatus.absent;
    }
  }

  String toJson(AttendanceStatus object) {
    switch (object) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
    }
  }
}

class DailyAttendanceRecordModel extends DailyAttendanceRecord {
  const DailyAttendanceRecordModel({
    required super.date,
    required super.status,
    super.checkInTime,
    super.checkOutTime,
    super.totalHours,
    super.overtime,
  });

  factory DailyAttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final converter = AttendanceStatusConverter();
    return DailyAttendanceRecordModel(
      date: DateTime.parse(json['date'] as String),
      status: converter.fromJson(json['status'] as String),
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'] as String)
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'] as String)
          : null,
      totalHours: json['total_hours'] != null
          ? Duration(seconds: json['total_hours'] as int)
          : null,
      overtime: json['overtime'] != null
          ? Duration(seconds: json['overtime'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final converter = AttendanceStatusConverter();
    return {
      'date': date.toIso8601String(),
      'status': converter.toJson(status),
      if (checkInTime != null) 'check_in_time': checkInTime!.toIso8601String(),
      if (checkOutTime != null) 'check_out_time': checkOutTime!.toIso8601String(),
      if (totalHours != null) 'total_hours': totalHours!.inSeconds,
      if (overtime != null) 'overtime': overtime!.inSeconds,
    };
  }

  DailyAttendanceRecord toEntity() {
    return DailyAttendanceRecord(
      date: date,
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      totalHours: totalHours,
      overtime: overtime,
    );
  }
}

class AttendanceReportModel extends AttendanceReport {
  const AttendanceReportModel({
    required super.totalDays,
    required super.presentDays,
    required super.absentDays,
    required super.leaveDays,
    required super.attendanceRate,
    required super.totalHours,
    required super.dailyRecords,
  });

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    // Convert daily_records to DailyAttendanceRecordModel list
    final dailyRecordsJson = json['daily_records'] ?? json['dailyRecords'] ?? [];
    final dailyRecords = (dailyRecordsJson as List)
        .map((record) => DailyAttendanceRecordModel.fromJson(record))
        .toList();

    return AttendanceReportModel(
      totalDays: json['total_days'] ?? json['totalDays'] ?? 0,
      presentDays: json['present_days'] ?? json['presentDays'] ?? 0,
      absentDays: json['absent_days'] ?? json['absentDays'] ?? 0,
      leaveDays: json['leave_days'] ?? json['leaveDays'] ?? 0,
      attendanceRate: (json['attendance_rate'] ?? json['attendanceRate'] ?? 0.0).toDouble(),
      totalHours: json['total_hours'] != null
          ? Duration(seconds: json['total_hours'] as int)
          : json['totalHours'] != null
              ? json['totalHours'] as Duration
              : Duration.zero,
      dailyRecords: dailyRecords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'present_days': presentDays,
      'absent_days': absentDays,
      'leave_days': leaveDays,
      'attendance_rate': attendanceRate,
      'total_hours': totalHours.inSeconds,
      'daily_records': dailyRecords.map((r) {
        if (r is DailyAttendanceRecordModel) {
          return r.toJson();
        }
        return (r as DailyAttendanceRecordModel).toJson();
      }).toList(),
    };
  }

  AttendanceReport toEntity() {
    return AttendanceReport(
      totalDays: totalDays,
      presentDays: presentDays,
      absentDays: absentDays,
      leaveDays: leaveDays,
      attendanceRate: attendanceRate,
      totalHours: totalHours,
      dailyRecords: dailyRecords,
    );
  }
}
