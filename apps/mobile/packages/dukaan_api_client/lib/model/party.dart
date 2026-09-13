//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Party {
  /// Returns a new [Party] instance.
  Party({
    required this.id,
    required this.business,
    required this.name,
    required this.kind,
    this.phoneE164,
    required this.phone,
    this.gstin,
    this.stateCode,
    this.address,
    this.isActive,
    required this.receivableMinor,
    required this.payableMinor,
  });

  String id;

  String business;

  String name;

  KindEnum kind;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? phoneE164;

  String phone;

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

  String receivableMinor;

  String payableMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Party &&
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
    (id.hashCode) +
    (business.hashCode) +
    (name.hashCode) +
    (kind.hashCode) +
    (phoneE164 == null ? 0 : phoneE164!.hashCode) +
    (phone.hashCode) +
    (gstin == null ? 0 : gstin!.hashCode) +
    (stateCode == null ? 0 : stateCode!.hashCode) +
    (address == null ? 0 : address!.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode) +
    (receivableMinor.hashCode) +
    (payableMinor.hashCode);

  @override
  String toString() => 'Party[id=$id, business=$business, name=$name, kind=$kind, phoneE164=$phoneE164, phone=$phone, gstin=$gstin, stateCode=$stateCode, address=$address, isActive=$isActive, receivableMinor=$receivableMinor, payableMinor=$payableMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'name'] = this.name;
      json[r'kind'] = this.kind;
    if (this.phoneE164 != null) {
      json[r'phone_e164'] = this.phoneE164;
    } else {
      json[r'phone_e164'] = null;
    }
      json[r'phone'] = this.phone;
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
      json[r'receivable_minor'] = this.receivableMinor;
      json[r'payable_minor'] = this.payableMinor;
    return json;
  }

  /// Returns a new [Party] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Party? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Party[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Party[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Party(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        name: mapValueOfType<String>(json, r'name')!,
        kind: KindEnum.fromJson(json[r'kind'])!,
        phoneE164: mapValueOfType<String>(json, r'phone_e164'),
        phone: mapValueOfType<String>(json, r'phone')!,
        gstin: mapValueOfType<String>(json, r'gstin'),
        stateCode: mapValueOfType<String>(json, r'state_code'),
        address: mapValueOfType<String>(json, r'address'),
        isActive: mapValueOfType<bool>(json, r'is_active'),
        receivableMinor: mapValueOfType<String>(json, r'receivable_minor')!,
        payableMinor: mapValueOfType<String>(json, r'payable_minor')!,
      );
    }
    return null;
  }

  static List<Party> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Party>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Party.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Party> mapFromJson(dynamic json) {
    final map = <String, Party>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Party.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Party-objects as value to a dart map
  static Map<String, List<Party>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Party>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Party.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'name',
    'kind',
    'phone',
    'receivable_minor',
    'payable_minor',
  };
}

