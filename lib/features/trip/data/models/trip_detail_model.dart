import '../../domain/entities/trip_detail.dart';
import '../../../../core/extensions/json_extensions.dart';

class TripDetailStatusConverter {
  TripDetailStatus fromJson(String json) {
    switch (json.toLowerCase().trim()) {
      case 'scheduled':
      case 'trip scheduled':
        return TripDetailStatus.scheduled;
      case 'started':
      case 'trip started':
        return TripDetailStatus.started;
      case 'completed':
      case 'trip completed':
        return TripDetailStatus.completed;
      case 'cancelled':
      case 'trip cancelled':
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
    super.mobileNo,
    super.tripType,
    required super.scheduleStart,
    super.scheduleEnd,
    super.actualStart,
    super.actualEnd,
    required super.status,
    super.tripStatus,
    super.tripStartOdometer,
    super.tripEndOdometer,
    super.driverId,
    super.driverName,
    super.driverMobileNo,
    super.expatName,
    super.filePath,
    required super.createdAt,
    super.updatedAt,
  });

  factory TripDetailModel.fromJson(Map<String, dynamic> json) {
    final converter = TripDetailStatusConverter();
    
    // New API format fields - check multiple possible field name variations using safe extensions
    final tripId = json.getStringSafe('TripRequestId') ??
                   json.getStringSafe('TripID') ??
                   json.getStringSafe('trip_id') ??
                   json.getStringSafe('tripId') ??
                   json.getStringSafe('id') ??
                   '';
    final driverName = json.getStringSafe('DriverName') ??
                       json.getStringSafe('driver_name') ??
                       json.getStringSafe('driverName');
    final vehicleNo = json.getStringSafe('VehicleNo') ??
                      json.getStringSafe('vehicle_no') ??
                      json.getStringSafe('vehicleNo');
    // Trip name (for adhoc / request-based trips)
    final tripName = json.getStringSafe('TripName') ??
                     json.getStringSafe('trip_name');
    final pickupLocation = json.getStringSafe('PickupLocation') ??
                           json.getStringSafe('pickup_location') ??
                           json.getStringSafe('pickupLocation');
    final dropLocation = json.getStringSafe('DropLocation') ??
                         json.getStringSafe('drop_location') ??
                         json.getStringSafe('dropLocation');
    final tripType = json.getStringSafe('TripType') ??
                     json.getStringSafe('trip_type') ??
                     json.getStringSafe('tripType');
    final tripStatusString = json.getStringSafe('Trip Status') ??  // API uses "Trip Status" with space
                             json.getStringSafe('TripStatus') ??
                             json.getStringSafe('trip_status') ??
                             json.getStringSafe('tripStatus');
    
    // Parse tripStatus - can be numeric (int) or string
    // Check multiple possible field names from API
    int? tripStatusNumeric;
    
    // Try "Trip Status" field (with space) - new API format
    if (json['Trip Status'] != null) {
      if (json['Trip Status'] is int) {
        tripStatusNumeric = json['Trip Status'] as int;
      } else if (json['Trip Status'] is String) {
        final statusStr = (json['Trip Status'] as String).trim().toLowerCase();
        // Map status strings to numeric values
        switch (statusStr) {
          case 'trip requested':
          case 'requested':
            tripStatusNumeric = 1;
            break;
          case 'trip scheduled':
          case 'scheduled':
            tripStatusNumeric = 2;
            break;
          case 'trip cancelled':
          case 'cancelled':
            tripStatusNumeric = 3;
            break;
          case 'trip started':
          case 'started':
            tripStatusNumeric = 4;
            break;
          case 'trip completed':
          case 'completed':
            tripStatusNumeric = 5;
            break;
          case 'expat confirmation pending':
          case 'expatconfirmationpending':
            tripStatusNumeric = 6;
            break;
          case 'expat approved':
          case 'expatapproved':
            tripStatusNumeric = 7;
            break;
          case 'expat rejected':
          case 'expatrejected':
            tripStatusNumeric = 8;
            break;
          default:
            // Try to parse as number if it's a numeric string
            tripStatusNumeric = int.tryParse(json['Trip Status'] as String);
        }
      }
    }
    
    // Try TripStatusId field first (new API format)
    if (tripStatusNumeric == null && json['TripStatusId'] != null) {
      if (json['TripStatusId'] is int) {
        tripStatusNumeric = json['TripStatusId'] as int;
      } else if (json['TripStatusId'] is String) {
        tripStatusNumeric = int.tryParse(json['TripStatusId'] as String);
      }
    }
    
    // Try TripStatus field (without space) - old API format
    if (tripStatusNumeric == null && json['TripStatus'] != null) {
      if (json['TripStatus'] is int) {
        tripStatusNumeric = json['TripStatus'] as int;
      } else if (json['TripStatus'] is String) {
        tripStatusNumeric = int.tryParse(json['TripStatus'] as String);
      }
    }
    
    // Try alternative field names
    tripStatusNumeric ??= json['trip_status_id'] as int?;
    tripStatusNumeric ??= json['tripStatusId'] as int?;
    tripStatusNumeric ??= json['trip_status'] as int?;
    tripStatusNumeric ??= json['tripStatus'] as int?;
    tripStatusNumeric ??= json['Status'] as int?;
    tripStatusNumeric ??= json['status'] is int ? json['status'] as int : null;
    
    // If status is a string, try to parse it
    if (tripStatusNumeric == null && json['status'] is String) {
      final statusStr = (json['status'] as String).toLowerCase();
      // Map common status strings to numeric values
      switch (statusStr) {
        case 'trip requested':
        case 'requested':
          tripStatusNumeric = 1;
          break;
        case 'trip scheduled':
        case 'scheduled':
          tripStatusNumeric = 2;
          break;
        case 'trip cancelled':
        case 'cancelled':
          tripStatusNumeric = 3;
          break;
        case 'trip started':
        case 'started':
          tripStatusNumeric = 4;
          break;
        case 'trip completed':
        case 'completed':
          tripStatusNumeric = 5;
          break;
        case 'expat confirmation pending':
        case 'expatconfirmationpending':
          tripStatusNumeric = 6;
          break;
        case 'expat approved':
        case 'expatapproved':
          tripStatusNumeric = 7;
          break;
        case 'expat rejected':
        case 'expatrejected':
          tripStatusNumeric = 8;
          break;
      }
    }
    
    // Use new API format if available, otherwise fall back to old format
    return TripDetailModel(
      id: tripId,
      // For adhoc/request trips, we may not have a vehicle yet.
      // In that case, show TripName as the main title and TripRequestId as ID.
      vehicleId: vehicleNo ?? json['vehicle_id'] ?? json['vehicleId'] ?? tripId,
      vehicleName: vehicleNo ?? tripName ?? json['vehicle_name'] ?? json['vehicleName'] ?? '',
      route: tripType ?? json['route'] as String?,
      customer: json['customer'] as String?,
      // Show both pickup and drop locations if available
      location: pickupLocation != null && dropLocation != null
          ? '$pickupLocation → $dropLocation'
          : pickupLocation ?? dropLocation ?? json['location'] as String?,
      pickupDrop: pickupLocation != null && dropLocation != null
          ? '$pickupLocation → $dropLocation'
          : json.getStringSafe('pickup_drop') ??
            json.getStringSafe('pickupDrop'),
      mobileNo: json.getStringSafe('MobileNo') ??
                json.getStringSafe('mobile_no') ??
                json.getStringSafe('mobileNo'),
      tripType: tripType ??
                json.getStringSafe('route'),
      scheduleStart: json.getDateTimeSafe('TripStartDate') ??
                      json.getDateTimeSafe('trip_start_date') ??
                      json.getDateTimeSafe('tripStartDate') ??
                      json.getDateTimeSafe('schedule_start') ??
                      json.getDateTimeSafe('scheduleStart') ??
                      DateTime.now(),
      scheduleEnd: json.getDateTimeSafe('TripEndDate') ??
                   json.getDateTimeSafe('trip_end_date') ??
                   json.getDateTimeSafe('tripEndDate') ??
                   json.getDateTimeSafe('schedule_end') ??
                   json.getDateTimeSafe('scheduleEnd'),
      actualStart: json.getDateTimeSafe('actual_start') ??
                   json.getDateTimeSafe('actualStart'),
      actualEnd: json.getDateTimeSafe('actual_end') ??
                 json.getDateTimeSafe('actualEnd'),
      status: tripStatusString != null
          ? converter.fromJson(tripStatusString)
          : converter.fromJson(json['status'] as String? ?? 'scheduled'),
      tripStatus: tripStatusNumeric,
      tripStartOdometer: json.getIntSafe('trip_start_odometer') ??
                         json.getIntSafe('tripStartOdometer'),
      tripEndOdometer: json.getIntSafe('trip_end_odometer') ??
                       json.getIntSafe('tripEndOdometer'),
      driverId: json.getStringSafe('DriverId') ??
                json.getStringSafe('driver_id') ??
                json.getStringSafe('driverId'),
      driverName: driverName ??
                  json.getStringSafe('driver_name') ??
                  json.getStringSafe('driverName'),
      driverMobileNo: json.getStringSafe('Driver MobileNo') ??
                      json.getStringSafe('DriverMobileNo') ??
                      json.getStringSafe('driver_mobile_no'),
      expatName: json.getStringSafe('ExpatName') ??
                 json.getStringSafe('expat_name') ??
                 json.getStringSafe('expatName'),
      filePath: json.getStringSafe('FilePath') ??
                json.getStringSafe('file_path') ??
                json.getStringSafe('filePath'),
      createdAt: json.getDateTimeSafe('TripStartDate') ??
                 json.getDateTimeSafe('created_at') ??
                 json.getDateTimeSafe('createdAt') ??
                 DateTime.now(),
      updatedAt: json.getDateTimeSafe('updated_at') ??
                 json.getDateTimeSafe('updatedAt'),
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
      if (scheduleEnd != null) 'schedule_end': scheduleEnd!.toIso8601String(),
      if (actualStart != null) 'actual_start': actualStart!.toIso8601String(),
      if (actualEnd != null) 'actual_end': actualEnd!.toIso8601String(),
      'status': converter.toJson(status),
      if (tripStatus != null) 'trip_status': tripStatus,
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
      mobileNo: mobileNo,
      tripType: route,
      scheduleStart: scheduleStart,
      scheduleEnd: scheduleEnd,
      actualStart: actualStart,
      actualEnd: actualEnd,
      status: status,
      tripStatus: tripStatus,
      tripStartOdometer: tripStartOdometer,
      tripEndOdometer: tripEndOdometer,
      driverId: driverId,
      driverName: driverName,
      driverMobileNo: driverMobileNo,
      expatName: expatName,
      filePath: filePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

