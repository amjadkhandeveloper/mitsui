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
    super.driverId,
    required super.username,
    required super.email,
    super.token,
    super.role = UserRole.driver,
    super.name,
    super.clientId,
    super.zoneId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final model = _$UserModelFromJson(json);
    return UserModel(
      id: model.id,
      driverId: model.driverId,
      username: model.username,
      email: model.email,
      token: model.token,
      role: model.role,
      name: model.name,
      clientId: json['clientId'] is int 
          ? json['clientId'] as int 
          : (json['clientId'] is num 
              ? (json['clientId'] as num).toInt() 
              : null),
      zoneId: json['zoneId'] is int
          ? json['zoneId'] as int
          : (json['zoneId'] is num
              ? (json['zoneId'] as num).toInt()
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    final json = _$UserModelToJson(this);
    if (clientId != null) {
      json['clientId'] = clientId;
    }
    if (zoneId != null) {
      json['zoneId'] = zoneId;
    }
    return json;
  }

  User toEntity() {
    return User(
      id: id,
      driverId: driverId,
      username: username,
      email: email,
      token: token,
      role: role,
      name: name,
      clientId: clientId,
      zoneId: zoneId,
    );
  }
}

