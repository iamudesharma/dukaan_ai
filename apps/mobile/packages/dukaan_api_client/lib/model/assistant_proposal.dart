//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AssistantProposal {
  /// Returns a new [AssistantProposal] instance.
  AssistantProposal({
    required this.id,
    required this.business,
    required this.location,
    required this.inputType,
    required this.locale,
    required this.content,
    required this.attachments,
    required this.commandType,
    required this.payload,
    required this.preview,
    required this.previewData,
    required this.warnings,
    required this.blockingQuestions,
    required this.status,
    required this.version,
    required this.expiresAt,
    required this.confirmedAt,
    required this.confirmedResultType,
    required this.confirmedResultId,
    required this.createdAt,
  });

  String id;

  String business;

  String location;

  InputTypeEnum inputType;

  String locale;

  String content;

  Object? attachments;

  String commandType;

  Object? payload;

  String preview;

  Object? previewData;

  Object? warnings;

  Object? blockingQuestions;

  AssistantProposalStatusEnum status;

  int version;

  DateTime expiresAt;

  DateTime? confirmedAt;

  String confirmedResultType;

  String? confirmedResultId;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AssistantProposal &&
    other.id == id &&
    other.business == business &&
    other.location == location &&
    other.inputType == inputType &&
    other.locale == locale &&
    other.content == content &&
    other.attachments == attachments &&
    other.commandType == commandType &&
    other.payload == payload &&
    other.preview == preview &&
    other.previewData == previewData &&
    other.warnings == warnings &&
    other.blockingQuestions == blockingQuestions &&
    other.status == status &&
    other.version == version &&
    other.expiresAt == expiresAt &&
    other.confirmedAt == confirmedAt &&
    other.confirmedResultType == confirmedResultType &&
    other.confirmedResultId == confirmedResultId &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (location.hashCode) +
    (inputType.hashCode) +
    (locale.hashCode) +
    (content.hashCode) +
    (attachments == null ? 0 : attachments!.hashCode) +
    (commandType.hashCode) +
    (payload == null ? 0 : payload!.hashCode) +
    (preview.hashCode) +
    (previewData == null ? 0 : previewData!.hashCode) +
    (warnings == null ? 0 : warnings!.hashCode) +
    (blockingQuestions == null ? 0 : blockingQuestions!.hashCode) +
    (status.hashCode) +
    (version.hashCode) +
    (expiresAt.hashCode) +
    (confirmedAt == null ? 0 : confirmedAt!.hashCode) +
    (confirmedResultType.hashCode) +
    (confirmedResultId == null ? 0 : confirmedResultId!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'AssistantProposal[id=$id, business=$business, location=$location, inputType=$inputType, locale=$locale, content=$content, attachments=$attachments, commandType=$commandType, payload=$payload, preview=$preview, previewData=$previewData, warnings=$warnings, blockingQuestions=$blockingQuestions, status=$status, version=$version, expiresAt=$expiresAt, confirmedAt=$confirmedAt, confirmedResultType=$confirmedResultType, confirmedResultId=$confirmedResultId, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'location'] = this.location;
      json[r'input_type'] = this.inputType;
      json[r'locale'] = this.locale;
      json[r'content'] = this.content;
    if (this.attachments != null) {
      json[r'attachments'] = this.attachments;
    } else {
      json[r'attachments'] = null;
    }
      json[r'command_type'] = this.commandType;
    if (this.payload != null) {
      json[r'payload'] = this.payload;
    } else {
      json[r'payload'] = null;
    }
      json[r'preview'] = this.preview;
    if (this.previewData != null) {
      json[r'preview_data'] = this.previewData;
    } else {
      json[r'preview_data'] = null;
    }
    if (this.warnings != null) {
      json[r'warnings'] = this.warnings;
    } else {
      json[r'warnings'] = null;
    }
    if (this.blockingQuestions != null) {
      json[r'blocking_questions'] = this.blockingQuestions;
    } else {
      json[r'blocking_questions'] = null;
    }
      json[r'status'] = this.status;
      json[r'version'] = this.version;
      json[r'expires_at'] = this.expiresAt.toUtc().toIso8601String();
    if (this.confirmedAt != null) {
      json[r'confirmed_at'] = this.confirmedAt!.toUtc().toIso8601String();
    } else {
      json[r'confirmed_at'] = null;
    }
      json[r'confirmed_result_type'] = this.confirmedResultType;
    if (this.confirmedResultId != null) {
      json[r'confirmed_result_id'] = this.confirmedResultId;
    } else {
      json[r'confirmed_result_id'] = null;
    }
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AssistantProposal] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AssistantProposal? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AssistantProposal[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AssistantProposal[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AssistantProposal(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        location: mapValueOfType<String>(json, r'location')!,
        inputType: InputTypeEnum.fromJson(json[r'input_type'])!,
        locale: mapValueOfType<String>(json, r'locale')!,
        content: mapValueOfType<String>(json, r'content')!,
        attachments: mapValueOfType<Object>(json, r'attachments'),
        commandType: mapValueOfType<String>(json, r'command_type')!,
        payload: mapValueOfType<Object>(json, r'payload'),
        preview: mapValueOfType<String>(json, r'preview')!,
        previewData: mapValueOfType<Object>(json, r'preview_data'),
        warnings: mapValueOfType<Object>(json, r'warnings'),
        blockingQuestions: mapValueOfType<Object>(json, r'blocking_questions'),
        status: AssistantProposalStatusEnum.fromJson(json[r'status'])!,
        version: mapValueOfType<int>(json, r'version')!,
        expiresAt: mapDateTime(json, r'expires_at', r'')!,
        confirmedAt: mapDateTime(json, r'confirmed_at', r''),
        confirmedResultType: mapValueOfType<String>(json, r'confirmed_result_type')!,
        confirmedResultId: mapValueOfType<String>(json, r'confirmed_result_id'),
        createdAt: mapDateTime(json, r'created_at', r'')!,
      );
    }
    return null;
  }

  static List<AssistantProposal> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AssistantProposal>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AssistantProposal.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AssistantProposal> mapFromJson(dynamic json) {
    final map = <String, AssistantProposal>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AssistantProposal.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AssistantProposal-objects as value to a dart map
  static Map<String, List<AssistantProposal>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AssistantProposal>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AssistantProposal.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'location',
    'input_type',
    'locale',
    'content',
    'attachments',
    'command_type',
    'payload',
    'preview',
    'preview_data',
    'warnings',
    'blocking_questions',
    'status',
    'version',
    'expires_at',
    'confirmed_at',
    'confirmed_result_type',
    'confirmed_result_id',
    'created_at',
  };
}

