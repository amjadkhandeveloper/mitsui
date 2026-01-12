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

  const AttendanceRecord({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.location,
  });

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
      ];
}

