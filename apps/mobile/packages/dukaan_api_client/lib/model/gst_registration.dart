//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GSTRegistration {
  /// Returns a new [GSTRegistration] instance.
  GSTRegistration({
    required this.id,
    required this.business,
    required this.gstin,
    required this.legalName,
    this.address,
    required this.stateCode,
    this.invoicePrefix,
    this.isActive,
  });

  String id;

  String business;

  String gstin;

  String legalName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? address;

  String stateCode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? invoicePrefix;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isActive;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GSTRegistration &&
    other.id == id &&
    other.business == business &&
    other.gstin == gstin &&
    other.legalName == legalName &&
    other.address == address &&
    other.stateCode == stateCode &&
    other.invoicePrefix == invoicePrefix &&
    other.isActive == isActive;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (gstin.hashCode) +
    (legalName.hashCode) +
    (address == null ? 0 : address!.hashCode) +
    (stateCode.hashCode) +
    (invoicePrefix == null ? 0 : invoicePrefix!.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode);

  @override
  String toString() => 'GSTRegistration[id=$id, business=$business, gstin=$gstin, legalName=$legalName, address=$address, stateCode=$stateCode, invoicePrefix=$invoicePrefix, isActive=$isActive]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'gstin'] = this.gstin;
      json[r'legal_name'] = this.legalName;
    if (this.address != null) {
      json[r'address'] = this.address;
    } else {
      json[r'address'] = null;
    }
      json[r'state_code'] = this.stateCode;
    if (this.invoicePrefix != null) {
      json[r'invoice_prefix'] = this.invoicePrefix;
    } else {
      json[r'invoice_prefix'] = null;
    }
    if (this.isActive != null) {
      json[r'is_active'] = this.isActive;
    } else {
      json[r'is_active'] = null;
    }
    return json;
  }

  /// Returns a new [GSTRegistration] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GSTRegistration? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GSTRegistration[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GSTRegistration[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GSTRegistration(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        gstin: mapValueOfType<String>(json, r'gstin')!,
        legalName: mapValueOfType<String>(json, r'legal_name')!,
        address: mapValueOfType<String>(json, r'address'),
        stateCode: mapValueOfType<String>(json, r'state_code')!,
        invoicePrefix: mapValueOfType<String>(json, r'invoice_prefix'),
        isActive: mapValueOfType<bool>(json, r'is_active'),
      );
    }
    return null;
  }

  static List<GSTRegistration> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GSTRegistration>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GSTRegistration.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GSTRegistration> mapFromJson(dynamic json) {
    final map = <String, GSTRegistration>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GSTRegistration.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GSTRegistration-objects as value to a dart map
  static Map<String, List<GSTRegistration>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GSTRegistration>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GSTRegistration.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'gstin',
    'legal_name',
    'state_code',
  };
}

