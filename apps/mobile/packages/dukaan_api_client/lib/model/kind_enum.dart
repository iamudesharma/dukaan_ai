//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `CUSTOMER` - Customer * `SUPPLIER` - Supplier * `BOTH` - Customer and supplier
class KindEnum {
  /// Instantiate a new enum with the provided [value].
  const KindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const CUSTOMER = KindEnum._(r'CUSTOMER');
  static const SUPPLIER = KindEnum._(r'SUPPLIER');
  static const BOTH = KindEnum._(r'BOTH');

  /// List of all possible values in this [enum][KindEnum].
  static const values = <KindEnum>[
    CUSTOMER,
    SUPPLIER,
    BOTH,
  ];

  static KindEnum? fromJson(dynamic value) => KindEnumTypeTransformer().decode(value);

  static List<KindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [KindEnum] to String,
/// and [decode] dynamic data back to [KindEnum].
class KindEnumTypeTransformer {
  factory KindEnumTypeTransformer() => _instance ??= const KindEnumTypeTransformer._();

  const KindEnumTypeTransformer._();

  String encode(KindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a KindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  KindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'CUSTOMER': return KindEnum.CUSTOMER;
        case r'SUPPLIER': return KindEnum.SUPPLIER;
        case r'BOTH': return KindEnum.BOTH;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [KindEnumTypeTransformer] instance.
  static KindEnumTypeTransformer? _instance;
}

