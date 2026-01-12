import 'package:equatable/equatable.dart';

enum TripStatus { pending, accepted, rejected }

class Trip extends Equatable {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final TripStatus status;
  final String? driverId;
  final String? driverName;
  final String? destination;
  final String? purpose;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Trip({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.driverId,
    this.driverName,
    this.destination,
    this.purpose,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        vehicleName,
        date,
        startTime,
        endTime,
        status,
        driverId,
        driverName,
        destination,
        purpose,
        createdAt,
        updatedAt,
      ];
}

