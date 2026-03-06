import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent }

class AttendanceRecord extends Equatable {
  final String id;
  final String driverId;
  final String driverName;
  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? location;
  // New fields from API
  final int? attendanceId;
  final String? clientName;
  final String? zoneName;
  final double? checkInLat;
  final double? checkInLon;
  final double? checkOutLat;
  final double? checkOutLon;
  final String? driverStatus;

  const AttendanceRecord({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.location,
    this.attendanceId,
    this.clientName,
    this.zoneName,
    this.checkInLat,
    this.checkInLon,
    this.checkOutLat,
    this.checkOutLon,
    this.driverStatus,
  });

  // Helper method to check if check-in needs approval
  bool get needsCheckInApproval => checkInTime != null && checkOutTime == null;

  // Helper method to check if check-out needs approval
  bool get needsCheckOutApproval => checkInTime != null && checkOutTime != null && checkOutLat == null && checkOutLon == null;

  @override
  List<Object?> get props => [
        id,
        driverId,
        driverName,
        date,
        status,
        checkInTime,
        checkOutTime,
        location,
        attendanceId,
        clientName,
        zoneName,
        checkInLat,
        checkInLon,
        checkOutLat,
        checkOutLon,
        driverStatus,
      ];
}

