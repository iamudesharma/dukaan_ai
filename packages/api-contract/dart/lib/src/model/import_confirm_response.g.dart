// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_confirm_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportConfirmResponseCWProxy {
  ImportConfirmResponse job(ImportJob job);

  ImportConfirmResponse replayed(bool replayed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportConfirmResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportConfirmResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportConfirmResponse call({ImportJob job, bool replayed});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportConfirmResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportConfirmResponse.copyWith.fieldName(...)`
class _$ImportConfirmResponseCWProxyImpl
    implements _$ImportConfirmResponseCWProxy {
  const _$ImportConfirmResponseCWProxyImpl(this._value);

  final ImportConfirmResponse _value;

  @override
  ImportConfirmResponse job(ImportJob job) => this(job: job);

  @override
  ImportConfirmResponse replayed(bool replayed) => this(replayed: replayed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportConfirmResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportConfirmResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportConfirmResponse call({
    Object? job = const $CopyWithPlaceholder(),
    Object? replayed = const $CopyWithPlaceholder(),
  }) {
    return ImportConfirmResponse(
      job: job == const $CopyWithPlaceholder()
          ? _value.job
          // ignore: cast_nullable_to_non_nullable
          : job as ImportJob,
      replayed: replayed == const $CopyWithPlaceholder()
          ? _value.replayed
          // ignore: cast_nullable_to_non_nullable
          : replayed as bool,
    );
  }
}

extension $ImportConfirmResponseCopyWith on ImportConfirmResponse {
  /// Returns a callable class that can be used as follows: `instanceOfImportConfirmResponse.copyWith(...)` or like so:`instanceOfImportConfirmResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportConfirmResponseCWProxy get copyWith =>
      _$ImportConfirmResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportConfirmResponse _$ImportConfirmResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportConfirmResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['job', 'replayed']);
  final val = ImportConfirmResponse(
    job: $checkedConvert(
      'job',
      (v) => ImportJob.fromJson(v as Map<String, dynamic>),
    ),
    replayed: $checkedConvert('replayed', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$ImportConfirmResponseToJson(
  ImportConfirmResponse instance,
) => <String, dynamic>{
  'job': instance.job.toJson(),
  'replayed': instance.replayed,
};
