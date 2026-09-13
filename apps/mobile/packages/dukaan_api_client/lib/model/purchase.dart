//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Purchase {
  /// Returns a new [Purchase] instance.
  Purchase({
    required this.id,
    required this.business,
    required this.location,
    required this.supplier,
    required this.supplierName,
    this.status,
    required this.number,
    required this.invoiceNumber,
    required this.occurredAt,
    required this.financialYear,
    required this.documentDate,
    this.supplierBillNumber,
    this.taxInclusive,
    this.sellerName,
    this.sellerGstin,
    this.buyerName,
    this.buyerGstin,
    this.placeOfSupply,
    this.subtotalMinor,
    this.discountTotalMinor,
    this.taxableTotalMinor,
    this.taxTotalMinor,
    this.grandTotalMinor,
    this.paidTotalMinor,
    this.dueTotalMinor,
    this.source_,
    required this.postedAt,
    this.reversalReason,
    this.reversedAt,
    this.lines = const [],
  });

  String id;

  String business;

  String location;

  String supplier;

  String supplierName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Status3f8Enum? status;

  String number;

  String invoiceNumber;

  DateTime occurredAt;

  String financialYear;

  DateTime documentDate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? supplierBillNumber;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? taxInclusive;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sellerName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sellerGstin;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? buyerName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? buyerGstin;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? placeOfSupply;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? subtotalMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? discountTotalMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? taxableTotalMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? taxTotalMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? grandTotalMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? paidTotalMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? dueTotalMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? source_;

  DateTime postedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reversalReason;

  DateTime? reversedAt;

  List<PurchaseLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Purchase &&
    other.id == id &&
    other.business == business &&
    other.location == location &&
    other.supplier == supplier &&
    other.supplierName == supplierName &&
    other.status == status &&
    other.number == number &&
    other.invoiceNumber == invoiceNumber &&
    other.occurredAt == occurredAt &&
    other.financialYear == financialYear &&
    other.documentDate == documentDate &&
    other.supplierBillNumber == supplierBillNumber &&
    other.taxInclusive == taxInclusive &&
    other.sellerName == sellerName &&
    other.sellerGstin == sellerGstin &&
    other.buyerName == buyerName &&
    other.buyerGstin == buyerGstin &&
    other.placeOfSupply == placeOfSupply &&
    other.subtotalMinor == subtotalMinor &&
    other.discountTotalMinor == discountTotalMinor &&
    other.taxableTotalMinor == taxableTotalMinor &&
    other.taxTotalMinor == taxTotalMinor &&
    other.grandTotalMinor == grandTotalMinor &&
    other.paidTotalMinor == paidTotalMinor &&
    other.dueTotalMinor == dueTotalMinor &&
    other.source_ == source_ &&
    other.postedAt == postedAt &&
    other.reversalReason == reversalReason &&
    other.reversedAt == reversedAt &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (location.hashCode) +
    (supplier.hashCode) +
    (supplierName.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (number.hashCode) +
    (invoiceNumber.hashCode) +
    (occurredAt.hashCode) +
    (financialYear.hashCode) +
    (documentDate.hashCode) +
    (supplierBillNumber == null ? 0 : supplierBillNumber!.hashCode) +
    (taxInclusive == null ? 0 : taxInclusive!.hashCode) +
    (sellerName == null ? 0 : sellerName!.hashCode) +
    (sellerGstin == null ? 0 : sellerGstin!.hashCode) +
    (buyerName == null ? 0 : buyerName!.hashCode) +
    (buyerGstin == null ? 0 : buyerGstin!.hashCode) +
    (placeOfSupply == null ? 0 : placeOfSupply!.hashCode) +
    (subtotalMinor == null ? 0 : subtotalMinor!.hashCode) +
    (discountTotalMinor == null ? 0 : discountTotalMinor!.hashCode) +
    (taxableTotalMinor == null ? 0 : taxableTotalMinor!.hashCode) +
    (taxTotalMinor == null ? 0 : taxTotalMinor!.hashCode) +
    (grandTotalMinor == null ? 0 : grandTotalMinor!.hashCode) +
    (paidTotalMinor == null ? 0 : paidTotalMinor!.hashCode) +
    (dueTotalMinor == null ? 0 : dueTotalMinor!.hashCode) +
    (source_ == null ? 0 : source_!.hashCode) +
    (postedAt.hashCode) +
    (reversalReason == null ? 0 : reversalReason!.hashCode) +
    (reversedAt == null ? 0 : reversedAt!.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'Purchase[id=$id, business=$business, location=$location, supplier=$supplier, supplierName=$supplierName, status=$status, number=$number, invoiceNumber=$invoiceNumber, occurredAt=$occurredAt, financialYear=$financialYear, documentDate=$documentDate, supplierBillNumber=$supplierBillNumber, taxInclusive=$taxInclusive, sellerName=$sellerName, sellerGstin=$sellerGstin, buyerName=$buyerName, buyerGstin=$buyerGstin, placeOfSupply=$placeOfSupply, subtotalMinor=$subtotalMinor, discountTotalMinor=$discountTotalMinor, taxableTotalMinor=$taxableTotalMinor, taxTotalMinor=$taxTotalMinor, grandTotalMinor=$grandTotalMinor, paidTotalMinor=$paidTotalMinor, dueTotalMinor=$dueTotalMinor, source_=$source_, postedAt=$postedAt, reversalReason=$reversalReason, reversedAt=$reversedAt, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'location'] = this.location;
      json[r'supplier'] = this.supplier;
      json[r'supplier_name'] = this.supplierName;
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
      json[r'number'] = this.number;
      json[r'invoice_number'] = this.invoiceNumber;
      json[r'occurred_at'] = this.occurredAt.toUtc().toIso8601String();
      json[r'financial_year'] = this.financialYear;
      json[r'document_date'] = _dateFormatter.format(this.documentDate.toUtc());
    if (this.supplierBillNumber != null) {
      json[r'supplier_bill_number'] = this.supplierBillNumber;
    } else {
      json[r'supplier_bill_number'] = null;
    }
    if (this.taxInclusive != null) {
      json[r'tax_inclusive'] = this.taxInclusive;
    } else {
      json[r'tax_inclusive'] = null;
    }
    if (this.sellerName != null) {
      json[r'seller_name'] = this.sellerName;
    } else {
      json[r'seller_name'] = null;
    }
    if (this.sellerGstin != null) {
      json[r'seller_gstin'] = this.sellerGstin;
    } else {
      json[r'seller_gstin'] = null;
    }
    if (this.buyerName != null) {
      json[r'buyer_name'] = this.buyerName;
    } else {
      json[r'buyer_name'] = null;
    }
    if (this.buyerGstin != null) {
      json[r'buyer_gstin'] = this.buyerGstin;
    } else {
      json[r'buyer_gstin'] = null;
    }
    if (this.placeOfSupply != null) {
      json[r'place_of_supply'] = this.placeOfSupply;
    } else {
      json[r'place_of_supply'] = null;
    }
    if (this.subtotalMinor != null) {
      json[r'subtotal_minor'] = this.subtotalMinor;
    } else {
      json[r'subtotal_minor'] = null;
    }
    if (this.discountTotalMinor != null) {
      json[r'discount_total_minor'] = this.discountTotalMinor;
    } else {
      json[r'discount_total_minor'] = null;
    }
    if (this.taxableTotalMinor != null) {
      json[r'taxable_total_minor'] = this.taxableTotalMinor;
    } else {
      json[r'taxable_total_minor'] = null;
    }
    if (this.taxTotalMinor != null) {
      json[r'tax_total_minor'] = this.taxTotalMinor;
    } else {
      json[r'tax_total_minor'] = null;
    }
    if (this.grandTotalMinor != null) {
      json[r'grand_total_minor'] = this.grandTotalMinor;
    } else {
      json[r'grand_total_minor'] = null;
    }
    if (this.paidTotalMinor != null) {
      json[r'paid_total_minor'] = this.paidTotalMinor;
    } else {
      json[r'paid_total_minor'] = null;
    }
    if (this.dueTotalMinor != null) {
      json[r'due_total_minor'] = this.dueTotalMinor;
    } else {
      json[r'due_total_minor'] = null;
    }
    if (this.source_ != null) {
      json[r'source'] = this.source_;
    } else {
      json[r'source'] = null;
    }
      json[r'posted_at'] = this.postedAt.toUtc().toIso8601String();
    if (this.reversalReason != null) {
      json[r'reversal_reason'] = this.reversalReason;
    } else {
      json[r'reversal_reason'] = null;
    }
    if (this.reversedAt != null) {
      json[r'reversed_at'] = this.reversedAt!.toUtc().toIso8601String();
    } else {
      json[r'reversed_at'] = null;
    }
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [Purchase] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Purchase? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Purchase[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Purchase[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Purchase(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        location: mapValueOfType<String>(json, r'location')!,
        supplier: mapValueOfType<String>(json, r'supplier')!,
        supplierName: mapValueOfType<String>(json, r'supplier_name')!,
        status: Status3f8Enum.fromJson(json[r'status']),
        number: mapValueOfType<String>(json, r'number')!,
        invoiceNumber: mapValueOfType<String>(json, r'invoice_number')!,
        occurredAt: mapDateTime(json, r'occurred_at', r'')!,
        financialYear: mapValueOfType<String>(json, r'financial_year')!,
        documentDate: mapDateTime(json, r'document_date', r'')!,
        supplierBillNumber: mapValueOfType<String>(json, r'supplier_bill_number'),
        taxInclusive: mapValueOfType<bool>(json, r'tax_inclusive'),
        sellerName: mapValueOfType<String>(json, r'seller_name'),
        sellerGstin: mapValueOfType<String>(json, r'seller_gstin'),
        buyerName: mapValueOfType<String>(json, r'buyer_name'),
        buyerGstin: mapValueOfType<String>(json, r'buyer_gstin'),
        placeOfSupply: mapValueOfType<String>(json, r'place_of_supply'),
        subtotalMinor: mapValueOfType<int>(json, r'subtotal_minor'),
        discountTotalMinor: mapValueOfType<int>(json, r'discount_total_minor'),
        taxableTotalMinor: mapValueOfType<int>(json, r'taxable_total_minor'),
        taxTotalMinor: mapValueOfType<int>(json, r'tax_total_minor'),
        grandTotalMinor: mapValueOfType<int>(json, r'grand_total_minor'),
        paidTotalMinor: mapValueOfType<int>(json, r'paid_total_minor'),
        dueTotalMinor: mapValueOfType<int>(json, r'due_total_minor'),
        source_: mapValueOfType<String>(json, r'source'),
        postedAt: mapDateTime(json, r'posted_at', r'')!,
        reversalReason: mapValueOfType<String>(json, r'reversal_reason'),
        reversedAt: mapDateTime(json, r'reversed_at', r''),
        lines: PurchaseLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<Purchase> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Purchase>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Purchase.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Purchase> mapFromJson(dynamic json) {
    final map = <String, Purchase>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Purchase.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Purchase-objects as value to a dart map
  static Map<String, List<Purchase>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Purchase>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Purchase.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'location',
    'supplier',
    'supplier_name',
    'number',
    'invoice_number',
    'occurred_at',
    'financial_year',
    'document_date',
    'posted_at',
    'lines',
  };
}

