//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `SMS` - SMS * `WHATSAPP` - WhatsApp * `SHARE` - Manual share
class ChannelEnum {
  /// Instantiate a new enum with the provided [value].
  const ChannelEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const SMS = ChannelEnum._(r'SMS');
  static const WHATSAPP = ChannelEnum._(r'WHATSAPP');
  static const SHARE = ChannelEnum._(r'SHARE');

  /// List of all possible values in this [enum][ChannelEnum].
  static const values = <ChannelEnum>[
    SMS,
    WHATSAPP,
    SHARE,
  ];

  static ChannelEnum? fromJson(dynamic value) => ChannelEnumTypeTransformer().decode(value);

  static List<ChannelEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChannelEnum] to String,
/// and [decode] dynamic data back to [ChannelEnum].
class ChannelEnumTypeTransformer {
  factory ChannelEnumTypeTransformer() => _instance ??= const ChannelEnumTypeTransformer._();

  const ChannelEnumTypeTransformer._();

  String encode(ChannelEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ChannelEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChannelEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'SMS': return ChannelEnum.SMS;
        case r'WHATSAPP': return ChannelEnum.WHATSAPP;
        case r'SHARE': return ChannelEnum.SHARE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ChannelEnumTypeTransformer] instance.
  static ChannelEnumTypeTransformer? _instance;
}

