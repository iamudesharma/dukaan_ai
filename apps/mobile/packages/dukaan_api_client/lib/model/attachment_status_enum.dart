//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `PENDING` - Pending * `READY` - Ready * `FAILED` - Failed
class AttachmentStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const AttachmentStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const PENDING = AttachmentStatusEnum._(r'PENDING');
  static const READY = AttachmentStatusEnum._(r'READY');
  static const FAILED = AttachmentStatusEnum._(r'FAILED');

  /// List of all possible values in this [enum][AttachmentStatusEnum].
  static const values = <AttachmentStatusEnum>[
    PENDING,
    READY,
    FAILED,
  ];

  static AttachmentStatusEnum? fromJson(dynamic value) => AttachmentStatusEnumTypeTransformer().decode(value);

  static List<AttachmentStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AttachmentStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttachmentStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AttachmentStatusEnum] to String,
/// and [decode] dynamic data back to [AttachmentStatusEnum].
class AttachmentStatusEnumTypeTransformer {
  factory AttachmentStatusEnumTypeTransformer() => _instance ??= const AttachmentStatusEnumTypeTransformer._();

  const AttachmentStatusEnumTypeTransformer._();

  String encode(AttachmentStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AttachmentStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AttachmentStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'PENDING': return AttachmentStatusEnum.PENDING;
        case r'READY': return AttachmentStatusEnum.READY;
        case r'FAILED': return AttachmentStatusEnum.FAILED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AttachmentStatusEnumTypeTransformer] instance.
  static AttachmentStatusEnumTypeTransformer? _instance;
}

