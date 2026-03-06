import 'package:equatable/equatable.dart';

enum UserRole { expat, driver }

class User extends Equatable {
  final String id;
  // For driver logins, backend sends separate driverid
  // For expat logins, this will typically be "0" or null
  final String? driverId;
  final String username;
  final String email;
  final String? token;
  final String? refreshToken;
  final UserRole role;
  final String? name;
  final int? clientId;
  final int? zoneId;

  const User({
    required this.id,
    this.driverId,
    required this.username,
    required this.email,
    this.token,
    this.refreshToken,
    this.role = UserRole.driver,
    this.name,
    this.clientId,
    this.zoneId,
  });

  @override
  List<Object?> get props => [id, driverId, username, email, token, refreshToken, role, name, clientId, zoneId];
}

