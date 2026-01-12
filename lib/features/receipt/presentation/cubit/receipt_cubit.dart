import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/usecases/get_receipts_usecase.dart';
import '../../domain/usecases/create_receipt_usecase.dart';

part 'receipt_state.dart';

class ReceiptCubit extends Cubit<ReceiptState> {
  final GetReceiptsUseCase getReceiptsUseCase;
  final CreateReceiptUseCase createReceiptUseCase;

  ReceiptCubit({
    required this.getReceiptsUseCase,
    required this.createReceiptUseCase,
  }) : super(ReceiptInitial());

  Future<void> loadReceipts({String? driverId, String? status}) async {
    emit(ReceiptLoading());
    final result = await getReceiptsUseCase(driverId: driverId, status: status);
    result.fold(
      (failure) => emit(ReceiptError(failure.message)),
      (receipts) {
        final total = receipts.length;
        final approved = receipts.where((r) => r.status == ReceiptStatus.approved).length;
        final pending = receipts.where((r) => r.status == ReceiptStatus.pending).length;
        emit(ReceiptsLoaded(
          receipts: receipts,
          total: total,
          approved: approved,
          pending: pending,
        ));
      },
    );
  }

  Future<void> createReceipt({
    required ReceiptType type,
    required double amount,
    required String description,
    required DateTime receiptDate,
    File? receiptImage,
    double? fueledLiters,
    int? odometerReading,
  }) async {
    emit(ReceiptSubmitting());
    final result = await createReceiptUseCase(
      type: type,
      amount: amount,
      description: description,
      receiptDate: receiptDate,
      receiptImage: receiptImage,
      fueledLiters: fueledLiters,
      odometerReading: odometerReading,
    );
    result.fold(
      (failure) => emit(ReceiptError(failure.message)),
      (receipt) {
        emit(ReceiptCreated(receipt: receipt));
        // Reload receipts
        loadReceipts();
      },
    );
  }
}

