import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_remote_data_source.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptRemoteDataSource remoteDataSource;

  ReceiptRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResult<List<Receipt>> getReceipts({
    String? driverId,
    String? userId,
    String? status,
  }) async {
    try {
      final receipts = await remoteDataSource.getReceipts(
        driverId: driverId,
        userId: userId,
        status: status,
      );
      return Right(receipts.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  FutureResult<void> updateReceiptStatus({
    required int expenseId,
    required int expenseTypeId,
    required int expenseStatusId,
    required int approvedByUserId,
    required String remark,
  }) async {
    try {
      await remoteDataSource.updateReceiptStatus(
        expenseId: expenseId,
        expenseTypeId: expenseTypeId,
        expenseStatusId: expenseStatusId,
        approvedByUserId: approvedByUserId,
        remark: remark,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final receipt = await remoteDataSource.createReceipt(
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
      return Right(receipt.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }
}

