//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProductPack {
  /// Returns a new [ProductPack] instance.
  ProductPack({
    required this.id,
    required this.name,
    required this.conversionFactor,
    required this.retailPriceMinor,
    required this.wholesalePriceMinor,
    this.isActive,
  });

  String id;

  String name;

  double conversionFactor;

  /// Minimum value: 0
  /// Maximum value: 9223372036854775807
  int retailPriceMinor;

  /// Minimum value: 0
  /// Maximum value: 9223372036854775807
  int wholesalePriceMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isActive;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProductPack &&
    other.id == id &&
    other.name == name &&
    other.conversionFactor == conversionFactor &&
    other.retailPriceMinor == retailPriceMinor &&
    other.wholesalePriceMinor == wholesalePriceMinor &&
    other.isActive == isActive;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (conversionFactor.hashCode) +
    (retailPriceMinor.hashCode) +
    (wholesalePriceMinor.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode);

  @override
  String toString() => 'ProductPack[id=$id, name=$name, conversionFactor=$conversionFactor, retailPriceMinor=$retailPriceMinor, wholesalePriceMinor=$wholesalePriceMinor, isActive=$isActive]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'conversion_factor'] = this.conversionFactor;
      json[r'retail_price_minor'] = this.retailPriceMinor;
      json[r'wholesale_price_minor'] = this.wholesalePriceMinor;
    if (this.isActive != null) {
      json[r'is_active'] = this.isActive;
    } else {
      json[r'is_active'] = null;
    }
    return json;
  }

  /// Returns a new [ProductPack] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProductPack? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ProductPack[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ProductPack[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ProductPack(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        conversionFactor: mapValueOfType<double>(json, r'conversion_factor')!,
        retailPriceMinor: mapValueOfType<int>(json, r'retail_price_minor')!,
        wholesalePriceMinor: mapValueOfType<int>(json, r'wholesale_price_minor')!,
        isActive: mapValueOfType<bool>(json, r'is_active'),
      );
    }
    return null;
  }

  static List<ProductPack> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProductPack>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProductPack.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProductPack> mapFromJson(dynamic json) {
    final map = <String, ProductPack>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProductPack.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProductPack-objects as value to a dart map
  static Map<String, List<ProductPack>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProductPack>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProductPack.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'conversion_factor',
    'retail_price_minor',
    'wholesale_price_minor',
  };
}

