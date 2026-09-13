//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Interpret {
  /// Returns a new [Interpret] instance.
  Interpret({
    required this.businessId,
    required this.locationId,
    this.inputType = InputTypeEnum.TEXT,
    this.content = '',
    this.locale = 'hi-IN',
    this.attachmentIds = const [],
  });

  String businessId;

  String locationId;

  InputTypeEnum inputType;

  String content;

  String locale;

  List<String> attachmentIds;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Interpret &&
    other.businessId == businessId &&
    other.locationId == locationId &&
    other.inputType == inputType &&
    other.content == content &&
    other.locale == locale &&
    _deepEquality.equals(other.attachmentIds, attachmentIds);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (businessId.hashCode) +
    (locationId.hashCode) +
    (inputType.hashCode) +
    (content.hashCode) +
    (locale.hashCode) +
    (attachmentIds.hashCode);

  @override
  String toString() => 'Interpret[businessId=$businessId, locationId=$locationId, inputType=$inputType, content=$content, locale=$locale, attachmentIds=$attachmentIds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'business_id'] = this.businessId;
      json[r'location_id'] = this.locationId;
      json[r'input_type'] = this.inputType;
      json[r'content'] = this.content;
      json[r'locale'] = this.locale;
      json[r'attachment_ids'] = this.attachmentIds;
    return json;
  }

  /// Returns a new [Interpret] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Interpret? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Interpret[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Interpret[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Interpret(
        businessId: mapValueOfType<String>(json, r'business_id')!,
        locationId: mapValueOfType<String>(json, r'location_id')!,
        inputType: InputTypeEnum.fromJson(json[r'input_type']) ?? InputTypeEnum.TEXT,
        content: mapValueOfType<String>(json, r'content') ?? '',
        locale: mapValueOfType<String>(json, r'locale') ?? 'hi-IN',
        attachmentIds: json[r'attachment_ids'] is Iterable
            ? (json[r'attachment_ids'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<Interpret> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Interpret>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Interpret.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Interpret> mapFromJson(dynamic json) {
    final map = <String, Interpret>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Interpret.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Interpret-objects as value to a dart map
  static Map<String, List<Interpret>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Interpret>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Interpret.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'business_id',
    'location_id',
  };
}

