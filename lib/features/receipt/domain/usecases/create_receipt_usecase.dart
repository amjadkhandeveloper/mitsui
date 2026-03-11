import 'dart:io';
import '../../../../core/utils/result.dart';
import '../entities/receipt.dart';
import '../repositories/receipt_repository.dart';

class CreateReceiptUseCase {
  final ReceiptRepository repository;

  CreateReceiptUseCase({required this.repository});

  FutureResult<Receipt> call({
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
  }) async {
    return await repository.createReceipt(
      type: type,
      amount: amount,
      description: description,
      receiptDate: receiptDate,
      receiptImage1: receiptImage1,
      receiptImage2: receiptImage2,
      driverId: driverId,
      zoneId: zoneId,
      lat: lat,
      lon: lon,
    );
  }
}

