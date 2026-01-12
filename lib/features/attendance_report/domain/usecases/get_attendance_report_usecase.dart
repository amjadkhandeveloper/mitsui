import '../../../../core/utils/result.dart';
import '../entities/attendance_report.dart';
import '../repositories/attendance_report_repository.dart';

class GetAttendanceReportUseCase {
  final AttendanceReportRepository repository;

  GetAttendanceReportUseCase({required this.repository});

  FutureResult<AttendanceReport> call({
    String? driverId,
    int? month,
    int? year,
  }) async {
    return await repository.getAttendanceReport(
      driverId: driverId,
      month: month,
      year: year,
    );
  }
}

