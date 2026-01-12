import '../../../../core/utils/result.dart';
import '../entities/attendance_report.dart';

abstract class AttendanceReportRepository {
  FutureResult<AttendanceReport> getAttendanceReport({
    String? driverId,
    int? month,
    int? year,
  });
}

