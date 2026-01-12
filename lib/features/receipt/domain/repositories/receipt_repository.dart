import 'dart:io';
import '../../../../core/utils/result.dart';
import '../entities/receipt.dart';

abstract class ReceiptRepository {
  FutureResult<List<Receipt>> getReceipts({String? driverId, String? status});
  FutureResult<Receipt> createReceipt({
    required ReceiptType type,
    required double amount,
    required String description,
    required DateTime receiptDate,
    File? receiptImage,
    double? fueledLiters,
    int? odometerReading,
  });
}

