//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `day-book` - day-book * `gst` - gst * `party-balances` - party-balances * `purchases` - purchases * `sales` - sales * `stock-valuation` - stock-valuation
class ReportEnum {
  /// Instantiate a new enum with the provided [value].
  const ReportEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const dayBook = ReportEnum._(r'day-book');
  static const gst = ReportEnum._(r'gst');
  static const partyBalances = ReportEnum._(r'party-balances');
  static const purchases = ReportEnum._(r'purchases');
  static const sales = ReportEnum._(r'sales');
  static const stockValuation = ReportEnum._(r'stock-valuation');

  /// List of all possible values in this [enum][ReportEnum].
  static const values = <ReportEnum>[
    dayBook,
    gst,
    partyBalances,
    purchases,
    sales,
    stockValuation,
  ];

  static ReportEnum? fromJson(dynamic value) => ReportEnumTypeTransformer().decode(value);

  static List<ReportEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReportEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReportEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ReportEnum] to String,
/// and [decode] dynamic data back to [ReportEnum].
class ReportEnumTypeTransformer {
  factory ReportEnumTypeTransformer() => _instance ??= const ReportEnumTypeTransformer._();

  const ReportEnumTypeTransformer._();

  String encode(ReportEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ReportEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ReportEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'day-book': return ReportEnum.dayBook;
        case r'gst': return ReportEnum.gst;
        case r'party-balances': return ReportEnum.partyBalances;
        case r'purchases': return ReportEnum.purchases;
        case r'sales': return ReportEnum.sales;
        case r'stock-valuation': return ReportEnum.stockValuation;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ReportEnumTypeTransformer] instance.
  static ReportEnumTypeTransformer? _instance;
}

