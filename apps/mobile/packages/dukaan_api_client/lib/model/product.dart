//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Product {
  /// Returns a new [Product] instance.
  Product({
    required this.id,
    required this.business,
    required this.name,
    this.sku,
    this.baseUnit,
    this.trackInventory,
    this.hsnSac,
    this.taxRateBps,
    this.lowStockThreshold,
    this.isActive,
    required this.defaultPackId,
    required this.stockQuantity,
    required this.isLowStock,
    this.packs = const [],
  });

  String id;

  String business;

  String name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sku;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  BaseUnitEnum? baseUnit;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? trackInventory;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? hsnSac;

  /// Minimum value: 0
  /// Maximum value: 10000
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? taxRateBps;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? lowStockThreshold;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isActive;

  String defaultPackId;

  String stockQuantity;

  String isLowStock;

  List<ProductPack> packs;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Product &&
    other.id == id &&
    other.business == business &&
    other.name == name &&
    other.sku == sku &&
    other.baseUnit == baseUnit &&
    other.trackInventory == trackInventory &&
    other.hsnSac == hsnSac &&
    other.taxRateBps == taxRateBps &&
    other.lowStockThreshold == lowStockThreshold &&
    other.isActive == isActive &&
    other.defaultPackId == defaultPackId &&
    other.stockQuantity == stockQuantity &&
    other.isLowStock == isLowStock &&
    _deepEquality.equals(other.packs, packs);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (name.hashCode) +
    (sku == null ? 0 : sku!.hashCode) +
    (baseUnit == null ? 0 : baseUnit!.hashCode) +
    (trackInventory == null ? 0 : trackInventory!.hashCode) +
    (hsnSac == null ? 0 : hsnSac!.hashCode) +
    (taxRateBps == null ? 0 : taxRateBps!.hashCode) +
    (lowStockThreshold == null ? 0 : lowStockThreshold!.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode) +
    (defaultPackId.hashCode) +
    (stockQuantity.hashCode) +
    (isLowStock.hashCode) +
    (packs.hashCode);

  @override
  String toString() => 'Product[id=$id, business=$business, name=$name, sku=$sku, baseUnit=$baseUnit, trackInventory=$trackInventory, hsnSac=$hsnSac, taxRateBps=$taxRateBps, lowStockThreshold=$lowStockThreshold, isActive=$isActive, defaultPackId=$defaultPackId, stockQuantity=$stockQuantity, isLowStock=$isLowStock, packs=$packs]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'name'] = this.name;
    if (this.sku != null) {
      json[r'sku'] = this.sku;
    } else {
      json[r'sku'] = null;
    }
    if (this.baseUnit != null) {
      json[r'base_unit'] = this.baseUnit;
    } else {
      json[r'base_unit'] = null;
    }
    if (this.trackInventory != null) {
      json[r'track_inventory'] = this.trackInventory;
    } else {
      json[r'track_inventory'] = null;
    }
    if (this.hsnSac != null) {
      json[r'hsn_sac'] = this.hsnSac;
    } else {
      json[r'hsn_sac'] = null;
    }
    if (this.taxRateBps != null) {
      json[r'tax_rate_bps'] = this.taxRateBps;
    } else {
      json[r'tax_rate_bps'] = null;
    }
    if (this.lowStockThreshold != null) {
      json[r'low_stock_threshold'] = this.lowStockThreshold;
    } else {
      json[r'low_stock_threshold'] = null;
    }
    if (this.isActive != null) {
      json[r'is_active'] = this.isActive;
    } else {
      json[r'is_active'] = null;
    }
      json[r'default_pack_id'] = this.defaultPackId;
      json[r'stock_quantity'] = this.stockQuantity;
      json[r'is_low_stock'] = this.isLowStock;
      json[r'packs'] = this.packs;
    return json;
  }

  /// Returns a new [Product] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Product? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Product[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Product[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Product(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        name: mapValueOfType<String>(json, r'name')!,
        sku: mapValueOfType<String>(json, r'sku'),
        baseUnit: BaseUnitEnum.fromJson(json[r'base_unit']),
        trackInventory: mapValueOfType<bool>(json, r'track_inventory'),
        hsnSac: mapValueOfType<String>(json, r'hsn_sac'),
        taxRateBps: mapValueOfType<int>(json, r'tax_rate_bps'),
        lowStockThreshold: mapValueOfType<double>(json, r'low_stock_threshold'),
        isActive: mapValueOfType<bool>(json, r'is_active'),
        defaultPackId: mapValueOfType<String>(json, r'default_pack_id')!,
        stockQuantity: mapValueOfType<String>(json, r'stock_quantity')!,
        isLowStock: mapValueOfType<String>(json, r'is_low_stock')!,
        packs: ProductPack.listFromJson(json[r'packs']),
      );
    }
    return null;
  }

  static List<Product> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Product>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Product.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Product> mapFromJson(dynamic json) {
    final map = <String, Product>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Product.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Product-objects as value to a dart map
  static Map<String, List<Product>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Product>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Product.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'name',
    'default_pack_id',
    'stock_quantity',
    'is_low_stock',
    'packs',
  };
}

