// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_line_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TransferLineInputCWProxy {
  TransferLineInput packId(String packId);

  TransferLineInput quantity(double quantity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TransferLineInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TransferLineInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TransferLineInput call({String packId, double quantity});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTransferLineInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTransferLineInput.copyWith.fieldName(...)`
class _$TransferLineInputCWProxyImpl implements _$TransferLineInputCWProxy {
  const _$TransferLineInputCWProxyImpl(this._value);

  final TransferLineInput _value;

  @override
  TransferLineInput packId(String packId) => this(packId: packId);

  @override
  TransferLineInput quantity(double quantity) => this(quantity: quantity);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TransferLineInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TransferLineInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TransferLineInput call({
    Object? packId = const $CopyWithPlaceholder(),
    Object? quantity = const $CopyWithPlaceholder(),
  }) {
    return TransferLineInput(
      packId: packId == const $CopyWithPlaceholder()
          ? _value.packId
          // ignore: cast_nullable_to_non_nullable
          : packId as String,
      quantity: quantity == const $CopyWithPlaceholder()
          ? _value.quantity
          // ignore: cast_nullable_to_non_nullable
          : quantity as double,
    );
  }
}

extension $TransferLineInputCopyWith on TransferLineInput {
  /// Returns a callable class that can be used as follows: `instanceOfTransferLineInput.copyWith(...)` or like so:`instanceOfTransferLineInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TransferLineInputCWProxy get copyWith =>
      _$TransferLineInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferLineInput _$TransferLineInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TransferLineInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['pack_id', 'quantity']);
      final val = TransferLineInput(
        packId: $checkedConvert('pack_id', (v) => v as String),
        quantity: $checkedConvert('quantity', (v) => (v as num).toDouble()),
      );
      return val;
    }, fieldKeyMap: const {'packId': 'pack_id'});

Map<String, dynamic> _$TransferLineInputToJson(TransferLineInput instance) =>
    <String, dynamic>{
      'pack_id': instance.packId,
      'quantity': instance.quantity,
    };
