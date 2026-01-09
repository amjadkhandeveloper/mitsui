import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? token;
  final String? refreshToken;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.token,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [id, username, email, token, refreshToken];
}

