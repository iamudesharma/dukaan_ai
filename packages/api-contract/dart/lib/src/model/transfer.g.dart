// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TransferCWProxy {
  Transfer id(String id);

  Transfer business(String business);

  Transfer fromLocation(String fromLocation);

  Transfer toLocation(String toLocation);

  Transfer status(TransferStatusEnum? status);

  Transfer number(String number);

  Transfer documentDate(DateTime documentDate);

  Transfer note(String? note);

  Transfer negativeStockAcknowledged(bool? negativeStockAcknowledged);

  Transfer negativeStockReason(String? negativeStockReason);

  Transfer postedAt(DateTime postedAt);

  Transfer reversalReason(String? reversalReason);

  Transfer reversedAt(DateTime? reversedAt);

  Transfer lines(List<TransferLine> lines);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Transfer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Transfer(...).copyWith(id: 12, name: "My name")
  /// ````
  Transfer call({
    String id,
    String business,
    String fromLocation,
    String toLocation,
    TransferStatusEnum? status,
    String number,
    DateTime documentDate,
    String? note,
    bool? negativeStockAcknowledged,
    String? negativeStockReason,
    DateTime postedAt,
    String? reversalReason,
    DateTime? reversedAt,
    List<TransferLine> lines,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTransfer.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTransfer.copyWith.fieldName(...)`
class _$TransferCWProxyImpl implements _$TransferCWProxy {
  const _$TransferCWProxyImpl(this._value);

  final Transfer _value;

  @override
  Transfer id(String id) => this(id: id);

  @override
  Transfer business(String business) => this(business: business);

  @override
  Transfer fromLocation(String fromLocation) =>
      this(fromLocation: fromLocation);

  @override
  Transfer toLocation(String toLocation) => this(toLocation: toLocation);

  @override
  Transfer status(TransferStatusEnum? status) => this(status: status);

  @override
  Transfer number(String number) => this(number: number);

  @override
  Transfer documentDate(DateTime documentDate) =>
      this(documentDate: documentDate);

  @override
  Transfer note(String? note) => this(note: note);

  @override
  Transfer negativeStockAcknowledged(bool? negativeStockAcknowledged) =>
      this(negativeStockAcknowledged: negativeStockAcknowledged);

  @override
  Transfer negativeStockReason(String? negativeStockReason) =>
      this(negativeStockReason: negativeStockReason);

  @override
  Transfer postedAt(DateTime postedAt) => this(postedAt: postedAt);

  @override
  Transfer reversalReason(String? reversalReason) =>
      this(reversalReason: reversalReason);

  @override
  Transfer reversedAt(DateTime? reversedAt) => this(reversedAt: reversedAt);

  @override
  Transfer lines(List<TransferLine> lines) => this(lines: lines);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Transfer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Transfer(...).copyWith(id: 12, name: "My name")
  /// ````
  Transfer call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? fromLocation = const $CopyWithPlaceholder(),
    Object? toLocation = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? number = const $CopyWithPlaceholder(),
    Object? documentDate = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? negativeStockAcknowledged = const $CopyWithPlaceholder(),
    Object? negativeStockReason = const $CopyWithPlaceholder(),
    Object? postedAt = const $CopyWithPlaceholder(),
    Object? reversalReason = const $CopyWithPlaceholder(),
    Object? reversedAt = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
  }) {
    return Transfer(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      fromLocation: fromLocation == const $CopyWithPlaceholder()
          ? _value.fromLocation
          // ignore: cast_nullable_to_non_nullable
          : fromLocation as String,
      toLocation: toLocation == const $CopyWithPlaceholder()
          ? _value.toLocation
          // ignore: cast_nullable_to_non_nullable
          : toLocation as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as TransferStatusEnum?,
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as String,
      documentDate: documentDate == const $CopyWithPlaceholder()
          ? _value.documentDate
          // ignore: cast_nullable_to_non_nullable
          : documentDate as DateTime,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      negativeStockAcknowledged:
          negativeStockAcknowledged == const $CopyWithPlaceholder()
          ? _value.negativeStockAcknowledged
          // ignore: cast_nullable_to_non_nullable
          : negativeStockAcknowledged as bool?,
      negativeStockReason: negativeStockReason == const $CopyWithPlaceholder()
          ? _value.negativeStockReason
          // ignore: cast_nullable_to_non_nullable
          : negativeStockReason as String?,
      postedAt: postedAt == const $CopyWithPlaceholder()
          ? _value.postedAt
          // ignore: cast_nullable_to_non_nullable
          : postedAt as DateTime,
      reversalReason: reversalReason == const $CopyWithPlaceholder()
          ? _value.reversalReason
          // ignore: cast_nullable_to_non_nullable
          : reversalReason as String?,
      reversedAt: reversedAt == const $CopyWithPlaceholder()
          ? _value.reversedAt
          // ignore: cast_nullable_to_non_nullable
          : reversedAt as DateTime?,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as List<TransferLine>,
    );
  }
}

extension $TransferCopyWith on Transfer {
  /// Returns a callable class that can be used as follows: `instanceOfTransfer.copyWith(...)` or like so:`instanceOfTransfer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TransferCWProxy get copyWith => _$TransferCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transfer _$TransferFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Transfer',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'from_location',
        'to_location',
        'number',
        'document_date',
        'posted_at',
        'lines',
      ],
    );
    final val = Transfer(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      fromLocation: $checkedConvert('from_location', (v) => v as String),
      toLocation: $checkedConvert('to_location', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$TransferStatusEnumEnumMap, v),
      ),
      number: $checkedConvert('number', (v) => v as String),
      documentDate: $checkedConvert(
        'document_date',
        (v) => DateTime.parse(v as String),
      ),
      note: $checkedConvert('note', (v) => v as String?),
      negativeStockAcknowledged: $checkedConvert(
        'negative_stock_acknowledged',
        (v) => v as bool?,
      ),
      negativeStockReason: $checkedConvert(
        'negative_stock_reason',
        (v) => v as String?,
      ),
      postedAt: $checkedConvert(
        'posted_at',
        (v) => DateTime.parse(v as String),
      ),
      reversalReason: $checkedConvert('reversal_reason', (v) => v as String?),
      reversedAt: $checkedConvert(
        'reversed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      lines: $checkedConvert(
        'lines',
        (v) => (v as List<dynamic>)
            .map((e) => TransferLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'fromLocation': 'from_location',
    'toLocation': 'to_location',
    'documentDate': 'document_date',
    'negativeStockAcknowledged': 'negative_stock_acknowledged',
    'negativeStockReason': 'negative_stock_reason',
    'postedAt': 'posted_at',
    'reversalReason': 'reversal_reason',
    'reversedAt': 'reversed_at',
  },
);

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'from_location': instance.fromLocation,
  'to_location': instance.toLocation,
  'status': ?_$TransferStatusEnumEnumMap[instance.status],
  'number': instance.number,
  'document_date': instance.documentDate.toIso8601String(),
  'note': ?instance.note,
  'negative_stock_acknowledged': ?instance.negativeStockAcknowledged,
  'negative_stock_reason': ?instance.negativeStockReason,
  'posted_at': instance.postedAt.toIso8601String(),
  'reversal_reason': ?instance.reversalReason,
  'reversed_at': ?instance.reversedAt?.toIso8601String(),
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

const _$TransferStatusEnumEnumMap = {
  TransferStatusEnum.DRAFT: 'DRAFT',
  TransferStatusEnum.POSTED: 'POSTED',
  TransferStatusEnum.REVERSED: 'REVERSED',
};
