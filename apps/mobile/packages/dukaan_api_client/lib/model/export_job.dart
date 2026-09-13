//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExportJob {
  /// Returns a new [ExportJob] instance.
  ExportJob({
    required this.id,
    required this.business,
    required this.report,
    required this.format,
    required this.params,
    required this.status,
    required this.error,
    required this.downloadUrl,
    required this.createdAt,
  });

  String id;

  String business;

  String report;

  FormatEnum format;

  Object? params;

  ExportJobStatusEnum status;

  String error;

  String downloadUrl;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExportJob &&
    other.id == id &&
    other.business == business &&
    other.report == report &&
    other.format == format &&
    other.params == params &&
    other.status == status &&
    other.error == error &&
    other.downloadUrl == downloadUrl &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (report.hashCode) +
    (format.hashCode) +
    (params == null ? 0 : params!.hashCode) +
    (status.hashCode) +
    (error.hashCode) +
    (downloadUrl.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'ExportJob[id=$id, business=$business, report=$report, format=$format, params=$params, status=$status, error=$error, downloadUrl=$downloadUrl, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'report'] = this.report;
      json[r'format'] = this.format;
    if (this.params != null) {
      json[r'params'] = this.params;
    } else {
      json[r'params'] = null;
    }
      json[r'status'] = this.status;
      json[r'error'] = this.error;
      json[r'download_url'] = this.downloadUrl;
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ExportJob] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExportJob? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExportJob[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExportJob[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExportJob(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        report: mapValueOfType<String>(json, r'report')!,
        format: FormatEnum.fromJson(json[r'format'])!,
        params: mapValueOfType<Object>(json, r'params'),
        status: ExportJobStatusEnum.fromJson(json[r'status'])!,
        error: mapValueOfType<String>(json, r'error')!,
        downloadUrl: mapValueOfType<String>(json, r'download_url')!,
        createdAt: mapDateTime(json, r'created_at', r'')!,
      );
    }
    return null;
  }

  static List<ExportJob> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExportJob>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExportJob.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExportJob> mapFromJson(dynamic json) {
    final map = <String, ExportJob>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExportJob.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExportJob-objects as value to a dart map
  static Map<String, List<ExportJob>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExportJob>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExportJob.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'report',
    'format',
    'params',
    'status',
    'error',
    'download_url',
    'created_at',
  };
}

