//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bootstrap_user.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BootstrapUser {
  /// Returns a new [BootstrapUser] instance.
  BootstrapUser({
    required this.id,

    required this.name,

    required this.phone,

    required this.role,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'phone', required: true, includeIfNull: false)
  final String phone;

  /// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final BootstrapUserRoleEnum role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BootstrapUser &&
          other.id == id &&
          other.name == name &&
          other.phone == phone &&
          other.role == role;

  @override
  int get hashCode =>
      id.hashCode + name.hashCode + phone.hashCode + role.hashCode;

  factory BootstrapUser.fromJson(Map<String, dynamic> json) =>
      _$BootstrapUserFromJson(json);

  Map<String, dynamic> toJson() => _$BootstrapUserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
enum BootstrapUserRoleEnum {
  @JsonValue(r'OWNER')
  OWNER(r'OWNER'),
  @JsonValue(r'MANAGER')
  MANAGER(r'MANAGER'),
  @JsonValue(r'CASHIER')
  CASHIER(r'CASHIER');

  const BootstrapUserRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
