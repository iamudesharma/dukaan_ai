//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class QueryParam {
  const QueryParam(this.name, this.value);

  final String name;
  final String value;

  @override
  String toString() => '${Uri.encodeQueryComponent(name)}=${Uri.encodeQueryComponent(value)}';
}

// Ported from the Java version.
Iterable<QueryParam> _queryParams(String collectionFormat, String name, dynamic value,) {
  // Assertions to run in debug mode only.
  assert(name.isNotEmpty, 'Parameter cannot be an empty string.');

  final params = <QueryParam>[];

  if (value is List) {
    if (collectionFormat == 'multi') {
      return value.map((dynamic v) => QueryParam(name, parameterToString(v)),);
    }

    // Default collection format is 'csv'.
    if (collectionFormat.isEmpty) {
      collectionFormat = 'csv'; // ignore: parameter_assignments
    }

    final delimiter = _delimiters[collectionFormat] ?? ',';

    params.add(QueryParam(name, value.map<dynamic>(parameterToString).join(delimiter),));
  } else if (value != null) {
    params.add(QueryParam(name, parameterToString(value)));
  }

  return params;
}

/// Format the given parameter object into a [String].
String parameterToString(dynamic value) {
  if (value == null) {
    return '';
  }
  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }
  if (value is AssistantProposalStatusEnum) {
    return AssistantProposalStatusEnumTypeTransformer().encode(value).toString();
  }
  if (value is AttachmentStatusEnum) {
    return AttachmentStatusEnumTypeTransformer().encode(value).toString();
  }
  if (value is BaseUnitEnum) {
    return BaseUnitEnumTypeTransformer().encode(value).toString();
  }
  if (value is ChannelEnum) {
    return ChannelEnumTypeTransformer().encode(value).toString();
  }
  if (value is DirectionEnum) {
    return DirectionEnumTypeTransformer().encode(value).toString();
  }
  if (value is ExportJobStatusEnum) {
    return ExportJobStatusEnumTypeTransformer().encode(value).toString();
  }
  if (value is FormatEnum) {
    return FormatEnumTypeTransformer().encode(value).toString();
  }
  if (value is InputTypeEnum) {
    return InputTypeEnumTypeTransformer().encode(value).toString();
  }
  if (value is InvitationStatusEnum) {
    return InvitationStatusEnumTypeTransformer().encode(value).toString();
  }
  if (value is KindEnum) {
    return KindEnumTypeTransformer().encode(value).toString();
  }
  if (value is MethodEnum) {
    return MethodEnumTypeTransformer().encode(value).toString();
  }
  if (value is PaymentMethodEnum) {
    return PaymentMethodEnumTypeTransformer().encode(value).toString();
  }
  if (value is PriceModeEnum) {
    return PriceModeEnumTypeTransformer().encode(value).toString();
  }
  if (value is ReminderStatusEnum) {
    return ReminderStatusEnumTypeTransformer().encode(value).toString();
  }
  if (value is ReportEnum) {
    return ReportEnumTypeTransformer().encode(value).toString();
  }
  if (value is RoleEnum) {
    return RoleEnumTypeTransformer().encode(value).toString();
  }
  if (value is Status3f8Enum) {
    return Status3f8EnumTypeTransformer().encode(value).toString();
  }
  return value.toString();
}

/// Returns the decoded body as UTF-8 if the given headers indicate an 'application/json'
/// content type. Otherwise, returns the decoded body as decoded by dart:http package.
Future<String> _decodeBodyBytes(Response response) async {
  final contentType = response.headers['content-type'];
  return contentType != null && contentType.toLowerCase().startsWith('application/json')
    ? response.bodyBytes.isEmpty ? '' : utf8.decode(response.bodyBytes)
    : response.body;
}

/// Returns a valid [T] value found at the specified Map [key], null otherwise.
T? mapValueOfType<T>(dynamic map, String key) {
  final dynamic value = map is Map ? map[key] : null;
  if (T == double && value is int) {
    return value.toDouble() as T;
  }
  return value is T ? value : null;
}

/// Returns a valid Map<K, V> found at the specified Map [key], null otherwise.
Map<K, V>? mapCastOfType<K, V>(dynamic map, String key) {
  final dynamic value = map is Map ? map[key] : null;
  return value is Map ? value.cast<K, V>() : null;
}

/// Returns a valid [DateTime] found at the specified Map [key], null otherwise.
DateTime? mapDateTime(dynamic map, String key, [String? pattern]) {
  final dynamic value = map is Map ? map[key] : null;
  if (value != null) {
    int? millis;
    if (value is int) {
      millis = value;
    } else if (value is String) {
      if (_isEpochMarker(pattern)) {
        millis = int.tryParse(value);
      } else {
        return DateTime.tryParse(value);
      }
    }
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }
  }
  return null;
}
