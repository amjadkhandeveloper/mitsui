import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_data_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/receipt_model.dart';
import '../../domain/entities/receipt.dart';

abstract class ReceiptRemoteDataSource {
  Future<List<ReceiptModel>> getReceipts({
    String? driverId,
    String? userId,
    String? status,
  });
  Future<ReceiptModel> createReceipt({
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
  Future<void> updateReceiptStatus({
    required int expenseId,
    required int expenseTypeId,
    required int expenseStatusId,
    required int approvedByUserId,
    required String remark,
  });
}

class ReceiptRemoteDataSourceImpl implements ReceiptRemoteDataSource {
  final Dio dio;

  ReceiptRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ReceiptModel>> getReceipts({
    String? driverId,
    String? userId,
    String? status,
  }) async {
    // Use mock data if enabled for receipt
    if (AppConfig.USE_MOCK_DATA || AppConfig.USE_MOCK_DATA_RECEIPT) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      var receipts = MockDataService.getMockReceipts(driverId: driverId);
      if (status != null) {
        receipts = receipts.where((r) => r.status.name == status).toList();
      }
      return receipts;
    }

    try {
      final intDriverId = int.tryParse(driverId ?? '') ?? 0;
      final intUserId = int.tryParse(userId ?? '') ?? 0;

      final response = await dio.post(
        ApiConstants.receiptList,
        data: {
          'driverId': intDriverId,
          'userId': intUserId,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ReceiptModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch receipts');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch receipts',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<ReceiptModel> createReceipt({
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
      final expenseTypeId = _mapTypeToExpenseTypeId(type);

      String encodeFileToBase64(File? file) {
        if (file == null) return '';
        final bytes = file.readAsBytesSync();
        return base64Encode(bytes);
      }

      final body = {
        'insertMode': 1, // 1 = insert
        'expenseID': 0,
        'driverID': driverId,
        'vehicleID': 1,
        'zoneID': zoneId,
        'expenseTypeID': expenseTypeId,
        'expenseStatusID': 2,
        'approvedByUserId': 0,
        'expenseDt': receiptDate.toIso8601String(),
        'lat': lat,
        'lon': lon,
        'expLocation': '',
        // Send up to two images as base64 strings (second can be empty).
        'expenseReceipt1': encodeFileToBase64(receiptImage1),
        'expenseReceipt2': encodeFileToBase64(receiptImage2),
        'expenseRemark': description,
        'expenseAmount': amount,
        'userID': 0,
      };

      final response = await dio.post(
        ApiConstants.expenseDetails,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic payload = (data is Map<String, dynamic>) ? data['data'] : null;

        if (payload != null) {
          return ReceiptModel.fromJson(payload as Map<String, dynamic>);
        }

        // Backend can return { status:200, message:'Success', data:null }.
        // In that case, build a local model using the request body so UI
        // can still show the created receipt without crashing.
        final now = DateTime.now();
        return ReceiptModel(
          id: '', // no id from backend
          type: type,
          expenseTypeId: expenseTypeId,
          expenseId: null,
          vehicleId: null,
          expenseStatusId: 0,
          lat: body['lat'] as double?,
          lon: body['lon'] as double?,
          expLocation: body['expLocation'] as String?,
          receiptImageUrl: body['expenseReceipt1'] as String?,
          receiptImageUrl2: body['expenseReceipt2'] as String?,
          amount: amount,
          description: description,
          receiptDate: receiptDate,
          status: ReceiptStatus.pending,
          approvedBy: null,
          submittedAt: now,
          driverId: driverId.toString(),
          driverName: null,
          fueledLiters: null,
          odometerReading: null,
          createdAt: now,
          updatedAt: null,
        );
      } else {
        throw ServerException('Failed to create receipt');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to create receipt',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> updateReceiptStatus({
    required int expenseId,
    required int expenseTypeId,
    required int expenseStatusId,
    required int approvedByUserId,
    required String remark,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.receiptStatusUpdate,
        data: {
          'expenseID': expenseId,
          'expenseTypeID': expenseTypeId,
          'approvedByUserId': approvedByUserId,
          'expenseRemark': remark,
          'expenseStatusID': expenseStatusId,
        },
      );

      final data = response.data;
      final status = (data is Map<String, dynamic>) ? data['status'] : null;
      if (response.statusCode == 200 || status == 200) {
        return;
      }
      throw ServerException('Failed to update receipt status');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to update receipt status',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
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

