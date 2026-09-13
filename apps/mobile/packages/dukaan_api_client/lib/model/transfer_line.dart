//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TransferLine {
  /// Returns a new [TransferLine] instance.
  TransferLine({
    required this.id,
    required this.product,
    required this.pack,
    required this.quantity,
    required this.conversionFactor,
    required this.baseQuantity,
  });

  String id;

  String product;

  String pack;

  double quantity;

  double conversionFactor;

  double baseQuantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TransferLine &&
    other.id == id &&
    other.product == product &&
    other.pack == pack &&
    other.quantity == quantity &&
    other.conversionFactor == conversionFactor &&
    other.baseQuantity == baseQuantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (product.hashCode) +
    (pack.hashCode) +
    (quantity.hashCode) +
    (conversionFactor.hashCode) +
    (baseQuantity.hashCode);

  @override
  String toString() => 'TransferLine[id=$id, product=$product, pack=$pack, quantity=$quantity, conversionFactor=$conversionFactor, baseQuantity=$baseQuantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'product'] = this.product;
      json[r'pack'] = this.pack;
      json[r'quantity'] = this.quantity;
      json[r'conversion_factor'] = this.conversionFactor;
      json[r'base_quantity'] = this.baseQuantity;
    return json;
  }

  /// Returns a new [TransferLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TransferLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TransferLine[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TransferLine[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TransferLine(
        id: mapValueOfType<String>(json, r'id')!,
        product: mapValueOfType<String>(json, r'product')!,
        pack: mapValueOfType<String>(json, r'pack')!,
        quantity: mapValueOfType<double>(json, r'quantity')!,
        conversionFactor: mapValueOfType<double>(json, r'conversion_factor')!,
        baseQuantity: mapValueOfType<double>(json, r'base_quantity')!,
      );
    }
    return null;
  }

  static List<TransferLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TransferLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TransferLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TransferLine> mapFromJson(dynamic json) {
    final map = <String, TransferLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TransferLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TransferLine-objects as value to a dart map
  static Map<String, List<TransferLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TransferLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TransferLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'product',
    'pack',
    'quantity',
    'conversion_factor',
    'base_quantity',
  };
}

