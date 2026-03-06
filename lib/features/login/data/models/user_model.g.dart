// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      driverId: json['driverId'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      token: json['token'] as String?,
      role: json['role'] == null
          ? UserRole.driver
          : const UserRoleConverter().fromJson(json['role'] as String),
      name: json['name'] as String?,
      clientId: (json['clientId'] as num?)?.toInt(),
      zoneId: (json['zoneId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'username': instance.username,
      'email': instance.email,
      'token': instance.token,
      'role': const UserRoleConverter().toJson(instance.role),
      'name': instance.name,
      'clientId': instance.clientId,
      'zoneId': instance.zoneId,
    };
