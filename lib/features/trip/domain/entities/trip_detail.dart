import 'package:equatable/equatable.dart';

enum TripDetailStatus { scheduled, started, completed, cancelled }

class TripDetail extends Equatable {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String? route;
  final String? customer;
  final String? location;
  final String? pickupDrop; // "PICK UP" or "DROP"
  final DateTime scheduleStart;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final TripDetailStatus status;
  final int? tripStartOdometer;
  final int? tripEndOdometer;
  final String? driverId;
  final String? driverName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TripDetail({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    this.route,
    this.customer,
    this.location,
    this.pickupDrop,
    required this.scheduleStart,
    this.actualStart,
    this.actualEnd,
    required this.status,
    this.tripStartOdometer,
    this.tripEndOdometer,
    this.driverId,
    this.driverName,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        vehicleName,
        route,
        customer,
        location,
        pickupDrop,
        scheduleStart,
        actualStart,
        actualEnd,
        status,
        tripStartOdometer,
        tripEndOdometer,
        driverId,
        driverName,
        createdAt,
        updatedAt,
      ];
}

