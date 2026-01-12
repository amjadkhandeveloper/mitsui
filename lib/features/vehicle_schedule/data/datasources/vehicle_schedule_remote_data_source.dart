import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_data_service.dart';
import '../models/trip_model.dart';
import '../models/free_slot_model.dart';
import '../../domain/entities/trip.dart';

abstract class VehicleScheduleRemoteDataSource {
  Future<List<TripModel>> getTrips({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TripModel> updateTripStatus(String tripId, TripStatus status);
  Future<FreeSlotModel> createFreeSlot(Map<String, dynamic> slotData);
  Future<List<FreeSlotModel>> getFreeSlots({DateTime? date});
}

class VehicleScheduleRemoteDataSourceImpl
    implements VehicleScheduleRemoteDataSource {
  final Dio dio;

  VehicleScheduleRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TripModel>> getTrips({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return MockDataService.getMockTrips(date: date);
    }

    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date.toIso8601String();
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await dio.get(
        '/trips',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => TripModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch trips');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch trips',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<TripModel> updateTripStatus(String tripId, TripStatus status) async {
    try {
      final response = await dio.patch(
        '/trips/$tripId/status',
        data: {'status': status.name},
      );

      if (response.statusCode == 200) {
        return TripModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw ServerException('Failed to update trip status');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to update trip status',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<FreeSlotModel> createFreeSlot(Map<String, dynamic> slotData) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      final now = DateTime.now();
      final startDate = DateTime.parse(slotData['start_date']);
      final startTime = DateTime.parse(slotData['start_time']);
      final endTime = DateTime.parse(slotData['end_time']);
      return FreeSlotModel(
        id: 'free_slot_${now.millisecondsSinceEpoch}',
        vehicleId: slotData['vehicle_id'] ?? 'V001',
        vehicleName: 'Toyota Camry',
        date: startDate,
        startTime: startTime,
        endTime: endTime,
        createdAt: now,
      );
    }

    try {
      final response = await dio.post(
        '/free-slots',
        data: slotData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FreeSlotModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw ServerException('Failed to create free slot');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to create free slot',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<FreeSlotModel>> getFreeSlots({DateTime? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date.toIso8601String();
      }

      final response = await dio.get(
        '/free-slots',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => FreeSlotModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch free slots');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch free slots',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}

