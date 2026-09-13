//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
class Status3f8Enum {
  /// Instantiate a new enum with the provided [value].
  const Status3f8Enum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const DRAFT = Status3f8Enum._(r'DRAFT');
  static const POSTED = Status3f8Enum._(r'POSTED');
  static const REVERSED = Status3f8Enum._(r'REVERSED');

  /// List of all possible values in this [enum][Status3f8Enum].
  static const values = <Status3f8Enum>[
    DRAFT,
    POSTED,
    REVERSED,
  ];

  static Status3f8Enum? fromJson(dynamic value) => Status3f8EnumTypeTransformer().decode(value);

  static List<Status3f8Enum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Status3f8Enum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Status3f8Enum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [Status3f8Enum] to String,
/// and [decode] dynamic data back to [Status3f8Enum].
class Status3f8EnumTypeTransformer {
  factory Status3f8EnumTypeTransformer() => _instance ??= const Status3f8EnumTypeTransformer._();

  const Status3f8EnumTypeTransformer._();

  String encode(Status3f8Enum data) => data.value;

  /// Decodes a [dynamic value][data] to a Status3f8Enum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  Status3f8Enum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'DRAFT': return Status3f8Enum.DRAFT;
        case r'POSTED': return Status3f8Enum.POSTED;
        case r'REVERSED': return Status3f8Enum.REVERSED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [Status3f8EnumTypeTransformer] instance.
  static Status3f8EnumTypeTransformer? _instance;
}

