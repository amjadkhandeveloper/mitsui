import '../../features/attendance/data/models/attendance_record_model.dart';
import '../../features/attendance/data/models/driver_model.dart';
import '../../features/attendance_report/data/models/attendance_report_model.dart';
import '../../features/leave/data/models/leave_request_model.dart';
import '../../features/vehicle_schedule/data/models/trip_model.dart';
import '../../features/vehicle_schedule/domain/entities/trip.dart';
import '../../features/trip/data/models/trip_detail_model.dart';
import '../../features/receipt/data/models/receipt_model.dart';
import '../../features/attendance/domain/entities/attendance_record.dart';
import '../../features/leave/domain/entities/leave_request.dart';
import '../../features/trip/domain/entities/trip_detail.dart';
import '../../features/receipt/domain/entities/receipt.dart';

class MockDataService {
  // Mock Drivers
  static List<DriverModel> getMockDrivers() {
    return [
      DriverModel(
        id: '1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
      ),
      DriverModel(
        id: '2',
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phone: '+1234567891',
      ),
      DriverModel(
        id: '3',
        name: 'Mike Johnson',
        email: 'mike.johnson@example.com',
        phone: '+1234567892',
      ),
    ];
  }

  // Mock Attendance Records
  static List<AttendanceRecordModel> getMockAttendanceRecords({String? driverId}) {
    final now = DateTime.now();
    final records = <AttendanceRecordModel>[];

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final checkIn = DateTime(date.year, date.month, date.day, 9, 0);
      final checkOut = DateTime(date.year, date.month, date.day, 18, 0);

      records.add(AttendanceRecordModel(
        id: 'att_$i',
        driverId: driverId ?? '1',
        driverName: 'John Doe',
        date: date,
        checkInTime: checkIn,
        checkOutTime: checkOut,
        status: AttendanceStatus.present,
      ));
    }

    return records;
  }

  // Mock Attendance Report
  static AttendanceReportModel getMockAttendanceReport() {
    final now = DateTime.now();
    final dailyRecords = <DailyAttendanceRecordModel>[];

    for (int i = 0; i < 10; i++) {
      final date = now.subtract(Duration(days: i));
      final checkIn = DateTime(date.year, date.month, date.day, 9, 0);
      final checkOut = DateTime(date.year, date.month, date.day, 18, 0);

      dailyRecords.add(DailyAttendanceRecordModel(
        date: date,
        status: i < 7 ? AttendanceStatus.present : AttendanceStatus.absent,
        checkInTime: i < 7 ? checkIn : null,
        checkOutTime: i < 7 ? checkOut : null,
        totalHours: i < 7 ? const Duration(hours: 9) : null,
        overtime: i < 7 ? const Duration(hours: 1) : null,
      ));
    }

    return AttendanceReportModel(
      totalDays: 10,
      presentDays: 7,
      absentDays: 1,
      leaveDays: 1,
      attendanceRate: 70.0,
      totalHours: const Duration(hours: 62, minutes: 15),
      dailyRecords: dailyRecords,
    );
  }

  // Mock Leave Requests
  static List<LeaveRequestModel> getMockLeaveRequests({String? userId}) {
    final now = DateTime.now();
    return [
      LeaveRequestModel(
        id: 'leave_1',
        userId: userId ?? '1',
        userName: 'John Doe',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 7)),
        startTime: DateTime(now.year, now.month, now.day + 5, 9, 0),
        endTime: DateTime(now.year, now.month, now.day + 7, 18, 0),
        reason: 'Family emergency',
        status: LeaveStatus.pending,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      LeaveRequestModel(
        id: 'leave_2',
        userId: userId ?? '1',
        userName: 'John Doe',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 8)),
        startTime: DateTime(now.year, now.month, now.day - 10, 9, 0),
        endTime: DateTime(now.year, now.month, now.day - 8, 18, 0),
        reason: 'Sick leave',
        status: LeaveStatus.approved,
        adminNote: 'Approved by Manager',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      LeaveRequestModel(
        id: 'leave_3',
        userId: userId ?? '1',
        userName: 'John Doe',
        startDate: now.subtract(const Duration(days: 20)),
        endDate: now.subtract(const Duration(days: 18)),
        startTime: DateTime(now.year, now.month, now.day - 20, 9, 0),
        endTime: DateTime(now.year, now.month, now.day - 18, 18, 0),
        reason: 'Personal work',
        status: LeaveStatus.rejected,
        adminNote: 'Not enough notice',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
    ];
  }

  // Mock Trips (Vehicle Schedule)
  static List<TripModel> getMockTrips({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    return [
      TripModel(
        id: 'trip_1',
        vehicleId: 'V001',
        vehicleName: 'Toyota Camry',
        date: targetDate,
        startTime: DateTime(targetDate.year, targetDate.month, targetDate.day, 9, 0),
        endTime: DateTime(targetDate.year, targetDate.month, targetDate.day, 17, 0),
        status: TripStatus.pending,
        driverId: '1',
        driverName: 'John Doe',
        destination: 'Airport',
        purpose: 'Pickup',
        createdAt: targetDate.subtract(const Duration(days: 1)),
      ),
      TripModel(
        id: 'trip_2',
        vehicleId: 'V002',
        vehicleName: 'Honda Accord',
        date: targetDate,
        startTime: DateTime(targetDate.year, targetDate.month, targetDate.day, 10, 0),
        endTime: DateTime(targetDate.year, targetDate.month, targetDate.day, 16, 0),
        status: TripStatus.accepted,
        driverId: '2',
        driverName: 'Jane Smith',
        destination: 'Downtown',
        purpose: 'Meeting',
        createdAt: targetDate.subtract(const Duration(days: 2)),
      ),
    ];
  }

  // Mock Trip Details
  static List<TripDetailModel> getMockTripDetails({String? driverId}) {
    final now = DateTime.now();
    return [
      TripDetailModel(
        id: 'trip_detail_1',
        vehicleId: 'AP39UD6009',
        vehicleName: 'Toyota Camry',
        route: 'NA',
        customer: 'TESCO',
        location: 'Silkboard',
        pickupDrop: 'PICK UP',
        scheduleStart: DateTime(now.year, now.month, now.day, 18, 30),
        status: TripDetailStatus.scheduled,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TripDetailModel(
        id: 'trip_detail_2',
        vehicleId: 'V002',
        vehicleName: 'Honda Accord',
        route: 'Route 101',
        customer: 'Walmart',
        location: 'City Center',
        pickupDrop: 'DROP',
        scheduleStart: DateTime(now.year, now.month, now.day, 14, 0),
        actualStart: DateTime(now.year, now.month, now.day, 14, 5),
        status: TripDetailStatus.started,
        tripStartOdometer: 38200,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Mock Receipts
  static List<ReceiptModel> getMockReceipts({String? driverId}) {
    final now = DateTime.now();
    return [
      ReceiptModel(
        id: 'receipt_1',
        type: ReceiptType.fuel,
        amount: 2500,
        description: 'Petrol for Mumbai trip',
        receiptDate: DateTime(2025, 10, 22),
        status: ReceiptStatus.approved,
        approvedBy: 'Manager',
        approvedAt: DateTime(2025, 10, 23, 6, 24),
        submittedAt: DateTime(2025, 10, 22),
        driverId: driverId ?? '1',
        driverName: 'John Doe',
        fueledLiters: 50,
        odometerReading: 38000,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ReceiptModel(
        id: 'receipt_2',
        type: ReceiptType.parking,
        amount: 150,
        description: 'Airport parking',
        receiptDate: DateTime(2025, 10, 21),
        status: ReceiptStatus.pending,
        submittedAt: DateTime(2025, 10, 21),
        driverId: driverId ?? '1',
        driverName: 'John Doe',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      ReceiptModel(
        id: 'receipt_3',
        type: ReceiptType.toll,
        amount: 300,
        description: 'Highway toll charges',
        receiptDate: DateTime(2025, 10, 20),
        status: ReceiptStatus.rejected,
        rejectedAt: DateTime(2025, 10, 21),
        rejectionReason: 'Receipt image not clear',
        submittedAt: DateTime(2025, 10, 20),
        driverId: driverId ?? '1',
        driverName: 'John Doe',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      ReceiptModel(
        id: 'receipt_4',
        type: ReceiptType.fuel,
        amount: 1800,
        description: 'Diesel for delivery',
        receiptDate: DateTime(2025, 10, 19),
        status: ReceiptStatus.approved,
        approvedBy: 'Manager',
        approvedAt: DateTime(2025, 10, 20),
        submittedAt: DateTime(2025, 10, 19),
        driverId: driverId ?? '1',
        driverName: 'John Doe',
        fueledLiters: 35,
        odometerReading: 37500,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      ReceiptModel(
        id: 'receipt_5',
        type: ReceiptType.other,
        amount: 500,
        description: 'Vehicle maintenance',
        receiptDate: DateTime(2025, 10, 18),
        status: ReceiptStatus.pending,
        submittedAt: DateTime(2025, 10, 18),
        driverId: driverId ?? '1',
        driverName: 'John Doe',
        createdAt: now.subtract(const Duration(days: 9)),
      ),
    ];
  }
}

