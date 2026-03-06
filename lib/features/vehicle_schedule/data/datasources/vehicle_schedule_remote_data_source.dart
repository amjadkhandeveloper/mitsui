import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/extensions/json_extensions.dart';
import '../../../../core/mock/mock_data_service.dart';
import '../models/trip_model.dart';
import '../models/free_slot_model.dart';
import '../../domain/entities/trip.dart';

abstract class VehicleScheduleRemoteDataSource {
  Future<List<TripModel>> getTrips({
    String? userId,
    String? driverId,
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
    String? userId,
    String? driverId,
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
      // Resolve user_id / driver_id similar to TripDetails API:
      // - If expat:  user_id = <userid>, driver_id = "0"
      // - If driver: user_id = "0",       driver_id = <driverid>
      String resolvedUserId = '0';
      String resolvedDriverId = '0';
      if (userId != null && userId.isNotEmpty) {
        resolvedUserId = userId;
        resolvedDriverId = '0';
      } else if (driverId != null && driverId.isNotEmpty) {
        resolvedUserId = '0';
        resolvedDriverId = driverId;
      }

      // Call TripListRequest API (same as trip list) for all trips; we will filter by date in the cubit.
      final response = await dio.post(
        ApiConstants.tripListRequest,
        data: {
          'user_id': resolvedUserId,
          'driver_id': resolvedDriverId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final apiStatus = responseData['status'];
        final apiMessage = responseData['message'] as String?;

        if ((apiStatus == 200 || apiStatus == 1 || apiStatus == 'success') &&
            responseData['data'] != null) {
          final List<dynamic> data = responseData['data'] as List<dynamic>;

          return data.map((raw) {
            final json = raw as Map<String, dynamic>;

            // Map TripListRequest fields to TripModel fields using safe extensions
            final tripRequestId = json.getStringOr('TripRequestId', '');
            final tripName = json.getStringOr('TripName', '');

            final startDateTime = json.getDateTimeSafe('TripStartDate') ?? DateTime.now();
            final endDateTime = json.getDateTimeSafe('TripEndDate') ?? startDateTime;

            // Map string status to simple TripStatus
            final statusStr = (json.getStringSafe('Trip Status') ??
                              json.getStringSafe('TripStatus') ??
                              '').toLowerCase();
            TripStatus status;
            if (statusStr.contains('approved')) {
              status = TripStatus.accepted;
            } else if (statusStr.contains('rejected')) {
              status = TripStatus.rejected;
            } else {
              // Pending / confirmation pending / requested
              status = TripStatus.pending;
            }

            // Extract additional fields from API response using safe extensions
            final driverId = json.getStringSafe('DriverId');
            final driverName = json.getStringSafe('DriverName');
            final mobileNo = json.getStringSafe('MobileNo');
            final tripType = json.getStringSafe('TripType');
            final pickupLocation = json.getStringOr('PickupLocation', '');
            final dropLocation = json.getStringOr('DropLocation', '');
            final destination = pickupLocation.isNotEmpty && dropLocation.isNotEmpty
                ? '$pickupLocation → $dropLocation'
                : (pickupLocation.isNotEmpty ? pickupLocation : dropLocation);

            // Create TripModel directly
            return TripModel(
              id: tripRequestId,
              vehicleId: tripRequestId,
              vehicleName: tripName,
              date: DateTime(startDateTime.year, startDateTime.month, startDateTime.day),
              startTime: startDateTime,
              endTime: endDateTime,
              status: status,
              driverId: driverId,
              driverName: driverName,
              mobileNo: mobileNo,
              tripType: tripType,
              destination: destination.isNotEmpty ? destination : null,
              purpose: null,
              createdAt: startDateTime,
              updatedAt: null,
            );
          }).toList();
        } else {
          throw ServerException(apiMessage ?? 'Failed to fetch trips');
        }
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

