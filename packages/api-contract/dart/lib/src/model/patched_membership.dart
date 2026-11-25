//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patched_membership.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchedMembership {
  /// Returns a new [PatchedMembership] instance.
  PatchedMembership({
    this.id,

    this.user,

    this.userName,

    this.userPhone,

    this.business,

    this.role,

    this.locations,

    this.isActive,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'user', required: false, includeIfNull: false)
  final String? user;

  @JsonKey(name: r'user_name', required: false, includeIfNull: false)
  final String? userName;

  @JsonKey(name: r'user_phone', required: false, includeIfNull: false)
  final String? userPhone;

  @JsonKey(name: r'business', required: false, includeIfNull: false)
  final String? business;

  /// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
  @JsonKey(name: r'role', required: false, includeIfNull: false)
  final PatchedMembershipRoleEnum? role;

  @JsonKey(name: r'locations', required: false, includeIfNull: false)
  final List<String>? locations;

  @JsonKey(name: r'is_active', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchedMembership &&
          other.id == id &&
          other.user == user &&
          other.userName == userName &&
          other.userPhone == userPhone &&
          other.business == business &&
          other.role == role &&
          other.locations == locations &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      id.hashCode +
      user.hashCode +
      userName.hashCode +
      userPhone.hashCode +
      business.hashCode +
      role.hashCode +
      locations.hashCode +
      isActive.hashCode;

  factory PatchedMembership.fromJson(Map<String, dynamic> json) =>
      _$PatchedMembershipFromJson(json);

  Map<String, dynamic> toJson() => _$PatchedMembershipToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
enum PatchedMembershipRoleEnum {
  @JsonValue(r'OWNER')
  OWNER(r'OWNER'),
  @JsonValue(r'MANAGER')
  MANAGER(r'MANAGER'),
  @JsonValue(r'CASHIER')
  CASHIER(r'CASHIER');

  const PatchedMembershipRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
