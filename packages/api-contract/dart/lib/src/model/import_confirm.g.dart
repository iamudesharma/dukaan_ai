// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_confirm.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportConfirmCWProxy {
  ImportConfirm idempotencyKey(String? idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportConfirm(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportConfirm(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportConfirm call({String? idempotencyKey});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportConfirm.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportConfirm.copyWith.fieldName(...)`
class _$ImportConfirmCWProxyImpl implements _$ImportConfirmCWProxy {
  const _$ImportConfirmCWProxyImpl(this._value);

  final ImportConfirm _value;

  @override
  ImportConfirm idempotencyKey(String? idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportConfirm(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportConfirm(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportConfirm call({Object? idempotencyKey = const $CopyWithPlaceholder()}) {
    return ImportConfirm(
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String?,
    );
  }
}

extension $ImportConfirmCopyWith on ImportConfirm {
  /// Returns a callable class that can be used as follows: `instanceOfImportConfirm.copyWith(...)` or like so:`instanceOfImportConfirm.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportConfirmCWProxy get copyWith => _$ImportConfirmCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportConfirm _$ImportConfirmFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ImportConfirm', json, ($checkedConvert) {
      final val = ImportConfirm(
        idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'idempotencyKey': 'idempotency_key'});

Map<String, dynamic> _$ImportConfirmToJson(ImportConfirm instance) =>
    <String, dynamic>{'idempotency_key': ?instance.idempotencyKey};
