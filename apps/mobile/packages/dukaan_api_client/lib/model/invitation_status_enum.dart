//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `PENDING` - Pending * `ACCEPTED` - Accepted * `REVOKED` - Revoked * `EXPIRED` - Expired
class InvitationStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const InvitationStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const PENDING = InvitationStatusEnum._(r'PENDING');
  static const ACCEPTED = InvitationStatusEnum._(r'ACCEPTED');
  static const REVOKED = InvitationStatusEnum._(r'REVOKED');
  static const EXPIRED = InvitationStatusEnum._(r'EXPIRED');

  /// List of all possible values in this [enum][InvitationStatusEnum].
  static const values = <InvitationStatusEnum>[
    PENDING,
    ACCEPTED,
    REVOKED,
    EXPIRED,
  ];

  static InvitationStatusEnum? fromJson(dynamic value) => InvitationStatusEnumTypeTransformer().decode(value);

  static List<InvitationStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InvitationStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InvitationStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [InvitationStatusEnum] to String,
/// and [decode] dynamic data back to [InvitationStatusEnum].
class InvitationStatusEnumTypeTransformer {
  factory InvitationStatusEnumTypeTransformer() => _instance ??= const InvitationStatusEnumTypeTransformer._();

  const InvitationStatusEnumTypeTransformer._();

  String encode(InvitationStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a InvitationStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  InvitationStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'PENDING': return InvitationStatusEnum.PENDING;
        case r'ACCEPTED': return InvitationStatusEnum.ACCEPTED;
        case r'REVOKED': return InvitationStatusEnum.REVOKED;
        case r'EXPIRED': return InvitationStatusEnum.EXPIRED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [InvitationStatusEnumTypeTransformer] instance.
  static InvitationStatusEnumTypeTransformer? _instance;
}

