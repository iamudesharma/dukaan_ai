//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Attachment {
  /// Returns a new [Attachment] instance.
  Attachment({
    required this.id,
    required this.business,
    this.kind = 'sale-invoice',
    required this.sale,
    required this.mimeType,
    required this.sizeBytes,
    required this.status,
    required this.error,
    required this.downloadUrl,
    required this.createdAt,
  });

  String id;

  String business;

  String kind;

  String? sale;

  String mimeType;

  int sizeBytes;

  AttachmentStatusEnum status;

  String error;

  String downloadUrl;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Attachment &&
    other.id == id &&
    other.business == business &&
    other.kind == kind &&
    other.sale == sale &&
    other.mimeType == mimeType &&
    other.sizeBytes == sizeBytes &&
    other.status == status &&
    other.error == error &&
    other.downloadUrl == downloadUrl &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (kind.hashCode) +
    (sale == null ? 0 : sale!.hashCode) +
    (mimeType.hashCode) +
    (sizeBytes.hashCode) +
    (status.hashCode) +
    (error.hashCode) +
    (downloadUrl.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Attachment[id=$id, business=$business, kind=$kind, sale=$sale, mimeType=$mimeType, sizeBytes=$sizeBytes, status=$status, error=$error, downloadUrl=$downloadUrl, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
      json[r'kind'] = this.kind;
    if (this.sale != null) {
      json[r'sale'] = this.sale;
    } else {
      json[r'sale'] = null;
    }
      json[r'mime_type'] = this.mimeType;
      json[r'size_bytes'] = this.sizeBytes;
      json[r'status'] = this.status;
      json[r'error'] = this.error;
      json[r'download_url'] = this.downloadUrl;
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Attachment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Attachment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Attachment[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Attachment[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Attachment(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        kind: mapValueOfType<String>(json, r'kind')!,
        sale: mapValueOfType<String>(json, r'sale'),
        mimeType: mapValueOfType<String>(json, r'mime_type')!,
        sizeBytes: mapValueOfType<int>(json, r'size_bytes')!,
        status: AttachmentStatusEnum.fromJson(json[r'status'])!,
        error: mapValueOfType<String>(json, r'error')!,
        downloadUrl: mapValueOfType<String>(json, r'download_url')!,
        createdAt: mapDateTime(json, r'created_at', r'')!,
      );
    }
    return null;
  }

  static List<Attachment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Attachment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Attachment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Attachment> mapFromJson(dynamic json) {
    final map = <String, Attachment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Attachment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Attachment-objects as value to a dart map
  static Map<String, List<Attachment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Attachment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Attachment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'kind',
    'sale',
    'mime_type',
    'size_bytes',
    'status',
    'error',
    'download_url',
    'created_at',
  };
}

