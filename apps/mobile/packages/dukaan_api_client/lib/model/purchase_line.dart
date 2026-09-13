//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PurchaseLine {
  /// Returns a new [PurchaseLine] instance.
  PurchaseLine({
    required this.id,
    required this.product,
    required this.pack,
    required this.description,
    this.hsnSac,
    required this.quantity,
    required this.conversionFactor,
    required this.baseQuantity,
    required this.unitCostMinor,
    this.discountMinor,
    required this.taxableValueMinor,
    this.taxRateBps,
    this.cgstAmountMinor,
    this.sgstAmountMinor,
    this.igstAmountMinor,
    required this.lineTotalMinor,
  });

  String id;

  String product;

  String pack;

  String description;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? hsnSac;

  double quantity;

  double conversionFactor;

  double baseQuantity;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  int unitCostMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? discountMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  int taxableValueMinor;

  /// Minimum value: 0
  /// Maximum value: 10000
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? taxRateBps;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? cgstAmountMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? sgstAmountMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? igstAmountMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  int lineTotalMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseLine &&
    other.id == id &&
    other.product == product &&
    other.pack == pack &&
    other.description == description &&
    other.hsnSac == hsnSac &&
    other.quantity == quantity &&
    other.conversionFactor == conversionFactor &&
    other.baseQuantity == baseQuantity &&
    other.unitCostMinor == unitCostMinor &&
    other.discountMinor == discountMinor &&
    other.taxableValueMinor == taxableValueMinor &&
    other.taxRateBps == taxRateBps &&
    other.cgstAmountMinor == cgstAmountMinor &&
    other.sgstAmountMinor == sgstAmountMinor &&
    other.igstAmountMinor == igstAmountMinor &&
    other.lineTotalMinor == lineTotalMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (product.hashCode) +
    (pack.hashCode) +
    (description.hashCode) +
    (hsnSac == null ? 0 : hsnSac!.hashCode) +
    (quantity.hashCode) +
    (conversionFactor.hashCode) +
    (baseQuantity.hashCode) +
    (unitCostMinor.hashCode) +
    (discountMinor == null ? 0 : discountMinor!.hashCode) +
    (taxableValueMinor.hashCode) +
    (taxRateBps == null ? 0 : taxRateBps!.hashCode) +
    (cgstAmountMinor == null ? 0 : cgstAmountMinor!.hashCode) +
    (sgstAmountMinor == null ? 0 : sgstAmountMinor!.hashCode) +
    (igstAmountMinor == null ? 0 : igstAmountMinor!.hashCode) +
    (lineTotalMinor.hashCode);

  @override
  String toString() => 'PurchaseLine[id=$id, product=$product, pack=$pack, description=$description, hsnSac=$hsnSac, quantity=$quantity, conversionFactor=$conversionFactor, baseQuantity=$baseQuantity, unitCostMinor=$unitCostMinor, discountMinor=$discountMinor, taxableValueMinor=$taxableValueMinor, taxRateBps=$taxRateBps, cgstAmountMinor=$cgstAmountMinor, sgstAmountMinor=$sgstAmountMinor, igstAmountMinor=$igstAmountMinor, lineTotalMinor=$lineTotalMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'product'] = this.product;
      json[r'pack'] = this.pack;
      json[r'description'] = this.description;
    if (this.hsnSac != null) {
      json[r'hsn_sac'] = this.hsnSac;
    } else {
      json[r'hsn_sac'] = null;
    }
      json[r'quantity'] = this.quantity;
      json[r'conversion_factor'] = this.conversionFactor;
      json[r'base_quantity'] = this.baseQuantity;
      json[r'unit_cost_minor'] = this.unitCostMinor;
    if (this.discountMinor != null) {
      json[r'discount_minor'] = this.discountMinor;
    } else {
      json[r'discount_minor'] = null;
    }
      json[r'taxable_value_minor'] = this.taxableValueMinor;
    if (this.taxRateBps != null) {
      json[r'tax_rate_bps'] = this.taxRateBps;
    } else {
      json[r'tax_rate_bps'] = null;
    }
    if (this.cgstAmountMinor != null) {
      json[r'cgst_amount_minor'] = this.cgstAmountMinor;
    } else {
      json[r'cgst_amount_minor'] = null;
    }
    if (this.sgstAmountMinor != null) {
      json[r'sgst_amount_minor'] = this.sgstAmountMinor;
    } else {
      json[r'sgst_amount_minor'] = null;
    }
    if (this.igstAmountMinor != null) {
      json[r'igst_amount_minor'] = this.igstAmountMinor;
    } else {
      json[r'igst_amount_minor'] = null;
    }
      json[r'line_total_minor'] = this.lineTotalMinor;
    return json;
  }

  /// Returns a new [PurchaseLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PurchaseLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PurchaseLine[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PurchaseLine[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PurchaseLine(
        id: mapValueOfType<String>(json, r'id')!,
        product: mapValueOfType<String>(json, r'product')!,
        pack: mapValueOfType<String>(json, r'pack')!,
        description: mapValueOfType<String>(json, r'description')!,
        hsnSac: mapValueOfType<String>(json, r'hsn_sac'),
        quantity: mapValueOfType<double>(json, r'quantity')!,
        conversionFactor: mapValueOfType<double>(json, r'conversion_factor')!,
        baseQuantity: mapValueOfType<double>(json, r'base_quantity')!,
        unitCostMinor: mapValueOfType<int>(json, r'unit_cost_minor')!,
        discountMinor: mapValueOfType<int>(json, r'discount_minor'),
        taxableValueMinor: mapValueOfType<int>(json, r'taxable_value_minor')!,
        taxRateBps: mapValueOfType<int>(json, r'tax_rate_bps'),
        cgstAmountMinor: mapValueOfType<int>(json, r'cgst_amount_minor'),
        sgstAmountMinor: mapValueOfType<int>(json, r'sgst_amount_minor'),
        igstAmountMinor: mapValueOfType<int>(json, r'igst_amount_minor'),
        lineTotalMinor: mapValueOfType<int>(json, r'line_total_minor')!,
      );
    }
    return null;
  }

  static List<PurchaseLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PurchaseLine> mapFromJson(dynamic json) {
    final map = <String, PurchaseLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PurchaseLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PurchaseLine-objects as value to a dart map
  static Map<String, List<PurchaseLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PurchaseLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PurchaseLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'product',
    'pack',
    'description',
    'quantity',
    'conversion_factor',
    'base_quantity',
    'unit_cost_minor',
    'taxable_value_minor',
    'line_total_minor',
  };
}

