import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/mock/mock_data_service.dart';
import '../models/trip_detail_model.dart';
import '../../domain/entities/trip_detail.dart';

abstract class TripRemoteDataSource {
  Future<List<TripDetailModel>> getTrips({
    String? userId,
    String? driverId,
    String? status,
  });
  Future<TripDetailModel> getTripDetail(String tripId);
  Future<TripDetailModel> startTrip(String tripId, int startOdometer);
  Future<TripDetailModel> endTrip(String tripId, int endOdometer);
  Future<void> splitTrip(String tripId, TripDetail originalTrip);
  Future<String> updateVehicleApproveStatus({
    required String tripRequestId,
    required int approvedStatus, // 1 for approve, 0 for reject
    required String approvedBy, // user ID of expat
  });
  Future<String> cancelTrip({
    required String tripId,
    required String userId,
    required String remarks,
  });
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;

  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TripDetailModel>> getTrips({
    String? userId,
    String? driverId,
    String? status,
  }) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return MockDataService.getMockTripDetails(driverId: driverId);
    }

    try {
      // Use TripDetails API to load all trips for the user.
      // Backend expects both user_id and driver_id:
      // - If expat:  user_id = <userid>, driver_id = "0"
      // - If driver: user_id = "0",       driver_id = <userid>
      String resolvedUserId = '0';
      String resolvedDriverId = '0';
      if (userId != null && userId.isNotEmpty) {
        resolvedUserId = userId;
        resolvedDriverId = '0';
      } else if (driverId != null && driverId.isNotEmpty) {
        resolvedUserId = '0';
        resolvedDriverId = driverId;
      }

      final response = await dio.post(
        ApiConstants.tripDetails,
        data: {
          'user_id': resolvedUserId,
          'driver_id': resolvedDriverId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final apiStatus = responseData['status'];
        final apiMessage = responseData['message'] as String?;

        // Check if API returned success status
        // Expected API response format:
        // {
        //   "status": 200,
        //   "message": "Success",
        //   "data": [
        //     {
        //       "TripID": "string",
        //       "UserName": "string",
        //       "VehicleNo": "string",
        //       "TripStartDate": "string",
        //       "TripEndDate": "string",
        //       "PickupLocation": "string",
        //       "DropLocation": "string",
        //       "TripType": "string",
        //       "TripStatus": 1-12 (int) or "string"
        //     }
        //   ]
        // }
        if ((apiStatus == 200 || apiStatus == 1 || apiStatus == 'success') &&
            responseData['data'] != null) {
          final List<dynamic> data = responseData['data'] as List<dynamic>;
          return data.map((json) => TripDetailModel.fromJson(json)).toList();
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
        final responseData = e.response?.data;
        final message = responseData is Map
            ? (responseData['message'] ?? 'Failed to fetch trips')
            : 'Failed to fetch trips';
        throw ServerException(message);
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<TripDetailModel> getTripDetail(String tripId) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      final trips = MockDataService.getMockTripDetails();
      return trips.firstWhere(
        (t) => t.id == tripId,
        orElse: () => trips.first,
      );
    }

    try {
      final response = await dio.get('/trips/$tripId');

      if (response.statusCode == 200) {
        return TripDetailModel.fromJson(
          response.data['data'] ?? response.data,
        );
      } else {
        throw ServerException('Failed to fetch trip detail');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to fetch trip detail',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<TripDetailModel> startTrip(String tripId, int startOdometer) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      final now = DateTime.now();
      return TripDetailModel(
        id: tripId,
        vehicleId: 'AP39UD6009',
        vehicleName: 'Toyota Camry',
        route: 'NA',
        customer: 'TESCO',
        location: 'Silkboard',
        pickupDrop: 'PICK UP',
        scheduleStart: DateTime(now.year, now.month, now.day, 18, 30),
        actualStart: now,
        status: TripDetailStatus.started,
        tripStartOdometer: startOdometer,
        createdAt: now.subtract(const Duration(days: 1)),
      );
    }

    try {
      final response = await dio.post(
        '/trips/$tripId/start',
        data: {'trip_start_odometer': startOdometer},
      );

      if (response.statusCode == 200) {
        return TripDetailModel.fromJson(
          response.data['data'] ?? response.data,
        );
      } else {
        throw ServerException('Failed to start trip');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to start trip',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<TripDetailModel> endTrip(String tripId, int endOdometer) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      final now = DateTime.now();
      return TripDetailModel(
        id: tripId,
        vehicleId: 'AP39UD6009',
        vehicleName: 'Toyota Camry',
        route: 'NA',
        customer: 'TESCO',
        location: 'Silkboard',
        pickupDrop: 'PICK UP',
        scheduleStart: DateTime(now.year, now.month, now.day, 18, 30),
        actualStart: DateTime(now.year, now.month, now.day, 18, 35),
        actualEnd: now,
        status: TripDetailStatus.completed,
        tripStartOdometer: 38200,
        tripEndOdometer: endOdometer,
        createdAt: now.subtract(const Duration(days: 1)),
      );
    }

    try {
      final response = await dio.post(
        '/trips/$tripId/end',
        data: {'trip_end_odometer': endOdometer},
      );

      if (response.statusCode == 200) {
        return TripDetailModel.fromJson(
          response.data['data'] ?? response.data,
        );
      } else {
        throw ServerException('Failed to end trip');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to end trip',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> splitTrip(String tripId, TripDetail originalTrip) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Create pickup trip (duplicate with PICK UP)
      final pickupTrip = TripDetailModel(
        id: '${tripId}_pickup_${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: originalTrip.vehicleId,
        vehicleName: originalTrip.vehicleName,
        route: originalTrip.route,
        customer: originalTrip.customer,
        location: originalTrip.location,
        pickupDrop: 'PICK UP',
        scheduleStart: originalTrip.scheduleStart,
        scheduleEnd: originalTrip.scheduleEnd,
        actualStart: originalTrip.actualStart,
        actualEnd: originalTrip.actualEnd,
        status: originalTrip.status,
        tripStatus: originalTrip.tripStatus,
        tripStartOdometer: originalTrip.tripStartOdometer,
        tripEndOdometer: originalTrip.tripEndOdometer,
        driverId: originalTrip.driverId,
        driverName: originalTrip.driverName,
        createdAt: originalTrip.createdAt,
        updatedAt: originalTrip.updatedAt,
      );
      
      // Create drop trip (duplicate with DROP)
      final dropTrip = TripDetailModel(
        id: '${tripId}_drop_${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: originalTrip.vehicleId,
        vehicleName: originalTrip.vehicleName,
        route: originalTrip.route,
        customer: originalTrip.customer,
        location: originalTrip.location,
        pickupDrop: 'DROP',
        scheduleStart: originalTrip.scheduleStart,
        scheduleEnd: originalTrip.scheduleEnd,
        actualStart: originalTrip.actualStart,
        actualEnd: originalTrip.actualEnd,
        status: originalTrip.status,
        tripStatus: originalTrip.tripStatus,
        tripStartOdometer: originalTrip.tripStartOdometer,
        tripEndOdometer: originalTrip.tripEndOdometer,
        driverId: originalTrip.driverId,
        driverName: originalTrip.driverName,
        createdAt: originalTrip.createdAt,
        updatedAt: originalTrip.updatedAt,
      );
      
      // Add split trips to mock data
      MockDataService.addSplitTrips(tripId, pickupTrip, dropTrip);
      return;
    }

    try {
      // For real API, we need to create two trips by duplicating the original
      // Real API for split trip is not implemented yet.
      // This block is kept for future implementation.
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Failed to split trip',
        );
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<String> updateVehicleApproveStatus({
    required String tripRequestId,
    required int approvedStatus,
    required String approvedBy,
  }) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return approvedStatus == 1 
          ? 'Trip approved successfully' 
          : 'Trip rejected successfully';
    }

    try {
      // Parse tripRequestId and approvedBy to integers
      final tripRequestIdInt = int.tryParse(tripRequestId) ?? 0;
      final approvedByInt = int.tryParse(approvedBy) ?? 0;

      // New API request body (no nested JSON string, direct object)
      // {
      //   "trip_request_id": 0,
      //   "approved_status": 0,
      //   "approved_by": 0
      // }
      final response = await dio.post(
        ApiConstants.updateVehicleApproveStatus,
        data: {
          'trip_request_id': tripRequestIdInt,
          'approved_status': approvedStatus,
          'approved_by': approvedByInt,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final apiStatus = responseData['status'] as int?;
        String? apiMessage = responseData['message'] as String?;

        // Check if API returned success status
        if (apiStatus == 200 || apiStatus == 1) {
          // Normalize generic messages like "Successful" to domain-specific ones
          final normalized = apiMessage?.trim().toLowerCase();
          if (normalized == null || normalized.isEmpty || normalized == 'successful') {
            apiMessage = approvedStatus == 1
                ? 'Trip approved successfully'
                : 'Trip rejected successfully';
          }
          return apiMessage!;
        } else {
          throw ServerException(apiMessage ?? 'Failed to update trip approval status');
        }
      } else {
        throw ServerException('Failed to update trip approval status');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        final responseData = e.response?.data;
        final message = responseData is Map
            ? (responseData['message'] ?? 'Failed to update trip approval status')
            : 'Failed to update trip approval status';
        throw ServerException(message);
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<String> cancelTrip({
    required String tripId,
    required String userId,
    required String remarks,
  }) async {
    // Use mock data if enabled
    if (AppConfig.USE_MOCK_DATA) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return 'Trip cancelled successfully';
    }

    try {
      final tripIdInt = int.tryParse(tripId) ?? 0;
      final userIdInt = int.tryParse(userId) ?? 0;

      final response = await dio.post(
        ApiConstants.cancelTrip,
        data: {
          'trip_id': tripIdInt,
          'user_id': userIdInt,
          'remarks': remarks,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final apiStatus = responseData['status'] as int?;
        final apiMessage = responseData['message'] as String?;

        if (apiStatus == 200 || apiStatus == 1) {
          return apiMessage ?? 'Trip cancelled successfully';
        } else {
          throw ServerException(apiMessage ?? 'Failed to cancel trip');
        }
      } else {
        throw ServerException('Failed to cancel trip');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet.');
      } else if (e.response != null) {
        final responseData = e.response?.data;
        final message = responseData is Map
            ? (responseData['message'] ?? 'Failed to cancel trip')
            : 'Failed to cancel trip';
        throw ServerException(message);
      } else {
        throw NetworkException('No internet connection');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}

