//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Payment {
  /// Returns a new [Payment] instance.
  Payment({
    required this.id,
    required this.business,
    required this.location,
    this.party,
    required this.partyName,
    required this.direction,
    required this.method,
    required this.amountMinor,
    this.reference,
    this.note,
    required this.paymentDate,
    required this.occurredAt,
    this.status,
    this.source_,
    this.reversalReason,
    this.reversedAt,
    this.allocations = const [],
  });

  String id;

  String business;

  String location;

  String? party;

  String partyName;

  DirectionEnum direction;

  MethodEnum method;

  /// Minimum value: -9223372036854775808
  /// Maximum value: 9223372036854775807
  int amountMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reference;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  DateTime paymentDate;

  DateTime occurredAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Status3f8Enum? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? source_;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reversalReason;

  DateTime? reversedAt;

  List<PaymentAllocation> allocations;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Payment &&
    other.id == id &&
    other.business == business &&
    other.location == location &&
    other.party == party &&
    other.partyName == partyName &&
    other.direction == direction &&
    other.method == method &&
    other.amountMinor == amountMinor &&
    other.reference == reference &&
    other.note == note &&
    other.paymentDate == paymentDate &&
    other.occurredAt == occurredAt &&
    other.status == status &&
    other.source_ == source_ &&
    other.reversalReason == reversalReason &&
    other.reversedAt == reversedAt &&
    _deepEquality.equals(other.allocations, allocations);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (location.hashCode) +
    (party == null ? 0 : party!.hashCode) +
    (partyName.hashCode) +
    (direction.hashCode) +
    (method.hashCode) +
    (amountMinor.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (paymentDate.hashCode) +
    (occurredAt.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (source_ == null ? 0 : source_!.hashCode) +
    (reversalReason == null ? 0 : reversalReason!.hashCode) +
    (reversedAt == null ? 0 : reversedAt!.hashCode) +
    (allocations.hashCode);

  @override
  String toString() => 'Payment[id=$id, business=$business, location=$location, party=$party, partyName=$partyName, direction=$direction, method=$method, amountMinor=$amountMinor, reference=$reference, note=$note, paymentDate=$paymentDate, occurredAt=$occurredAt, status=$status, source_=$source_, reversalReason=$reversalReason, reversedAt=$reversedAt, allocations=$allocations]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'location'] = this.location;
    if (this.party != null) {
      json[r'party'] = this.party;
    } else {
      json[r'party'] = null;
    }
      json[r'party_name'] = this.partyName;
      json[r'direction'] = this.direction;
      json[r'method'] = this.method;
      json[r'amount_minor'] = this.amountMinor;
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
      json[r'payment_date'] = _dateFormatter.format(this.paymentDate.toUtc());
      json[r'occurred_at'] = this.occurredAt.toUtc().toIso8601String();
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.source_ != null) {
      json[r'source'] = this.source_;
    } else {
      json[r'source'] = null;
    }
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
      json[r'allocations'] = this.allocations;
    return json;
  }

  /// Returns a new [Payment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Payment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Payment[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Payment[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Payment(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        location: mapValueOfType<String>(json, r'location')!,
        party: mapValueOfType<String>(json, r'party'),
        partyName: mapValueOfType<String>(json, r'party_name')!,
        direction: DirectionEnum.fromJson(json[r'direction'])!,
        method: MethodEnum.fromJson(json[r'method'])!,
        amountMinor: mapValueOfType<int>(json, r'amount_minor')!,
        reference: mapValueOfType<String>(json, r'reference'),
        note: mapValueOfType<String>(json, r'note'),
        paymentDate: mapDateTime(json, r'payment_date', r'')!,
        occurredAt: mapDateTime(json, r'occurred_at', r'')!,
        status: Status3f8Enum.fromJson(json[r'status']),
        source_: mapValueOfType<String>(json, r'source'),
        reversalReason: mapValueOfType<String>(json, r'reversal_reason'),
        reversedAt: mapDateTime(json, r'reversed_at', r''),
        allocations: PaymentAllocation.listFromJson(json[r'allocations']),
      );
    }
    return null;
  }

  static List<Payment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Payment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Payment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Payment> mapFromJson(dynamic json) {
    final map = <String, Payment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Payment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Payment-objects as value to a dart map
  static Map<String, List<Payment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Payment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Payment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'location',
    'party_name',
    'direction',
    'method',
    'amount_minor',
    'payment_date',
    'occurred_at',
    'allocations',
  };
}

