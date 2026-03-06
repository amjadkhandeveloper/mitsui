import '../../../../core/utils/result.dart';
import '../entities/attendance_record.dart';
import '../entities/driver.dart';

abstract class AttendanceRepository {
  FutureResult<List<AttendanceRecord>> getAttendanceRecords({
    required int? driverId,
    required int? userId,
  });

  FutureResult<List<Driver>> getDrivers();
  
  FutureResult<void> approveCheckIn({
    required int attendanceId,
    required int userId,
    required String remark,
  });
  
  FutureResult<void> approveCheckOut({
    required int attendanceId,
    required int userId,
    required String remark,
  });
}
