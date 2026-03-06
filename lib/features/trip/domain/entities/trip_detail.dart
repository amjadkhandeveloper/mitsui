import 'package:equatable/equatable.dart';

enum TripDetailStatus { scheduled, started, completed, cancelled }

/// Trip Status enum with numeric values
/// Trip Requested = 1, Trip Scheduled = 2, etc.
enum TripStatus {
  tripRequested(1),
  tripScheduled(2),
  tripCancelled(3),
  tripStarted(4),
  tripCompleted(5),
  expatConfirmationPending(6),
  expatApproved(7),
  expatRejected(8),
  vehicleReassigned(9),
  vehicleBreakdown(10),
  tripStartedByAdmin(11),
  tripCompletedByAdmin(12);

  final int value;
  const TripStatus(this.value);

  static TripStatus? fromValue(int? value) {
    if (value == null) return null;
    try {
      return TripStatus.values.firstWhere((status) => status.value == value);
    } catch (e) {
      return null;
    }
  }

  String get displayName {
    switch (this) {
      case TripStatus.tripRequested:
        return 'Trip Requested';
      case TripStatus.tripScheduled:
        return 'Trip Scheduled';
      case TripStatus.tripCancelled:
        return 'Trip Cancelled';
      case TripStatus.tripStarted:
        return 'Trip Started';
      case TripStatus.tripCompleted:
        return 'Trip Completed';
      case TripStatus.expatConfirmationPending:
        return 'Expat Confirmation Pending';
      case TripStatus.expatApproved:
        return 'Expat Approved';
      case TripStatus.expatRejected:
        return 'Expat Rejected';
      case TripStatus.vehicleReassigned:
        return 'Vehicle Reassigned';
      case TripStatus.vehicleBreakdown:
        return 'Vehicle Breakdown';
      case TripStatus.tripStartedByAdmin:
        return 'Trip Started By Admin';
      case TripStatus.tripCompletedByAdmin:
        return 'Trip Completed By Admin';
    }
  }
}

class TripDetail extends Equatable {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String? route;
  final String? customer;
  final String? location;
  final String? pickupDrop; // "PICK UP" or "DROP"
  final String? mobileNo; // Driver / user mobile number
  final String? tripType; // regular / adhoc etc.
  final DateTime scheduleStart;
  final DateTime? scheduleEnd; // End date
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final TripDetailStatus status;
  final int? tripStatus; // Numeric trip status (1-12)
  final int? tripStartOdometer;
  final int? tripEndOdometer;
  final String? driverId;
  final String? driverName;
  final String? driverMobileNo;
  final String? expatName;
  /// Relative path for adhoc trip PDF document; full URL = tripDocumentBaseUrl + filePath
  final String? filePath;
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
    this.mobileNo,
    this.tripType,
    required this.scheduleStart,
    this.scheduleEnd,
    this.actualStart,
    this.actualEnd,
    required this.status,
    this.tripStatus,
    this.tripStartOdometer,
    this.tripEndOdometer,
    this.driverId,
    this.driverName,
    this.driverMobileNo,
    this.expatName,
    this.filePath,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if accept/reject buttons should be shown
  /// Returns true if tripStatus is 1 (Trip Requested), 2 (Trip Scheduled), or 6 (Expat Confirmation Pending)
  bool get shouldShowAcceptRejectButtons {
    return tripStatus == 1 || tripStatus == 2 || tripStatus == 6;
  }

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        vehicleName,
        route,
        customer,
        location,
        pickupDrop,
        mobileNo,
        tripType,
        scheduleStart,
        scheduleEnd,
        actualStart,
        actualEnd,
        status,
        tripStatus,
        tripStartOdometer,
        tripEndOdometer,
        driverId,
        driverName,
        driverMobileNo,
        expatName,
        filePath,
        createdAt,
        updatedAt,
      ];
}

