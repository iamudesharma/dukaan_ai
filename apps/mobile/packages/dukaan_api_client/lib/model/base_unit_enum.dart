//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `PIECE` - Piece * `KILOGRAM` - Kilogram * `LITRE` - Litre * `METRE` - Metre * `SERVICE` - Service
class BaseUnitEnum {
  /// Instantiate a new enum with the provided [value].
  const BaseUnitEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const PIECE = BaseUnitEnum._(r'PIECE');
  static const KILOGRAM = BaseUnitEnum._(r'KILOGRAM');
  static const LITRE = BaseUnitEnum._(r'LITRE');
  static const METRE = BaseUnitEnum._(r'METRE');
  static const SERVICE = BaseUnitEnum._(r'SERVICE');

  /// List of all possible values in this [enum][BaseUnitEnum].
  static const values = <BaseUnitEnum>[
    PIECE,
    KILOGRAM,
    LITRE,
    METRE,
    SERVICE,
  ];

  static BaseUnitEnum? fromJson(dynamic value) => BaseUnitEnumTypeTransformer().decode(value);

  static List<BaseUnitEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BaseUnitEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BaseUnitEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [BaseUnitEnum] to String,
/// and [decode] dynamic data back to [BaseUnitEnum].
class BaseUnitEnumTypeTransformer {
  factory BaseUnitEnumTypeTransformer() => _instance ??= const BaseUnitEnumTypeTransformer._();

  const BaseUnitEnumTypeTransformer._();

  String encode(BaseUnitEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a BaseUnitEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  BaseUnitEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'PIECE': return BaseUnitEnum.PIECE;
        case r'KILOGRAM': return BaseUnitEnum.KILOGRAM;
        case r'LITRE': return BaseUnitEnum.LITRE;
        case r'METRE': return BaseUnitEnum.METRE;
        case r'SERVICE': return BaseUnitEnum.SERVICE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [BaseUnitEnumTypeTransformer] instance.
  static BaseUnitEnumTypeTransformer? _instance;
}

