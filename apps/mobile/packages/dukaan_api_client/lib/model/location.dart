//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Location {
  /// Returns a new [Location] instance.
  Location({
    required this.id,
    required this.business,
    this.gstRegistration,
    required this.code,
    required this.name,
    this.address,
    this.stateCode,
    required this.isPrimary,
    this.isActive,
  });

  String id;

  String business;

  String? gstRegistration;

  String code;

  String name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? address;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? stateCode;

  String isPrimary;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isActive;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Location &&
    other.id == id &&
    other.business == business &&
    other.gstRegistration == gstRegistration &&
    other.code == code &&
    other.name == name &&
    other.address == address &&
    other.stateCode == stateCode &&
    other.isPrimary == isPrimary &&
    other.isActive == isActive;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (gstRegistration == null ? 0 : gstRegistration!.hashCode) +
    (code.hashCode) +
    (name.hashCode) +
    (address == null ? 0 : address!.hashCode) +
    (stateCode == null ? 0 : stateCode!.hashCode) +
    (isPrimary.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode);

  @override
  String toString() => 'Location[id=$id, business=$business, gstRegistration=$gstRegistration, code=$code, name=$name, address=$address, stateCode=$stateCode, isPrimary=$isPrimary, isActive=$isActive]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
    if (this.gstRegistration != null) {
      json[r'gst_registration'] = this.gstRegistration;
    } else {
      json[r'gst_registration'] = null;
    }
      json[r'code'] = this.code;
      json[r'name'] = this.name;
    if (this.address != null) {
      json[r'address'] = this.address;
    } else {
      json[r'address'] = null;
    }
    if (this.stateCode != null) {
      json[r'state_code'] = this.stateCode;
    } else {
      json[r'state_code'] = null;
    }
      json[r'is_primary'] = this.isPrimary;
    if (this.isActive != null) {
      json[r'is_active'] = this.isActive;
    } else {
      json[r'is_active'] = null;
    }
    return json;
  }

  /// Returns a new [Location] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Location? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Location[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Location[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Location(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        gstRegistration: mapValueOfType<String>(json, r'gst_registration'),
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        address: mapValueOfType<String>(json, r'address'),
        stateCode: mapValueOfType<String>(json, r'state_code'),
        isPrimary: mapValueOfType<String>(json, r'is_primary')!,
        isActive: mapValueOfType<bool>(json, r'is_active'),
      );
    }
    return null;
  }

  static List<Location> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Location>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Location.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Location> mapFromJson(dynamic json) {
    final map = <String, Location>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Location.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Location-objects as value to a dart map
  static Map<String, List<Location>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Location>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Location.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'code',
    'name',
    'is_primary',
  };
}

