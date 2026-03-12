import 'dart:io';
import '../../../../core/utils/result.dart';
import '../entities/receipt.dart';

abstract class ReceiptRepository {
  FutureResult<List<Receipt>> getReceipts({
    String? driverId,
    String? userId,
    String? status,
  });
  FutureResult<void> updateReceiptStatus({
    required int expenseId,
    required int expenseTypeId,
    required int expenseStatusId,
    required int approvedByUserId,
    required String remark,
  });
  FutureResult<Receipt> createReceipt({
    required ReceiptType type,
    required double amount,
    required String description,
    required DateTime receiptDate,
    File? receiptImage1,
    File? receiptImage2,
    required int driverId,
    required int zoneId,
    required double lat,
    required double lon,
  });
}

