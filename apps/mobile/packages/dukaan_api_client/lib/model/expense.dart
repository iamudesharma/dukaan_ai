//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Expense {
  /// Returns a new [Expense] instance.
  Expense({
    required this.id,
    required this.business,
    required this.location,
    this.status,
    required this.number,
    required this.documentDate,
    required this.occurredAt,
    required this.category,
    this.payee,
    this.note,
    required this.amountMinor,
    this.taxAmountMinor,
    required this.totalMinor,
    required this.paymentMethod,
    this.source_,
    required this.postedAt,
    this.reversalReason,
    this.reversedAt,
  });

  String id;

  String business;

  String location;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Status3f8Enum? status;

  String number;

  DateTime documentDate;

  DateTime occurredAt;

  String category;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? payee;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  int amountMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? taxAmountMinor;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  int totalMinor;

  PaymentMethodEnum paymentMethod;

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

  @override
  bool operator ==(Object other) => identical(this, other) || other is Expense &&
    other.id == id &&
    other.business == business &&
    other.location == location &&
    other.status == status &&
    other.number == number &&
    other.documentDate == documentDate &&
    other.occurredAt == occurredAt &&
    other.category == category &&
    other.payee == payee &&
    other.note == note &&
    other.amountMinor == amountMinor &&
    other.taxAmountMinor == taxAmountMinor &&
    other.totalMinor == totalMinor &&
    other.paymentMethod == paymentMethod &&
    other.source_ == source_ &&
    other.postedAt == postedAt &&
    other.reversalReason == reversalReason &&
    other.reversedAt == reversedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (location.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (number.hashCode) +
    (documentDate.hashCode) +
    (occurredAt.hashCode) +
    (category.hashCode) +
    (payee == null ? 0 : payee!.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (amountMinor.hashCode) +
    (taxAmountMinor == null ? 0 : taxAmountMinor!.hashCode) +
    (totalMinor.hashCode) +
    (paymentMethod.hashCode) +
    (source_ == null ? 0 : source_!.hashCode) +
    (postedAt.hashCode) +
    (reversalReason == null ? 0 : reversalReason!.hashCode) +
    (reversedAt == null ? 0 : reversedAt!.hashCode);

  @override
  String toString() => 'Expense[id=$id, business=$business, location=$location, status=$status, number=$number, documentDate=$documentDate, occurredAt=$occurredAt, category=$category, payee=$payee, note=$note, amountMinor=$amountMinor, taxAmountMinor=$taxAmountMinor, totalMinor=$totalMinor, paymentMethod=$paymentMethod, source_=$source_, postedAt=$postedAt, reversalReason=$reversalReason, reversedAt=$reversedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'location'] = this.location;
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
      json[r'number'] = this.number;
      json[r'document_date'] = _dateFormatter.format(this.documentDate.toUtc());
      json[r'occurred_at'] = this.occurredAt.toUtc().toIso8601String();
      json[r'category'] = this.category;
    if (this.payee != null) {
      json[r'payee'] = this.payee;
    } else {
      json[r'payee'] = null;
    }
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
      json[r'amount_minor'] = this.amountMinor;
    if (this.taxAmountMinor != null) {
      json[r'tax_amount_minor'] = this.taxAmountMinor;
    } else {
      json[r'tax_amount_minor'] = null;
    }
      json[r'total_minor'] = this.totalMinor;
      json[r'payment_method'] = this.paymentMethod;
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
    return json;
  }

  /// Returns a new [Expense] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Expense? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Expense[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Expense[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Expense(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        location: mapValueOfType<String>(json, r'location')!,
        status: Status3f8Enum.fromJson(json[r'status']),
        number: mapValueOfType<String>(json, r'number')!,
        documentDate: mapDateTime(json, r'document_date', r'')!,
        occurredAt: mapDateTime(json, r'occurred_at', r'')!,
        category: mapValueOfType<String>(json, r'category')!,
        payee: mapValueOfType<String>(json, r'payee'),
        note: mapValueOfType<String>(json, r'note'),
        amountMinor: mapValueOfType<int>(json, r'amount_minor')!,
        taxAmountMinor: mapValueOfType<int>(json, r'tax_amount_minor'),
        totalMinor: mapValueOfType<int>(json, r'total_minor')!,
        paymentMethod: PaymentMethodEnum.fromJson(json[r'payment_method'])!,
        source_: mapValueOfType<String>(json, r'source'),
        postedAt: mapDateTime(json, r'posted_at', r'')!,
        reversalReason: mapValueOfType<String>(json, r'reversal_reason'),
        reversedAt: mapDateTime(json, r'reversed_at', r''),
      );
    }
    return null;
  }

  static List<Expense> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Expense>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Expense.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Expense> mapFromJson(dynamic json) {
    final map = <String, Expense>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Expense.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Expense-objects as value to a dart map
  static Map<String, List<Expense>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Expense>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Expense.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'location',
    'number',
    'document_date',
    'occurred_at',
    'category',
    'amount_minor',
    'total_minor',
    'payment_method',
    'posted_at',
  };
}

