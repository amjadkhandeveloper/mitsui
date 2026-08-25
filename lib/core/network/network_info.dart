import 'package:dio/dio.dart';

/// Connectivity probe used by the unused scaffold [RepositoryImpl].
/// Live API calls use [DioClient._hasInternetConnection] (DNS lookup of the API host).
/// Hitting google.com from the Dio instance that has Mitsui as baseUrl is unreliable.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Dio dio;

  NetworkInfoImpl(this.dio);

  @override
  Future<bool> get isConnected async {
    try {
      final response = await dio.get(
        'https://www.google.com',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
