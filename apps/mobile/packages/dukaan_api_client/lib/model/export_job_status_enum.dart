//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `PENDING` - Pending * `PROCESSING` - Processing * `READY` - Ready * `FAILED` - Failed
class ExportJobStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const ExportJobStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const PENDING = ExportJobStatusEnum._(r'PENDING');
  static const PROCESSING = ExportJobStatusEnum._(r'PROCESSING');
  static const READY = ExportJobStatusEnum._(r'READY');
  static const FAILED = ExportJobStatusEnum._(r'FAILED');

  /// List of all possible values in this [enum][ExportJobStatusEnum].
  static const values = <ExportJobStatusEnum>[
    PENDING,
    PROCESSING,
    READY,
    FAILED,
  ];

  static ExportJobStatusEnum? fromJson(dynamic value) => ExportJobStatusEnumTypeTransformer().decode(value);

  static List<ExportJobStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExportJobStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExportJobStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExportJobStatusEnum] to String,
/// and [decode] dynamic data back to [ExportJobStatusEnum].
class ExportJobStatusEnumTypeTransformer {
  factory ExportJobStatusEnumTypeTransformer() => _instance ??= const ExportJobStatusEnumTypeTransformer._();

  const ExportJobStatusEnumTypeTransformer._();

  String encode(ExportJobStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExportJobStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExportJobStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'PENDING': return ExportJobStatusEnum.PENDING;
        case r'PROCESSING': return ExportJobStatusEnum.PROCESSING;
        case r'READY': return ExportJobStatusEnum.READY;
        case r'FAILED': return ExportJobStatusEnum.FAILED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExportJobStatusEnumTypeTransformer] instance.
  static ExportJobStatusEnumTypeTransformer? _instance;
}

