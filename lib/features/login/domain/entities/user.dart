import 'package:equatable/equatable.dart';

enum UserRole { expat, driver }

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? token;
  final String? refreshToken;
  final UserRole role;
  final String? name;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.token,
    this.refreshToken,
    this.role = UserRole.driver,
    this.name,
  });

  @override
  List<Object?> get props => [id, username, email, token, refreshToken, role, name];
}

