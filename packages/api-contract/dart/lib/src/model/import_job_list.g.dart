// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_job_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportJobListCWProxy {
  ImportJobList count(int count);

  ImportJobList next(String? next);

  ImportJobList previous(String? previous);

  ImportJobList results(List<ImportJob> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJobList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJobList(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJobList call({
    int count,
    String? next,
    String? previous,
    List<ImportJob> results,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportJobList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportJobList.copyWith.fieldName(...)`
class _$ImportJobListCWProxyImpl implements _$ImportJobListCWProxy {
  const _$ImportJobListCWProxyImpl(this._value);

  final ImportJobList _value;

  @override
  ImportJobList count(int count) => this(count: count);

  @override
  ImportJobList next(String? next) => this(next: next);

  @override
  ImportJobList previous(String? previous) => this(previous: previous);

  @override
  ImportJobList results(List<ImportJob> results) => this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJobList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJobList(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJobList call({
    Object? count = const $CopyWithPlaceholder(),
    Object? next = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? results = const $CopyWithPlaceholder(),
  }) {
    return ImportJobList(
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
      next: next == const $CopyWithPlaceholder()
          ? _value.next
          // ignore: cast_nullable_to_non_nullable
          : next as String?,
      previous: previous == const $CopyWithPlaceholder()
          ? _value.previous
          // ignore: cast_nullable_to_non_nullable
          : previous as String?,
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<ImportJob>,
    );
  }
}

extension $ImportJobListCopyWith on ImportJobList {
  /// Returns a callable class that can be used as follows: `instanceOfImportJobList.copyWith(...)` or like so:`instanceOfImportJobList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportJobListCWProxy get copyWith => _$ImportJobListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportJobList _$ImportJobListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ImportJobList', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['count', 'next', 'previous', 'results'],
      );
      final val = ImportJobList(
        count: $checkedConvert('count', (v) => (v as num).toInt()),
        next: $checkedConvert('next', (v) => v as String?),
        previous: $checkedConvert('previous', (v) => v as String?),
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => ImportJob.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ImportJobListToJson(ImportJobList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
