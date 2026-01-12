import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import '../../../../core/error/exceptions.dart';
import '../models/receipt_model.dart';
import '../../domain/entities/receipt.dart';

abstract class ReceiptRemoteDataSource {
  Future<List<ReceiptModel>> getReceipts({String? driverId, String? status});
  Future<ReceiptModel> createReceipt({
    required ReceiptType type,
    required double amount,
    required String description,
    required DateTime receiptDate,
    File? receiptImage,
    double? fueledLiters,
    int? odometerReading,
  });
}

class ReceiptRemoteDataSourceImpl implements ReceiptRemoteDataSource {
  final Dio dio;

  ReceiptRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ReceiptModel>> getReceipts({
    String? driverId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (driverId != null) queryParams['driver_id'] = driverId;
      if (status != null) queryParams['status'] = status;

      final response = await dio.get(
        '/receipts',
        queryParameters: queryParams,
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
    File? receiptImage,
    double? fueledLiters,
    int? odometerReading,
  }) async {
    try {
      final formData = FormData();

      final typeConverter = ReceiptTypeConverter();
      formData.fields.addAll([
        MapEntry('type', typeConverter.toJson(type)),
        MapEntry('amount', amount.toString()),
        MapEntry('description', description),
        MapEntry('receipt_date', receiptDate.toIso8601String()),
        if (fueledLiters != null) MapEntry('fueled_liters', fueledLiters.toString()),
        if (odometerReading != null) MapEntry('odometer_reading', odometerReading.toString()),
      ]);

      if (receiptImage != null) {
        final fileName = receiptImage.path.split('/').last;
        formData.files.add(
          MapEntry(
            'receipt_image',
            await MultipartFile.fromFile(
              receiptImage.path,
              filename: fileName,
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      final response = await dio.post(
        '/receipts',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReceiptModel.fromJson(
          response.data['data'] ?? response.data,
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
}

