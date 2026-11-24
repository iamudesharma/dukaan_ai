// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_imports.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GmailImportsCWProxy {
  GmailImports results(List<GmailImportResult> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailImports(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailImports(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailImports call({List<GmailImportResult> results});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGmailImports.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGmailImports.copyWith.fieldName(...)`
class _$GmailImportsCWProxyImpl implements _$GmailImportsCWProxy {
  const _$GmailImportsCWProxyImpl(this._value);

  final GmailImports _value;

  @override
  GmailImports results(List<GmailImportResult> results) =>
      this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailImports(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailImports(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailImports call({Object? results = const $CopyWithPlaceholder()}) {
    return GmailImports(
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<GmailImportResult>,
    );
  }
}

extension $GmailImportsCopyWith on GmailImports {
  /// Returns a callable class that can be used as follows: `instanceOfGmailImports.copyWith(...)` or like so:`instanceOfGmailImports.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GmailImportsCWProxy get copyWith => _$GmailImportsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GmailImports _$GmailImportsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GmailImports', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['results']);
      final val = GmailImports(
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => GmailImportResult.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GmailImportsToJson(GmailImports instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
