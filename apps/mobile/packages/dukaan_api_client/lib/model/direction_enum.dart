//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `RECEIPT` - Customer receipt * `PAYMENT` - Supplier payment
class DirectionEnum {
  /// Instantiate a new enum with the provided [value].
  const DirectionEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const RECEIPT = DirectionEnum._(r'RECEIPT');
  static const PAYMENT = DirectionEnum._(r'PAYMENT');

  /// List of all possible values in this [enum][DirectionEnum].
  static const values = <DirectionEnum>[
    RECEIPT,
    PAYMENT,
  ];

  static DirectionEnum? fromJson(dynamic value) => DirectionEnumTypeTransformer().decode(value);

  static List<DirectionEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DirectionEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DirectionEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DirectionEnum] to String,
/// and [decode] dynamic data back to [DirectionEnum].
class DirectionEnumTypeTransformer {
  factory DirectionEnumTypeTransformer() => _instance ??= const DirectionEnumTypeTransformer._();

  const DirectionEnumTypeTransformer._();

  String encode(DirectionEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DirectionEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DirectionEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'RECEIPT': return DirectionEnum.RECEIPT;
        case r'PAYMENT': return DirectionEnum.PAYMENT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DirectionEnumTypeTransformer] instance.
  static DirectionEnumTypeTransformer? _instance;
}

