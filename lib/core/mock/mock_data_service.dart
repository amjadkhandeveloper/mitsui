import '../../features/attendance/data/models/attendance_record_model.dart';
import '../../features/attendance/data/models/driver_model.dart';
import '../../features/attendance_report/data/models/attendance_report_model.dart';
import '../../features/leave/data/models/leave_request_model.dart';
import '../../features/vehicle_schedule/data/models/trip_model.dart';
import '../../features/vehicle_schedule/domain/entities/trip.dart' as vehicle_schedule;
import '../../features/trip/data/models/trip_detail_model.dart';
import '../../features/receipt/data/models/receipt_model.dart';
import '../../features/attendance/domain/entities/attendance_record.dart';
import '../../features/trip/domain/entities/trip_detail.dart';
import '../../features/receipt/domain/entities/receipt.dart';

class MockDataService {
  // Store split trips (tripId -> list of split trips)
  static final Map<String, List<TripDetailModel>> _splitTrips = {};

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
    // Mock JSON payload (same structure as LeaveList API)
    const mockJson = {
      "status": 200,
      "message": "successfully",
      "data": [
        {
          "LeaveRequestId": 3,
          "LeaveTypeId": 1,
          "LeaveDate": "2026-02-02T00:00:00.000Z",
          "StartTime": "",
          "EndTime": "",
          "LeaveReason": "testing",
          "LeaveStatus": 1,
          "RequestedUserId": 1,
          "RequestedDateTime": "2026-02-02T18:19:01.353Z",
          "ApprovedBy": "",
          "ApproverId": "",
          "ApprovedDateTime": ""
        },
        {
          "LeaveRequestId": 7,
          "LeaveTypeId": 1,
          "LeaveDate": "2026-03-05T00:00:00.000Z",
          "StartTime": "",
          "EndTime": "",
          "LeaveReason": "testing",
          "LeaveStatus": 1,
          "RequestedUserId": 1,
          "RequestedDateTime": "2026-02-02T18:32:02.993Z",
          "ApprovedBy": "",
          "ApproverId": "",
          "ApprovedDateTime": ""
        },
        {
          "LeaveRequestId": 8,
          "LeaveTypeId": 1,
          "LeaveDate": "2026-03-06T00:00:00.000Z",
          "StartTime": "",
          "EndTime": "",
          "LeaveReason": "testing",
          "LeaveStatus": 1,
          "RequestedUserId": 1,
          "RequestedDateTime": "2026-02-02T18:32:02.993Z",
          "ApprovedBy": "",
          "ApproverId": "",
          "ApprovedDateTime": ""
        },
        {
          "LeaveRequestId": 2,
          "LeaveTypeId": 1,
          "LeaveDate": "2030-12-31T00:00:00.000Z",
          "StartTime": "",
          "EndTime": "",
          "LeaveReason": "Testing",
          "LeaveStatus": 1,
          "RequestedUserId": 1,
          "RequestedDateTime": "2026-02-02T18:11:33.247Z",
          "ApprovedBy": "",
          "ApproverId": "",
          "ApprovedDateTime": ""
        }
      ]
    };

    final List<dynamic> data = mockJson['data'] as List<dynamic>;

    return data.map((raw) {
      final json = raw as Map<String, dynamic>;

      // Normalize to what LeaveRequestModel.fromJson expects
      final normalized = <String, dynamic>{
        'leaveRequestId': json['LeaveRequestId'],
        'driverId': json['RequestedUserId'],
        'requestedUserId': json['RequestedUserId'],
        'leaveTypeId': json['LeaveTypeId'],
        'leaveFromDate': json['LeaveDate'],
        'leaveToDate': json['LeaveDate'],
        'leaveReason': json['LeaveReason'],
        'leaveStatusAt': json['LeaveStatus'],
        'approveId': json['ApproverId'],
        'createdAt': json['RequestedDateTime'],
        'rawLeaveDate': json['LeaveDate'],
        'rawStartTime': json['StartTime'],
        'rawEndTime': json['EndTime'],
      };

      return LeaveRequestModel.fromJson(normalized);
    }).toList();
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
        status: vehicle_schedule.TripStatus.pending,
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
        status: vehicle_schedule.TripStatus.accepted,
        driverId: '2',
        driverName: 'Jane Smith',
        destination: 'Downtown',
        purpose: 'Meeting',
        createdAt: targetDate.subtract(const Duration(days: 2)),
      ),
    ];
  }

  // Add split trips to the mock data
  static void addSplitTrips(String originalTripId, TripDetailModel pickupTrip, TripDetailModel dropTrip) {
    _splitTrips[originalTripId] = [pickupTrip, dropTrip];
  }

  // Mock Trip Details
  static List<TripDetailModel> getMockTripDetails({String? driverId}) {
    final now = DateTime.now();
    final trips = <TripDetailModel>[
      TripDetailModel(
        id: 'trip_detail_1',
        vehicleId: 'AP39UD6009',
        vehicleName: 'Toyota Camry',
        route: 'NA',
        customer: 'TESCO',
        location: 'Silkboard',
        pickupDrop: 'PICK UP',
        scheduleStart: DateTime(now.year, now.month, now.day, 18, 30),
        scheduleEnd: DateTime(now.year, now.month, now.day, 20, 30),
        status: TripDetailStatus.scheduled,
        tripStatus: 1, // Trip Requested
        driverId: driverId ?? '1',
        driverName: 'John Doe',
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
        scheduleEnd: DateTime(now.year, now.month, now.day, 16, 0),
        actualStart: DateTime(now.year, now.month, now.day, 14, 5),
        status: TripDetailStatus.started,
        tripStatus: 2, // Trip Scheduled
        tripStartOdometer: 38200,
        driverId: driverId ?? '2',
        driverName: 'Jane Smith',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TripDetailModel(
        id: 'trip_detail_3',
        vehicleId: 'V003',
        vehicleName: 'Ford Focus',
        route: 'Route 202',
        customer: 'Target',
        location: 'Airport',
        pickupDrop: 'PICK UP',
        scheduleStart: DateTime(now.year, now.month, now.day + 1, 10, 0),
        scheduleEnd: DateTime(now.year, now.month, now.day + 1, 12, 0),
        status: TripDetailStatus.scheduled,
        tripStatus: 2, // Trip Scheduled
        driverId: driverId ?? '1',
        driverName: 'John Doe',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
    
    // Add split trips to the list
    for (final splitTripList in _splitTrips.values) {
      trips.addAll(splitTripList);
    }
    
    return trips;
  }

  // Mock Receipts
  static List<ReceiptModel> getMockReceipts({String? driverId}) {
    final now = DateTime.now();
    return [
      ReceiptModel(
        id: 'receipt_1',
        type: ReceiptType.fuel,
        expenseTypeId: 2, // Fuel
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
        expenseTypeId: 3, // Parking
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
        expenseTypeId: 4, // Toll Fee
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
        expenseTypeId: 2, // Fuel
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
        expenseTypeId: 5, // Other
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

