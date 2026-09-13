//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Transfer {
  /// Returns a new [Transfer] instance.
  Transfer({
    required this.id,
    required this.business,
    required this.fromLocation,
    required this.toLocation,
    this.status,
    required this.number,
    required this.documentDate,
    this.note,
    this.negativeStockAcknowledged,
    this.negativeStockReason,
    required this.postedAt,
    this.reversalReason,
    this.reversedAt,
    this.lines = const [],
  });

  String id;

  String business;

  String fromLocation;

  String toLocation;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Status3f8Enum? status;

  String number;

  DateTime documentDate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? negativeStockAcknowledged;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? negativeStockReason;

  DateTime postedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reversalReason;

  DateTime? reversedAt;

  List<TransferLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Transfer &&
    other.id == id &&
    other.business == business &&
    other.fromLocation == fromLocation &&
    other.toLocation == toLocation &&
    other.status == status &&
    other.number == number &&
    other.documentDate == documentDate &&
    other.note == note &&
    other.negativeStockAcknowledged == negativeStockAcknowledged &&
    other.negativeStockReason == negativeStockReason &&
    other.postedAt == postedAt &&
    other.reversalReason == reversalReason &&
    other.reversedAt == reversedAt &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (fromLocation.hashCode) +
    (toLocation.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (number.hashCode) +
    (documentDate.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (negativeStockAcknowledged == null ? 0 : negativeStockAcknowledged!.hashCode) +
    (negativeStockReason == null ? 0 : negativeStockReason!.hashCode) +
    (postedAt.hashCode) +
    (reversalReason == null ? 0 : reversalReason!.hashCode) +
    (reversedAt == null ? 0 : reversedAt!.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'Transfer[id=$id, business=$business, fromLocation=$fromLocation, toLocation=$toLocation, status=$status, number=$number, documentDate=$documentDate, note=$note, negativeStockAcknowledged=$negativeStockAcknowledged, negativeStockReason=$negativeStockReason, postedAt=$postedAt, reversalReason=$reversalReason, reversedAt=$reversedAt, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'from_location'] = this.fromLocation;
      json[r'to_location'] = this.toLocation;
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
      json[r'number'] = this.number;
      json[r'document_date'] = _dateFormatter.format(this.documentDate.toUtc());
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    if (this.negativeStockAcknowledged != null) {
      json[r'negative_stock_acknowledged'] = this.negativeStockAcknowledged;
    } else {
      json[r'negative_stock_acknowledged'] = null;
    }
    if (this.negativeStockReason != null) {
      json[r'negative_stock_reason'] = this.negativeStockReason;
    } else {
      json[r'negative_stock_reason'] = null;
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

  /// Returns a new [Transfer] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Transfer? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Transfer[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Transfer[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Transfer(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        fromLocation: mapValueOfType<String>(json, r'from_location')!,
        toLocation: mapValueOfType<String>(json, r'to_location')!,
        status: Status3f8Enum.fromJson(json[r'status']),
        number: mapValueOfType<String>(json, r'number')!,
        documentDate: mapDateTime(json, r'document_date', r'')!,
        note: mapValueOfType<String>(json, r'note'),
        negativeStockAcknowledged: mapValueOfType<bool>(json, r'negative_stock_acknowledged'),
        negativeStockReason: mapValueOfType<String>(json, r'negative_stock_reason'),
        postedAt: mapDateTime(json, r'posted_at', r'')!,
        reversalReason: mapValueOfType<String>(json, r'reversal_reason'),
        reversedAt: mapDateTime(json, r'reversed_at', r''),
        lines: TransferLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<Transfer> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Transfer>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Transfer.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Transfer> mapFromJson(dynamic json) {
    final map = <String, Transfer>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Transfer.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Transfer-objects as value to a dart map
  static Map<String, List<Transfer>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Transfer>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Transfer.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'from_location',
    'to_location',
    'number',
    'document_date',
    'posted_at',
    'lines',
  };
}

