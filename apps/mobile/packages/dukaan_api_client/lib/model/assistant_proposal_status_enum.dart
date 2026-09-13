//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// * `DRAFT` - Needs clarification * `READY` - Ready to confirm * `PROCESSING` - Reading attachment * `CONFIRMED` - Confirmed * `CANCELLED` - Cancelled * `EXPIRED` - Expired
class AssistantProposalStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const AssistantProposalStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const DRAFT = AssistantProposalStatusEnum._(r'DRAFT');
  static const READY = AssistantProposalStatusEnum._(r'READY');
  static const PROCESSING = AssistantProposalStatusEnum._(r'PROCESSING');
  static const CONFIRMED = AssistantProposalStatusEnum._(r'CONFIRMED');
  static const CANCELLED = AssistantProposalStatusEnum._(r'CANCELLED');
  static const EXPIRED = AssistantProposalStatusEnum._(r'EXPIRED');

  /// List of all possible values in this [enum][AssistantProposalStatusEnum].
  static const values = <AssistantProposalStatusEnum>[
    DRAFT,
    READY,
    PROCESSING,
    CONFIRMED,
    CANCELLED,
    EXPIRED,
  ];

  static AssistantProposalStatusEnum? fromJson(dynamic value) => AssistantProposalStatusEnumTypeTransformer().decode(value);

  static List<AssistantProposalStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AssistantProposalStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AssistantProposalStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AssistantProposalStatusEnum] to String,
/// and [decode] dynamic data back to [AssistantProposalStatusEnum].
class AssistantProposalStatusEnumTypeTransformer {
  factory AssistantProposalStatusEnumTypeTransformer() => _instance ??= const AssistantProposalStatusEnumTypeTransformer._();

  const AssistantProposalStatusEnumTypeTransformer._();

  String encode(AssistantProposalStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AssistantProposalStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AssistantProposalStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'DRAFT': return AssistantProposalStatusEnum.DRAFT;
        case r'READY': return AssistantProposalStatusEnum.READY;
        case r'PROCESSING': return AssistantProposalStatusEnum.PROCESSING;
        case r'CONFIRMED': return AssistantProposalStatusEnum.CONFIRMED;
        case r'CANCELLED': return AssistantProposalStatusEnum.CANCELLED;
        case r'EXPIRED': return AssistantProposalStatusEnum.EXPIRED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AssistantProposalStatusEnumTypeTransformer] instance.
  static AssistantProposalStatusEnumTypeTransformer? _instance;
}

