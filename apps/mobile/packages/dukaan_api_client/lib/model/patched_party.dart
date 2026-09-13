//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PatchedParty {
  /// Returns a new [PatchedParty] instance.
  PatchedParty({
    this.id,
    this.business,
    this.name,
    this.kind,
    this.phoneE164,
    this.phone,
    this.gstin,
    this.stateCode,
    this.address,
    this.isActive,
    this.receivableMinor,
    this.payableMinor,
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
  String? business;

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
  KindEnum? kind;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? phoneE164;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? phone;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? gstin;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? stateCode;

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
  bool? isActive;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? receivableMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? payableMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PatchedParty &&
    other.id == id &&
    other.business == business &&
    other.name == name &&
    other.kind == kind &&
    other.phoneE164 == phoneE164 &&
    other.phone == phone &&
    other.gstin == gstin &&
    other.stateCode == stateCode &&
    other.address == address &&
    other.isActive == isActive &&
    other.receivableMinor == receivableMinor &&
    other.payableMinor == payableMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (business == null ? 0 : business!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (kind == null ? 0 : kind!.hashCode) +
    (phoneE164 == null ? 0 : phoneE164!.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (gstin == null ? 0 : gstin!.hashCode) +
    (stateCode == null ? 0 : stateCode!.hashCode) +
    (address == null ? 0 : address!.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode) +
    (receivableMinor == null ? 0 : receivableMinor!.hashCode) +
    (payableMinor == null ? 0 : payableMinor!.hashCode);

  @override
  String toString() => 'PatchedParty[id=$id, business=$business, name=$name, kind=$kind, phoneE164=$phoneE164, phone=$phone, gstin=$gstin, stateCode=$stateCode, address=$address, isActive=$isActive, receivableMinor=$receivableMinor, payableMinor=$payableMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.business != null) {
      json[r'business'] = this.business;
    } else {
      json[r'business'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.kind != null) {
      json[r'kind'] = this.kind;
    } else {
      json[r'kind'] = null;
    }
    if (this.phoneE164 != null) {
      json[r'phone_e164'] = this.phoneE164;
    } else {
      json[r'phone_e164'] = null;
    }
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
    if (this.gstin != null) {
      json[r'gstin'] = this.gstin;
    } else {
      json[r'gstin'] = null;
    }
    if (this.stateCode != null) {
      json[r'state_code'] = this.stateCode;
    } else {
      json[r'state_code'] = null;
    }
    if (this.address != null) {
      json[r'address'] = this.address;
    } else {
      json[r'address'] = null;
    }
    if (this.isActive != null) {
      json[r'is_active'] = this.isActive;
    } else {
      json[r'is_active'] = null;
    }
    if (this.receivableMinor != null) {
      json[r'receivable_minor'] = this.receivableMinor;
    } else {
      json[r'receivable_minor'] = null;
    }
    if (this.payableMinor != null) {
      json[r'payable_minor'] = this.payableMinor;
    } else {
      json[r'payable_minor'] = null;
    }
    return json;
  }

  /// Returns a new [PatchedParty] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PatchedParty? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PatchedParty[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PatchedParty[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PatchedParty(
        id: mapValueOfType<String>(json, r'id'),
        business: mapValueOfType<String>(json, r'business'),
        name: mapValueOfType<String>(json, r'name'),
        kind: KindEnum.fromJson(json[r'kind']),
        phoneE164: mapValueOfType<String>(json, r'phone_e164'),
        phone: mapValueOfType<String>(json, r'phone'),
        gstin: mapValueOfType<String>(json, r'gstin'),
        stateCode: mapValueOfType<String>(json, r'state_code'),
        address: mapValueOfType<String>(json, r'address'),
        isActive: mapValueOfType<bool>(json, r'is_active'),
        receivableMinor: mapValueOfType<String>(json, r'receivable_minor'),
        payableMinor: mapValueOfType<String>(json, r'payable_minor'),
      );
    }
    return null;
  }

  static List<PatchedParty> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PatchedParty>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PatchedParty.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PatchedParty> mapFromJson(dynamic json) {
    final map = <String, PatchedParty>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PatchedParty.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PatchedParty-objects as value to a dart map
  static Map<String, List<PatchedParty>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PatchedParty>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PatchedParty.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

