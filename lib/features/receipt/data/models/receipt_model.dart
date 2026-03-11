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

int _mapTypeToExpenseTypeId(ReceiptType type) {
  switch (type) {
    case ReceiptType.fuel:
      return 2;
    case ReceiptType.parking:
      return 3;
    case ReceiptType.toll:
      return 4;
    case ReceiptType.other:
      return 5;
  }
}

class ReceiptModel extends Receipt {
  const ReceiptModel({
    required super.id,
    required super.type,
    required super.expenseTypeId,
    super.expenseId,
    super.vehicleId,
    super.expenseStatusId,
    super.lat,
    super.lon,
    super.expLocation,
    super.receiptImageUrl2,
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

  static ReceiptType _typeFromExpenseTypeId(int? expenseTypeId) {
    switch (expenseTypeId) {
      case 1:
      case 2:
        return ReceiptType.fuel;
      case 3:
        return ReceiptType.parking;
      case 4:
        return ReceiptType.toll;
      case 5:
        return ReceiptType.other;
      default:
        return ReceiptType.other;
    }
  }

  /// Expense list API: 1 = approved, 2 = pending, 3 = rejected
  static ReceiptStatus _statusFromExpenseStatusId(int? expenseStatusId) {
    switch (expenseStatusId) {
      case 1:
        return ReceiptStatus.approved;
      case 2:
        return ReceiptStatus.pending;
      case 3:
        return ReceiptStatus.rejected;
      default:
        return ReceiptStatus.pending;
    }
  }

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    // Support Mitsui "Expense" receipt JSON shape:
    // { ID, DriverID, VehicleID, ExpenseTypeID, ExpenseStatusID, ExpenseDt, Lat, Lon,
    //   ExpLocation, ExpenseReceipt1, ExpenseReceipt2, ExpenseDesc, ExpenseRemark, expenseamount, ... }
    final isExpenseShape = json.containsKey('ID') ||
        json.containsKey('ExpenseTypeID') ||
        json.containsKey('ExpenseDt') ||
        json.containsKey('expenseamount');

    if (isExpenseShape) {
      final expenseIdRaw = json['ID'];
      final expenseTypeIdRaw = json['ExpenseTypeID'] ?? json['expenseTypeId'];
      final expenseStatusIdRaw = json['ExpenseStatusID'] ?? json['expenseStatusId'];

      final int? expenseId = expenseIdRaw is num
          ? expenseIdRaw.toInt()
          : int.tryParse(expenseIdRaw?.toString() ?? '');
      final int? expenseTypeId = expenseTypeIdRaw is num
          ? expenseTypeIdRaw.toInt()
          : int.tryParse(expenseTypeIdRaw?.toString() ?? '');
      final int? expenseStatusId = expenseStatusIdRaw is num
          ? expenseStatusIdRaw.toInt()
          : int.tryParse(expenseStatusIdRaw?.toString() ?? '');

      final vehicleIdRaw = json['VehicleID'] ?? json['vehicleId'];
      final int? vehicleId = vehicleIdRaw is num
          ? vehicleIdRaw.toInt()
          : int.tryParse(vehicleIdRaw?.toString() ?? '');

      final driverIdRaw = json['DriverID'] ?? json['driverId'];
      final driverId = driverIdRaw?.toString();

      final amountRaw = json['expenseamount'] ?? json['Amount'] ?? json['amount'];
      final double amount = amountRaw is num
          ? amountRaw.toDouble()
          : double.tryParse(amountRaw?.toString() ?? '') ?? 0;

      final expLocation = (json['ExpLocation'] ?? json['expLocation'])?.toString();
      final receipt1 = (json['ExpenseReceipt1'] ?? json['expenseReceipt1'])?.toString();
      final receipt2 = (json['ExpenseReceipt2'] ?? json['expenseReceipt2'])?.toString();

      final desc = (json['ExpenseDesc'] ?? json['expenseDesc'])?.toString();
      final remark = (json['ExpenseRemark'] ?? json['expenseRemark'])?.toString();
      final description = (desc != null && desc.trim().isNotEmpty)
          ? desc
          : (remark != null && remark.trim().isNotEmpty)
              ? remark
              : (expLocation != null && expLocation.trim().isNotEmpty)
                  ? expLocation
                  : 'Expense receipt';

      final dtRaw = (json['ExpenseDt'] ?? json['expenseDt'])?.toString();
      DateTime receiptDate;
      try {
        receiptDate = DateTime.parse(dtRaw ?? DateTime.now().toIso8601String());
      } catch (_) {
        receiptDate = DateTime.now();
      }

      final latRaw = json['Lat'] ?? json['lat'];
      final lonRaw = json['Lon'] ?? json['lon'] ?? json['Lng'] ?? json['lng'];
      final double? lat = latRaw is num ? latRaw.toDouble() : double.tryParse(latRaw?.toString() ?? '');
      final double? lon = lonRaw is num ? lonRaw.toDouble() : double.tryParse(lonRaw?.toString() ?? '');

      final type = _typeFromExpenseTypeId(expenseTypeId);
      final status = _statusFromExpenseStatusId(expenseStatusId);

      return ReceiptModel(
        id: (expenseId ?? json['id'] ?? '').toString(),
        type: type,
        expenseTypeId: expenseTypeId ?? _mapTypeToExpenseTypeId(type),
        expenseId: expenseId,
        vehicleId: vehicleId,
        expenseStatusId: expenseStatusId,
        lat: lat,
        lon: lon,
        expLocation: expLocation,
        receiptImageUrl: (receipt1 != null && receipt1.trim().isNotEmpty) ? receipt1 : null,
        receiptImageUrl2: (receipt2 != null && receipt2.trim().isNotEmpty) ? receipt2 : null,
        amount: amount,
        description: description,
        receiptDate: receiptDate,
        status: status,
        approvedBy: (json['ApproverName'] ?? json['ApprovedBy'] ?? json['approvedBy'])?.toString(),
        submittedAt: receiptDate,
        driverId: driverId,
        driverName: null,
        fueledLiters: null,
        odometerReading: null,
        createdAt: receiptDate,
        updatedAt: null,
      );
    }

    final typeConverter = ReceiptTypeConverter();
    final statusConverter = ReceiptStatusConverter();
    final type = typeConverter.fromJson(json['type'] as String);

    // Support multiple possible keys for expense type id from API; default from type.
    int? expenseTypeId;
    final dynamic rawId = json['expense_type_id'] ??
        json['expenseTypeId'] ??
        json['ExpenseTypeId'] ??
        json['typeId'];
    if (rawId is int) {
      expenseTypeId = rawId;
    } else if (rawId is String && rawId.isNotEmpty) {
      expenseTypeId = int.tryParse(rawId);
    }
    expenseTypeId ??= _mapTypeToExpenseTypeId(type);

    final receiptImageUrl = json['receipt_image_url'] ?? json['receiptImageUrl'] as String?;
    final receiptImageUrl2 = json['receipt_image_url_2'] ?? json['receiptImageUrl2'] as String?;
    return ReceiptModel(
      id: json['id'] as String,
      type: type,
      expenseTypeId: expenseTypeId,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      receiptDate: DateTime.parse(json['receipt_date'] ?? json['receiptDate']),
      status: statusConverter.fromJson(json['status'] as String),
      receiptImageUrl: receiptImageUrl,
      receiptImageUrl2: receiptImageUrl2,
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
      'expense_type_id': expenseTypeId,
      if (expenseId != null) 'expense_id': expenseId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (expenseStatusId != null) 'expense_status_id': expenseStatusId,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (expLocation != null) 'exp_location': expLocation,
      'amount': amount,
      'description': description,
      'receipt_date': receiptDate.toIso8601String(),
      'status': statusConverter.toJson(status),
      if (receiptImageUrl != null) 'receipt_image_url': receiptImageUrl,
      if (receiptImageUrl2 != null) 'receipt_image_url_2': receiptImageUrl2,
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
      expenseTypeId: expenseTypeId,
      expenseId: expenseId,
      vehicleId: vehicleId,
      expenseStatusId: expenseStatusId,
      lat: lat,
      lon: lon,
      expLocation: expLocation,
      receiptImageUrl2: receiptImageUrl2,
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

