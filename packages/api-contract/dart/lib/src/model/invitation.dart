//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invitation.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Invitation {
  /// Returns a new [Invitation] instance.
  Invitation({
    required this.id,

    required this.business,

    required this.inviteePhone,

    required this.role,

    required this.locations,

    required this.status,

    required this.expiresAt,

    required this.inviter,

    required this.acceptedBy,

    required this.acceptedAt,

    required this.revokedAt,

    required this.createdAt,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'invitee_phone', required: true, includeIfNull: false)
  final String inviteePhone;

  /// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final InvitationRoleEnum role;

  @JsonKey(name: r'locations', required: true, includeIfNull: false)
  final List<String> locations;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  @JsonKey(name: r'inviter', required: true, includeIfNull: false)
  final String inviter;

  @JsonKey(name: r'accepted_by', required: true, includeIfNull: true)
  final String? acceptedBy;

  @JsonKey(name: r'accepted_at', required: true, includeIfNull: true)
  final DateTime? acceptedAt;

  @JsonKey(name: r'revoked_at', required: true, includeIfNull: true)
  final DateTime? revokedAt;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updated_at', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invitation &&
          other.id == id &&
          other.business == business &&
          other.inviteePhone == inviteePhone &&
          other.role == role &&
          other.locations == locations &&
          other.status == status &&
          other.expiresAt == expiresAt &&
          other.inviter == inviter &&
          other.acceptedBy == acceptedBy &&
          other.acceptedAt == acceptedAt &&
          other.revokedAt == revokedAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      inviteePhone.hashCode +
      role.hashCode +
      locations.hashCode +
      status.hashCode +
      expiresAt.hashCode +
      inviter.hashCode +
      (acceptedBy == null ? 0 : acceptedBy.hashCode) +
      (acceptedAt == null ? 0 : acceptedAt.hashCode) +
      (revokedAt == null ? 0 : revokedAt.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
enum InvitationRoleEnum {
  @JsonValue(r'OWNER')
  OWNER(r'OWNER'),
  @JsonValue(r'MANAGER')
  MANAGER(r'MANAGER'),
  @JsonValue(r'CASHIER')
  CASHIER(r'CASHIER');

  const InvitationRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
