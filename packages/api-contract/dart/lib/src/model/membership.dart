//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'membership.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Membership {
  /// Returns a new [Membership] instance.
  Membership({
    required this.id,

    required this.user,

    required this.business,

    required this.role,

    this.locations,

    this.isActive,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final String user;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  /// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final MembershipRoleEnum role;

  @JsonKey(name: r'locations', required: false, includeIfNull: false)
  final List<String>? locations;

  @JsonKey(name: r'is_active', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Membership &&
          other.id == id &&
          other.user == user &&
          other.business == business &&
          other.role == role &&
          other.locations == locations &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      id.hashCode +
      user.hashCode +
      business.hashCode +
      role.hashCode +
      locations.hashCode +
      isActive.hashCode;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
enum MembershipRoleEnum {
  @JsonValue(r'OWNER')
  OWNER(r'OWNER'),
  @JsonValue(r'MANAGER')
  MANAGER(r'MANAGER'),
  @JsonValue(r'CASHIER')
  CASHIER(r'CASHIER');

  const MembershipRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
