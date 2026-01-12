import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/trip_detail_model.dart';

abstract class TripRemoteDataSource {
  Future<List<TripDetailModel>> getTrips({String? driverId, String? status});
  Future<TripDetailModel> getTripDetail(String tripId);
  Future<TripDetailModel> startTrip(String tripId, int startOdometer);
  Future<TripDetailModel> endTrip(String tripId, int endOdometer);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;

  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TripDetailModel>> getTrips({
    String? driverId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (driverId != null) queryParams['driver_id'] = driverId;
      if (status != null) queryParams['status'] = status;

      final response = await dio.get(
        '/trips',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => TripDetailModel.fromJson(json)).toList();
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
  Future<TripDetailModel> getTripDetail(String tripId) async {
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
}

