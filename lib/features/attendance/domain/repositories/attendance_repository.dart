import '../../../../core/utils/result.dart';
import '../entities/attendance_record.dart';
import '../entities/driver.dart';

abstract class AttendanceRepository {
  FutureResult<List<AttendanceRecord>> getAttendanceRecords({
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  });

  FutureResult<List<Driver>> getDrivers();
}
