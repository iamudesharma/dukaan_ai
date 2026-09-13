//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExportCreate {
  /// Returns a new [ExportCreate] instance.
  ExportCreate({
    required this.businessId,
    required this.report,
    this.format = FormatEnum.CSV,
    this.locationId,
    this.fromDate,
    this.toDate,
    this.groupBy = 'day',
  });

  String businessId;

  ReportEnum report;

  FormatEnum format;

  String? locationId;

  DateTime? fromDate;

  DateTime? toDate;

  String groupBy;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExportCreate &&
    other.businessId == businessId &&
    other.report == report &&
    other.format == format &&
    other.locationId == locationId &&
    other.fromDate == fromDate &&
    other.toDate == toDate &&
    other.groupBy == groupBy;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (businessId.hashCode) +
    (report.hashCode) +
    (format.hashCode) +
    (locationId == null ? 0 : locationId!.hashCode) +
    (fromDate == null ? 0 : fromDate!.hashCode) +
    (toDate == null ? 0 : toDate!.hashCode) +
    (groupBy.hashCode);

  @override
  String toString() => 'ExportCreate[businessId=$businessId, report=$report, format=$format, locationId=$locationId, fromDate=$fromDate, toDate=$toDate, groupBy=$groupBy]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'business_id'] = this.businessId;
      json[r'report'] = this.report;
      json[r'format'] = this.format;
    if (this.locationId != null) {
      json[r'location_id'] = this.locationId;
    } else {
      json[r'location_id'] = null;
    }
    if (this.fromDate != null) {
      json[r'from_date'] = _dateFormatter.format(this.fromDate!.toUtc());
    } else {
      json[r'from_date'] = null;
    }
    if (this.toDate != null) {
      json[r'to_date'] = _dateFormatter.format(this.toDate!.toUtc());
    } else {
      json[r'to_date'] = null;
    }
      json[r'group_by'] = this.groupBy;
    return json;
  }

  /// Returns a new [ExportCreate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExportCreate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExportCreate[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExportCreate[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExportCreate(
        businessId: mapValueOfType<String>(json, r'business_id')!,
        report: ReportEnum.fromJson(json[r'report'])!,
        format: FormatEnum.fromJson(json[r'format']) ?? FormatEnum.CSV,
        locationId: mapValueOfType<String>(json, r'location_id'),
        fromDate: mapDateTime(json, r'from_date', r''),
        toDate: mapDateTime(json, r'to_date', r''),
        groupBy: mapValueOfType<String>(json, r'group_by') ?? 'day',
      );
    }
    return null;
  }

  static List<ExportCreate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExportCreate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExportCreate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExportCreate> mapFromJson(dynamic json) {
    final map = <String, ExportCreate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExportCreate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExportCreate-objects as value to a dart map
  static Map<String, List<ExportCreate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExportCreate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExportCreate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'business_id',
    'report',
  };
}

