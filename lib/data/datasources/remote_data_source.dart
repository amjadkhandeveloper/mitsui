import 'package:dio/dio.dart';

abstract class RemoteDataSource {
  // Example methods - customize based on your needs
  // Future<AuthModel> login(String email, String password);
  // Future<UserModel> getUserProfile();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio dio;

  RemoteDataSourceImpl({required this.dio});

  // Implement your remote data source methods here
}
