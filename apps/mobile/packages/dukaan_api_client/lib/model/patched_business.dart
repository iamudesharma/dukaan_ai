//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PatchedBusiness {
  /// Returns a new [PatchedBusiness] instance.
  PatchedBusiness({
    this.id,
    this.name,
    this.legalName,
    this.currency,
    this.timezone,
    this.gstEnabled,
    this.defaultPriceMode,
    this.negativeStockAllowed,
    this.isActive,
    this.role,
    this.locations = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? legalName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? currency;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? timezone;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? gstEnabled;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? defaultPriceMode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? negativeStockAllowed;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isActive;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? role;

  List<Location> locations;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PatchedBusiness &&
    other.id == id &&
    other.name == name &&
    other.legalName == legalName &&
    other.currency == currency &&
    other.timezone == timezone &&
    other.gstEnabled == gstEnabled &&
    other.defaultPriceMode == defaultPriceMode &&
    other.negativeStockAllowed == negativeStockAllowed &&
    other.isActive == isActive &&
    other.role == role &&
    _deepEquality.equals(other.locations, locations);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (legalName == null ? 0 : legalName!.hashCode) +
    (currency == null ? 0 : currency!.hashCode) +
    (timezone == null ? 0 : timezone!.hashCode) +
    (gstEnabled == null ? 0 : gstEnabled!.hashCode) +
    (defaultPriceMode == null ? 0 : defaultPriceMode!.hashCode) +
    (negativeStockAllowed == null ? 0 : negativeStockAllowed!.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode) +
    (role == null ? 0 : role!.hashCode) +
    (locations.hashCode);

  @override
  String toString() => 'PatchedBusiness[id=$id, name=$name, legalName=$legalName, currency=$currency, timezone=$timezone, gstEnabled=$gstEnabled, defaultPriceMode=$defaultPriceMode, negativeStockAllowed=$negativeStockAllowed, isActive=$isActive, role=$role, locations=$locations]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.legalName != null) {
      json[r'legal_name'] = this.legalName;
    } else {
      json[r'legal_name'] = null;
    }
    if (this.currency != null) {
      json[r'currency'] = this.currency;
    } else {
      json[r'currency'] = null;
    }
    if (this.timezone != null) {
      json[r'timezone'] = this.timezone;
    } else {
      json[r'timezone'] = null;
    }
    if (this.gstEnabled != null) {
      json[r'gst_enabled'] = this.gstEnabled;
    } else {
      json[r'gst_enabled'] = null;
    }
    if (this.defaultPriceMode != null) {
      json[r'default_price_mode'] = this.defaultPriceMode;
    } else {
      json[r'default_price_mode'] = null;
    }
    if (this.negativeStockAllowed != null) {
      json[r'negative_stock_allowed'] = this.negativeStockAllowed;
    } else {
      json[r'negative_stock_allowed'] = null;
    }
    if (this.isActive != null) {
      json[r'is_active'] = this.isActive;
    } else {
      json[r'is_active'] = null;
    }
    if (this.role != null) {
      json[r'role'] = this.role;
    } else {
      json[r'role'] = null;
    }
      json[r'locations'] = this.locations;
    return json;
  }

  /// Returns a new [PatchedBusiness] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PatchedBusiness? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PatchedBusiness[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PatchedBusiness[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PatchedBusiness(
        id: mapValueOfType<String>(json, r'id'),
        name: mapValueOfType<String>(json, r'name'),
        legalName: mapValueOfType<String>(json, r'legal_name'),
        currency: mapValueOfType<String>(json, r'currency'),
        timezone: mapValueOfType<String>(json, r'timezone'),
        gstEnabled: mapValueOfType<bool>(json, r'gst_enabled'),
        defaultPriceMode: mapValueOfType<String>(json, r'default_price_mode'),
        negativeStockAllowed: mapValueOfType<bool>(json, r'negative_stock_allowed'),
        isActive: mapValueOfType<bool>(json, r'is_active'),
        role: mapValueOfType<String>(json, r'role'),
        locations: Location.listFromJson(json[r'locations']),
      );
    }
    return null;
  }

  static List<PatchedBusiness> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PatchedBusiness>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PatchedBusiness.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PatchedBusiness> mapFromJson(dynamic json) {
    final map = <String, PatchedBusiness>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PatchedBusiness.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PatchedBusiness-objects as value to a dart map
  static Map<String, List<PatchedBusiness>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PatchedBusiness>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PatchedBusiness.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

