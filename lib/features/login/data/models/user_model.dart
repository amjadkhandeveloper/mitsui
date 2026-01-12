import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'expat':
        return UserRole.expat;
      case 'driver':
        return UserRole.driver;
      default:
        return UserRole.driver;
    }
  }

  @override
  String toJson(UserRole object) {
    switch (object) {
      case UserRole.expat:
        return 'expat';
      case UserRole.driver:
        return 'driver';
    }
  }
}

@JsonSerializable(
  converters: [UserRoleConverter()],
)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.token,
    super.refreshToken,
    super.role = UserRole.driver,
    super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      token: token,
      refreshToken: refreshToken,
      role: role,
      name: name,
    );
  }
}

