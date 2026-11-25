// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TransferCreateCWProxy {
  TransferCreate businessId(String businessId);

  TransferCreate fromLocationId(String fromLocationId);

  TransferCreate toLocationId(String toLocationId);

  TransferCreate transferDate(DateTime? transferDate);

  TransferCreate note(String? note);

  TransferCreate lines(List<TransferLineInput> lines);

  TransferCreate negativeStockAcknowledged(bool? negativeStockAcknowledged);

  TransferCreate negativeStockReason(String? negativeStockReason);

  TransferCreate idempotencyKey(String idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TransferCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TransferCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  TransferCreate call({
    String businessId,
    String fromLocationId,
    String toLocationId,
    DateTime? transferDate,
    String? note,
    List<TransferLineInput> lines,
    bool? negativeStockAcknowledged,
    String? negativeStockReason,
    String idempotencyKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTransferCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTransferCreate.copyWith.fieldName(...)`
class _$TransferCreateCWProxyImpl implements _$TransferCreateCWProxy {
  const _$TransferCreateCWProxyImpl(this._value);

  final TransferCreate _value;

  @override
  TransferCreate businessId(String businessId) => this(businessId: businessId);

  @override
  TransferCreate fromLocationId(String fromLocationId) =>
      this(fromLocationId: fromLocationId);

  @override
  TransferCreate toLocationId(String toLocationId) =>
      this(toLocationId: toLocationId);

  @override
  TransferCreate transferDate(DateTime? transferDate) =>
      this(transferDate: transferDate);

  @override
  TransferCreate note(String? note) => this(note: note);

  @override
  TransferCreate lines(List<TransferLineInput> lines) => this(lines: lines);

  @override
  TransferCreate negativeStockAcknowledged(bool? negativeStockAcknowledged) =>
      this(negativeStockAcknowledged: negativeStockAcknowledged);

  @override
  TransferCreate negativeStockReason(String? negativeStockReason) =>
      this(negativeStockReason: negativeStockReason);

  @override
  TransferCreate idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TransferCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TransferCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  TransferCreate call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? fromLocationId = const $CopyWithPlaceholder(),
    Object? toLocationId = const $CopyWithPlaceholder(),
    Object? transferDate = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
    Object? negativeStockAcknowledged = const $CopyWithPlaceholder(),
    Object? negativeStockReason = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
  }) {
    return TransferCreate(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      fromLocationId: fromLocationId == const $CopyWithPlaceholder()
          ? _value.fromLocationId
          // ignore: cast_nullable_to_non_nullable
          : fromLocationId as String,
      toLocationId: toLocationId == const $CopyWithPlaceholder()
          ? _value.toLocationId
          // ignore: cast_nullable_to_non_nullable
          : toLocationId as String,
      transferDate: transferDate == const $CopyWithPlaceholder()
          ? _value.transferDate
          // ignore: cast_nullable_to_non_nullable
          : transferDate as DateTime?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as List<TransferLineInput>,
      negativeStockAcknowledged:
          negativeStockAcknowledged == const $CopyWithPlaceholder()
          ? _value.negativeStockAcknowledged
          // ignore: cast_nullable_to_non_nullable
          : negativeStockAcknowledged as bool?,
      negativeStockReason: negativeStockReason == const $CopyWithPlaceholder()
          ? _value.negativeStockReason
          // ignore: cast_nullable_to_non_nullable
          : negativeStockReason as String?,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
    );
  }
}

extension $TransferCreateCopyWith on TransferCreate {
  /// Returns a callable class that can be used as follows: `instanceOfTransferCreate.copyWith(...)` or like so:`instanceOfTransferCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TransferCreateCWProxy get copyWith => _$TransferCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferCreate _$TransferCreateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'TransferCreate',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'business_id',
        'from_location_id',
        'to_location_id',
        'lines',
        'idempotency_key',
      ],
    );
    final val = TransferCreate(
      businessId: $checkedConvert('business_id', (v) => v as String),
      fromLocationId: $checkedConvert('from_location_id', (v) => v as String),
      toLocationId: $checkedConvert('to_location_id', (v) => v as String),
      transferDate: $checkedConvert(
        'transfer_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      note: $checkedConvert('note', (v) => v as String?),
      lines: $checkedConvert(
        'lines',
        (v) => (v as List<dynamic>)
            .map((e) => TransferLineInput.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      negativeStockAcknowledged: $checkedConvert(
        'negative_stock_acknowledged',
        (v) => v as bool? ?? false,
      ),
      negativeStockReason: $checkedConvert(
        'negative_stock_reason',
        (v) => v as String?,
      ),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'fromLocationId': 'from_location_id',
    'toLocationId': 'to_location_id',
    'transferDate': 'transfer_date',
    'negativeStockAcknowledged': 'negative_stock_acknowledged',
    'negativeStockReason': 'negative_stock_reason',
    'idempotencyKey': 'idempotency_key',
  },
);

Map<String, dynamic> _$TransferCreateToJson(TransferCreate instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'from_location_id': instance.fromLocationId,
      'to_location_id': instance.toLocationId,
      'transfer_date': ?instance.transferDate?.toIso8601String(),
      'note': ?instance.note,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'negative_stock_acknowledged': ?instance.negativeStockAcknowledged,
      'negative_stock_reason': ?instance.negativeStockReason,
      'idempotency_key': instance.idempotencyKey,
    };
