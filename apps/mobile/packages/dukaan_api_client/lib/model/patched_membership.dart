//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PatchedMembership {
  /// Returns a new [PatchedMembership] instance.
  PatchedMembership({
    this.id,
    this.user,
    this.userName,
    this.userPhone,
    this.business,
    this.role,
    this.locations = const [],
    this.isActive,
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
  String? user;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userPhone;

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
  RoleEnum? role;

  List<String> locations;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isActive;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PatchedMembership &&
    other.id == id &&
    other.user == user &&
    other.userName == userName &&
    other.userPhone == userPhone &&
    other.business == business &&
    other.role == role &&
    _deepEquality.equals(other.locations, locations) &&
    other.isActive == isActive;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (user == null ? 0 : user!.hashCode) +
    (userName == null ? 0 : userName!.hashCode) +
    (userPhone == null ? 0 : userPhone!.hashCode) +
    (business == null ? 0 : business!.hashCode) +
    (role == null ? 0 : role!.hashCode) +
    (locations.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode);

  @override
  String toString() => 'PatchedMembership[id=$id, user=$user, userName=$userName, userPhone=$userPhone, business=$business, role=$role, locations=$locations, isActive=$isActive]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.user != null) {
      json[r'user'] = this.user;
    } else {
      json[r'user'] = null;
    }
    if (this.userName != null) {
      json[r'user_name'] = this.userName;
    } else {
      json[r'user_name'] = null;
    }
    if (this.userPhone != null) {
      json[r'user_phone'] = this.userPhone;
    } else {
      json[r'user_phone'] = null;
    }
    if (this.business != null) {
      json[r'business'] = this.business;
    } else {
      json[r'business'] = null;
    }
    if (this.role != null) {
      json[r'role'] = this.role;
    } else {
      json[r'role'] = null;
    }
      json[r'locations'] = this.locations;
    if (this.isActive != null) {
      json[r'is_active'] = this.isActive;
    } else {
      json[r'is_active'] = null;
    }
    return json;
  }

  /// Returns a new [PatchedMembership] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PatchedMembership? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PatchedMembership[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PatchedMembership[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PatchedMembership(
        id: mapValueOfType<String>(json, r'id'),
        user: mapValueOfType<String>(json, r'user'),
        userName: mapValueOfType<String>(json, r'user_name'),
        userPhone: mapValueOfType<String>(json, r'user_phone'),
        business: mapValueOfType<String>(json, r'business'),
        role: RoleEnum.fromJson(json[r'role']),
        locations: json[r'locations'] is Iterable
            ? (json[r'locations'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        isActive: mapValueOfType<bool>(json, r'is_active'),
      );
    }
    return null;
  }

  static List<PatchedMembership> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PatchedMembership>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PatchedMembership.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PatchedMembership> mapFromJson(dynamic json) {
    final map = <String, PatchedMembership>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PatchedMembership.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PatchedMembership-objects as value to a dart map
  static Map<String, List<PatchedMembership>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PatchedMembership>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PatchedMembership.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

