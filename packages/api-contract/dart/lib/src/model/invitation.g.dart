// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InvitationCWProxy {
  Invitation id(String id);

  Invitation business(String business);

  Invitation inviteePhone(String inviteePhone);

  Invitation role(InvitationRoleEnum role);

  Invitation locations(List<String> locations);

  Invitation status(String status);

  Invitation expiresAt(DateTime expiresAt);

  Invitation inviter(String inviter);

  Invitation acceptedBy(String? acceptedBy);

  Invitation acceptedAt(DateTime? acceptedAt);

  Invitation revokedAt(DateTime? revokedAt);

  Invitation createdAt(DateTime createdAt);

  Invitation updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Invitation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Invitation(...).copyWith(id: 12, name: "My name")
  /// ````
  Invitation call({
    String id,
    String business,
    String inviteePhone,
    InvitationRoleEnum role,
    List<String> locations,
    String status,
    DateTime expiresAt,
    String inviter,
    String? acceptedBy,
    DateTime? acceptedAt,
    DateTime? revokedAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInvitation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInvitation.copyWith.fieldName(...)`
class _$InvitationCWProxyImpl implements _$InvitationCWProxy {
  const _$InvitationCWProxyImpl(this._value);

  final Invitation _value;

  @override
  Invitation id(String id) => this(id: id);

  @override
  Invitation business(String business) => this(business: business);

  @override
  Invitation inviteePhone(String inviteePhone) =>
      this(inviteePhone: inviteePhone);

  @override
  Invitation role(InvitationRoleEnum role) => this(role: role);

  @override
  Invitation locations(List<String> locations) => this(locations: locations);

  @override
  Invitation status(String status) => this(status: status);

  @override
  Invitation expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  Invitation inviter(String inviter) => this(inviter: inviter);

  @override
  Invitation acceptedBy(String? acceptedBy) => this(acceptedBy: acceptedBy);

  @override
  Invitation acceptedAt(DateTime? acceptedAt) => this(acceptedAt: acceptedAt);

  @override
  Invitation revokedAt(DateTime? revokedAt) => this(revokedAt: revokedAt);

  @override
  Invitation createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Invitation updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Invitation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Invitation(...).copyWith(id: 12, name: "My name")
  /// ````
  Invitation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? inviteePhone = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? locations = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? inviter = const $CopyWithPlaceholder(),
    Object? acceptedBy = const $CopyWithPlaceholder(),
    Object? acceptedAt = const $CopyWithPlaceholder(),
    Object? revokedAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Invitation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      inviteePhone: inviteePhone == const $CopyWithPlaceholder()
          ? _value.inviteePhone
          // ignore: cast_nullable_to_non_nullable
          : inviteePhone as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as InvitationRoleEnum,
      locations: locations == const $CopyWithPlaceholder()
          ? _value.locations
          // ignore: cast_nullable_to_non_nullable
          : locations as List<String>,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      inviter: inviter == const $CopyWithPlaceholder()
          ? _value.inviter
          // ignore: cast_nullable_to_non_nullable
          : inviter as String,
      acceptedBy: acceptedBy == const $CopyWithPlaceholder()
          ? _value.acceptedBy
          // ignore: cast_nullable_to_non_nullable
          : acceptedBy as String?,
      acceptedAt: acceptedAt == const $CopyWithPlaceholder()
          ? _value.acceptedAt
          // ignore: cast_nullable_to_non_nullable
          : acceptedAt as DateTime?,
      revokedAt: revokedAt == const $CopyWithPlaceholder()
          ? _value.revokedAt
          // ignore: cast_nullable_to_non_nullable
          : revokedAt as DateTime?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $InvitationCopyWith on Invitation {
  /// Returns a callable class that can be used as follows: `instanceOfInvitation.copyWith(...)` or like so:`instanceOfInvitation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InvitationCWProxy get copyWith => _$InvitationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invitation _$InvitationFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Invitation',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'invitee_phone',
        'role',
        'locations',
        'status',
        'expires_at',
        'inviter',
        'accepted_by',
        'accepted_at',
        'revoked_at',
        'created_at',
        'updated_at',
      ],
    );
    final val = Invitation(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      inviteePhone: $checkedConvert('invitee_phone', (v) => v as String),
      role: $checkedConvert(
        'role',
        (v) => $enumDecode(_$InvitationRoleEnumEnumMap, v),
      ),
      locations: $checkedConvert(
        'locations',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      status: $checkedConvert('status', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
      inviter: $checkedConvert('inviter', (v) => v as String),
      acceptedBy: $checkedConvert('accepted_by', (v) => v as String?),
      acceptedAt: $checkedConvert(
        'accepted_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      revokedAt: $checkedConvert(
        'revoked_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'inviteePhone': 'invitee_phone',
    'expiresAt': 'expires_at',
    'acceptedBy': 'accepted_by',
    'acceptedAt': 'accepted_at',
    'revokedAt': 'revoked_at',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$InvitationToJson(Invitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business': instance.business,
      'invitee_phone': instance.inviteePhone,
      'role': _$InvitationRoleEnumEnumMap[instance.role]!,
      'locations': instance.locations,
      'status': instance.status,
      'expires_at': instance.expiresAt.toIso8601String(),
      'inviter': instance.inviter,
      'accepted_by': instance.acceptedBy,
      'accepted_at': instance.acceptedAt?.toIso8601String(),
      'revoked_at': instance.revokedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$InvitationRoleEnumEnumMap = {
  InvitationRoleEnum.OWNER: 'OWNER',
  InvitationRoleEnum.MANAGER: 'MANAGER',
  InvitationRoleEnum.CASHIER: 'CASHIER',
};
