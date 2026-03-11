import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/usecases/get_receipts_usecase.dart';
import '../../domain/usecases/create_receipt_usecase.dart';
import '../../domain/usecases/update_receipt_status_usecase.dart';

part 'receipt_state.dart';

class ReceiptCubit extends Cubit<ReceiptState> {
  final GetReceiptsUseCase getReceiptsUseCase;
  final CreateReceiptUseCase createReceiptUseCase;
  final UpdateReceiptStatusUseCase updateReceiptStatusUseCase;

  ReceiptCubit({
    required this.getReceiptsUseCase,
    required this.createReceiptUseCase,
    required this.updateReceiptStatusUseCase,
  }) : super(ReceiptInitial());

  Future<void> loadReceipts({
    String? driverId,
    String? userId,
    String? status,
  }) async {
    emit(ReceiptLoading());
    final result = await getReceiptsUseCase(
      driverId: driverId,
      userId: userId,
      status: status,
    );
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
    File? receiptImage1,
    File? receiptImage2,
    required int driverId,
    required int zoneId,
    required double lat,
    required double lon,
  }) async {
    emit(ReceiptSubmitting());
    final result = await createReceiptUseCase(
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
    result.fold(
      (failure) => emit(ReceiptError(failure.message)),
      (receipt) {
        emit(ReceiptCreated(receipt: receipt));
        // Reload receipts
        loadReceipts();
      },
    );
  }

  Future<void> approveReceipt({
    required int expenseId,
    required int approvedByUserId,
    String? remark,
  }) async {
    emit(ReceiptSubmitting());
    final result = await updateReceiptStatusUseCase(
      expenseId: expenseId,
      expenseStatusId: 1, // 1 = approved
      approvedByUserId: approvedByUserId,
      remark: remark,
    );
    result.fold(
      (failure) => emit(ReceiptError(failure.message)),
      (_) {
        emit(const ReceiptStatusUpdated());
        loadReceipts();
      },
    );
  }

  Future<void> rejectReceipt({
    required int expenseId,
    required int approvedByUserId,
    required String remark,
  }) async {
    emit(ReceiptSubmitting());
    final result = await updateReceiptStatusUseCase(
      expenseId: expenseId,
      expenseStatusId: 3, // 3 = rejected
      approvedByUserId: approvedByUserId,
      remark: remark,
    );
    result.fold(
      (failure) => emit(ReceiptError(failure.message)),
      (_) {
        emit(const ReceiptStatusUpdated());
        loadReceipts();
      },
    );
  }
}

