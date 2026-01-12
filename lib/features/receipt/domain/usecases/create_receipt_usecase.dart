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
    File? receiptImage,
    double? fueledLiters,
    int? odometerReading,
  }) async {
    return await repository.createReceipt(
      type: type,
      amount: amount,
      description: description,
      receiptDate: receiptDate,
      receiptImage: receiptImage,
      fueledLiters: fueledLiters,
      odometerReading: odometerReading,
    );
  }
}

