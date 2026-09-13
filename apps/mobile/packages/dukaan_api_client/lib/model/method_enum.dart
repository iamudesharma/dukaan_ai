//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
class MethodEnum {
  /// Instantiate a new enum with the provided [value].
  const MethodEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const CASH = MethodEnum._(r'CASH');
  static const UPI = MethodEnum._(r'UPI');
  static const CARD = MethodEnum._(r'CARD');
  static const BANK = MethodEnum._(r'BANK');
  static const OTHER = MethodEnum._(r'OTHER');

  /// List of all possible values in this [enum][MethodEnum].
  static const values = <MethodEnum>[
    CASH,
    UPI,
    CARD,
    BANK,
    OTHER,
  ];

  static MethodEnum? fromJson(dynamic value) => MethodEnumTypeTransformer().decode(value);

  static List<MethodEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MethodEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MethodEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MethodEnum] to String,
/// and [decode] dynamic data back to [MethodEnum].
class MethodEnumTypeTransformer {
  factory MethodEnumTypeTransformer() => _instance ??= const MethodEnumTypeTransformer._();

  const MethodEnumTypeTransformer._();

  String encode(MethodEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MethodEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MethodEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'CASH': return MethodEnum.CASH;
        case r'UPI': return MethodEnum.UPI;
        case r'CARD': return MethodEnum.CARD;
        case r'BANK': return MethodEnum.BANK;
        case r'OTHER': return MethodEnum.OTHER;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MethodEnumTypeTransformer] instance.
  static MethodEnumTypeTransformer? _instance;
}

