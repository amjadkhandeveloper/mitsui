import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/driver.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class DriverModel extends Driver {
  const DriverModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverModelToJson(this);

  Driver toEntity() {
    return Driver(
      id: id,
      name: name,
      email: email,
      phone: phone,
    );
  }
}

