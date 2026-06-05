import 'package:equatable/equatable.dart';

enum ReceiptType { fuel, parking, toll, other }
enum ReceiptStatus { pending, approved, rejected }

class Receipt extends Equatable {
  final String id;
  final ReceiptType type;
  /// Expense type id mapping (latest backend values):
  /// 1 = Fuel, 2 = Parking, 3 = Toll Fee, 4 = Other
  final int expenseTypeId;
  // Raw backend ids (Expense module)
  final int? expenseId;
  final int? vehicleId;
  final int? expenseStatusId;
  final double? lat;
  final double? lon;
  final String? expLocation;
  final String? receiptImageUrl2;
  final double amount;
  final String description;
  final DateTime receiptDate;
  final ReceiptStatus status;
  final String? receiptImageUrl;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final DateTime submittedAt;
  final String? driverId;
  final String? driverName;
  // Fuel-specific fields
  final double? fueledLiters;
  final int? odometerReading;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Receipt({
    required this.id,
    required this.type,
    required this.expenseTypeId,
    this.expenseId,
    this.vehicleId,
    this.expenseStatusId,
    this.lat,
    this.lon,
    this.expLocation,
    this.receiptImageUrl2,
    required this.amount,
    required this.description,
    required this.receiptDate,
    required this.status,
    this.receiptImageUrl,
    this.approvedBy,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    required this.submittedAt,
    this.driverId,
    this.driverName,
    this.fueledLiters,
    this.odometerReading,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        expenseTypeId,
        expenseId,
        vehicleId,
        expenseStatusId,
        lat,
        lon,
        expLocation,
        receiptImageUrl2,
        amount,
        description,
        receiptDate,
        status,
        receiptImageUrl,
        approvedBy,
        approvedAt,
        rejectedAt,
        rejectionReason,
        submittedAt,
        driverId,
        driverName,
        fueledLiters,
        odometerReading,
        createdAt,
        updatedAt,
      ];
}

