import '../../domain/entities/trip_detail.dart';

class TripDetailStatusConverter {
  TripDetailStatus fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'scheduled':
        return TripDetailStatus.scheduled;
      case 'started':
        return TripDetailStatus.started;
      case 'completed':
        return TripDetailStatus.completed;
      case 'cancelled':
        return TripDetailStatus.cancelled;
      default:
        return TripDetailStatus.scheduled;
    }
  }

  String toJson(TripDetailStatus object) {
    switch (object) {
      case TripDetailStatus.scheduled:
        return 'scheduled';
      case TripDetailStatus.started:
        return 'started';
      case TripDetailStatus.completed:
        return 'completed';
      case TripDetailStatus.cancelled:
        return 'cancelled';
    }
  }
}

class TripDetailModel extends TripDetail {
  const TripDetailModel({
    required super.id,
    required super.vehicleId,
    required super.vehicleName,
    super.route,
    super.customer,
    super.location,
    super.pickupDrop,
    required super.scheduleStart,
    super.actualStart,
    super.actualEnd,
    required super.status,
    super.tripStartOdometer,
    super.tripEndOdometer,
    super.driverId,
    super.driverName,
    required super.createdAt,
    super.updatedAt,
  });

  factory TripDetailModel.fromJson(Map<String, dynamic> json) {
    final converter = TripDetailStatusConverter();
    return TripDetailModel(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] ?? json['vehicleId'] ?? '',
      vehicleName: json['vehicle_name'] ?? json['vehicleName'] ?? '',
      route: json['route'] as String?,
      customer: json['customer'] as String?,
      location: json['location'] as String?,
      pickupDrop: json['pickup_drop'] ?? json['pickupDrop'] as String?,
      scheduleStart: DateTime.parse(json['schedule_start'] ?? json['scheduleStart']),
      actualStart: json['actual_start'] != null
          ? DateTime.parse(json['actual_start'] as String)
          : json['actualStart'] != null
              ? json['actualStart'] as DateTime
              : null,
      actualEnd: json['actual_end'] != null
          ? DateTime.parse(json['actual_end'] as String)
          : json['actualEnd'] != null
              ? json['actualEnd'] as DateTime
              : null,
      status: converter.fromJson(json['status'] as String),
      tripStartOdometer: json['trip_start_odometer'] ?? json['tripStartOdometer'] as int?,
      tripEndOdometer: json['trip_end_odometer'] ?? json['tripEndOdometer'] as int?,
      driverId: json['driver_id'] ?? json['driverId'] as String?,
      driverName: json['driver_name'] ?? json['driverName'] as String?,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] as DateTime?,
    );
  }

  Map<String, dynamic> toJson() {
    final converter = TripDetailStatusConverter();
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'vehicle_name': vehicleName,
      if (route != null) 'route': route,
      if (customer != null) 'customer': customer,
      if (location != null) 'location': location,
      if (pickupDrop != null) 'pickup_drop': pickupDrop,
      'schedule_start': scheduleStart.toIso8601String(),
      if (actualStart != null) 'actual_start': actualStart!.toIso8601String(),
      if (actualEnd != null) 'actual_end': actualEnd!.toIso8601String(),
      'status': converter.toJson(status),
      if (tripStartOdometer != null) 'trip_start_odometer': tripStartOdometer,
      if (tripEndOdometer != null) 'trip_end_odometer': tripEndOdometer,
      if (driverId != null) 'driver_id': driverId,
      if (driverName != null) 'driver_name': driverName,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  TripDetail toEntity() {
    return TripDetail(
      id: id,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      route: route,
      customer: customer,
      location: location,
      pickupDrop: pickupDrop,
      scheduleStart: scheduleStart,
      actualStart: actualStart,
      actualEnd: actualEnd,
      status: status,
      tripStartOdometer: tripStartOdometer,
      tripEndOdometer: tripEndOdometer,
      driverId: driverId,
      driverName: driverName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

