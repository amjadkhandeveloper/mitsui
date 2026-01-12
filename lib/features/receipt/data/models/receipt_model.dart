import '../../domain/entities/receipt.dart';

class ReceiptTypeConverter {
  ReceiptType fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'fuel':
        return ReceiptType.fuel;
      case 'parking':
        return ReceiptType.parking;
      case 'toll':
        return ReceiptType.toll;
      case 'other':
        return ReceiptType.other;
      default:
        return ReceiptType.other;
    }
  }

  String toJson(ReceiptType object) {
    switch (object) {
      case ReceiptType.fuel:
        return 'fuel';
      case ReceiptType.parking:
        return 'parking';
      case ReceiptType.toll:
        return 'toll';
      case ReceiptType.other:
        return 'other';
    }
  }
}

class ReceiptStatusConverter {
  ReceiptStatus fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'pending':
        return ReceiptStatus.pending;
      case 'approved':
        return ReceiptStatus.approved;
      case 'rejected':
        return ReceiptStatus.rejected;
      default:
        return ReceiptStatus.pending;
    }
  }

  String toJson(ReceiptStatus object) {
    switch (object) {
      case ReceiptStatus.pending:
        return 'pending';
      case ReceiptStatus.approved:
        return 'approved';
      case ReceiptStatus.rejected:
        return 'rejected';
    }
  }
}

class ReceiptModel extends Receipt {
  const ReceiptModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.description,
    required super.receiptDate,
    required super.status,
    super.receiptImageUrl,
    super.approvedBy,
    super.approvedAt,
    super.rejectedAt,
    super.rejectionReason,
    required super.submittedAt,
    super.driverId,
    super.driverName,
    super.fueledLiters,
    super.odometerReading,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    final typeConverter = ReceiptTypeConverter();
    final statusConverter = ReceiptStatusConverter();
    return ReceiptModel(
      id: json['id'] as String,
      type: typeConverter.fromJson(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      receiptDate: DateTime.parse(json['receipt_date'] ?? json['receiptDate']),
      status: statusConverter.fromJson(json['status'] as String),
      receiptImageUrl: json['receipt_image_url'] ?? json['receiptImageUrl'] as String?,
      approvedBy: json['approved_by'] ?? json['approvedBy'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : json['approvedAt'] as DateTime?,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : json['rejectedAt'] as DateTime?,
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] ?? json['submittedAt']),
      driverId: json['driver_id'] ?? json['driverId'] as String?,
      driverName: json['driver_name'] ?? json['driverName'] as String?,
      fueledLiters: json['fueled_liters'] != null
          ? (json['fueled_liters'] as num).toDouble()
          : json['fueledLiters'] != null
              ? (json['fueledLiters'] as num).toDouble()
              : null,
      odometerReading: json['odometer_reading'] ?? json['odometerReading'] as int?,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] as DateTime?,
    );
  }

  Map<String, dynamic> toJson() {
    final typeConverter = ReceiptTypeConverter();
    final statusConverter = ReceiptStatusConverter();
    return {
      'id': id,
      'type': typeConverter.toJson(type),
      'amount': amount,
      'description': description,
      'receipt_date': receiptDate.toIso8601String(),
      'status': statusConverter.toJson(status),
      if (receiptImageUrl != null) 'receipt_image_url': receiptImageUrl,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (approvedAt != null) 'approved_at': approvedAt!.toIso8601String(),
      if (rejectedAt != null) 'rejected_at': rejectedAt!.toIso8601String(),
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      'submitted_at': submittedAt.toIso8601String(),
      if (driverId != null) 'driver_id': driverId,
      if (driverName != null) 'driver_name': driverName,
      if (fueledLiters != null) 'fueled_liters': fueledLiters,
      if (odometerReading != null) 'odometer_reading': odometerReading,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Receipt toEntity() {
    return Receipt(
      id: id,
      type: type,
      amount: amount,
      description: description,
      receiptDate: receiptDate,
      status: status,
      receiptImageUrl: receiptImageUrl,
      approvedBy: approvedBy,
      approvedAt: approvedAt,
      rejectedAt: rejectedAt,
      rejectionReason: rejectionReason,
      submittedAt: submittedAt,
      driverId: driverId,
      driverName: driverName,
      fueledLiters: fueledLiters,
      odometerReading: odometerReading,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

