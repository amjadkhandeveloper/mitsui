// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      role: json['role'] == null
          ? UserRole.driver
          : const UserRoleConverter().fromJson(json['role'] as String),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'role': const UserRoleConverter().toJson(instance.role),
      'name': instance.name,
    };
