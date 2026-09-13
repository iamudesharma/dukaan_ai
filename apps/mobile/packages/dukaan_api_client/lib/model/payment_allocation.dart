//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PaymentAllocation {
  /// Returns a new [PaymentAllocation] instance.
  PaymentAllocation({
    required this.id,
    this.sale,
    this.purchase,
    required this.amountMinor,
  });

  String id;

  String? sale;

  String? purchase;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  int amountMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentAllocation &&
    other.id == id &&
    other.sale == sale &&
    other.purchase == purchase &&
    other.amountMinor == amountMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (sale == null ? 0 : sale!.hashCode) +
    (purchase == null ? 0 : purchase!.hashCode) +
    (amountMinor.hashCode);

  @override
  String toString() => 'PaymentAllocation[id=$id, sale=$sale, purchase=$purchase, amountMinor=$amountMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.sale != null) {
      json[r'sale'] = this.sale;
    } else {
      json[r'sale'] = null;
    }
    if (this.purchase != null) {
      json[r'purchase'] = this.purchase;
    } else {
      json[r'purchase'] = null;
    }
      json[r'amount_minor'] = this.amountMinor;
    return json;
  }

  /// Returns a new [PaymentAllocation] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentAllocation? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PaymentAllocation[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PaymentAllocation[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PaymentAllocation(
        id: mapValueOfType<String>(json, r'id')!,
        sale: mapValueOfType<String>(json, r'sale'),
        purchase: mapValueOfType<String>(json, r'purchase'),
        amountMinor: mapValueOfType<int>(json, r'amount_minor')!,
      );
    }
    return null;
  }

  static List<PaymentAllocation> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentAllocation>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentAllocation.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentAllocation> mapFromJson(dynamic json) {
    final map = <String, PaymentAllocation>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentAllocation.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentAllocation-objects as value to a dart map
  static Map<String, List<PaymentAllocation>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentAllocation>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentAllocation.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'amount_minor',
  };
}

