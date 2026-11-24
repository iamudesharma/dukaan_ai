// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_balance_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OpeningBalanceCreateCWProxy {
  OpeningBalanceCreate businessId(String businessId);

  OpeningBalanceCreate locationId(String locationId);

  OpeningBalanceCreate partyId(String partyId);

  OpeningBalanceCreate account(OpeningBalanceCreateAccountEnum account);

  OpeningBalanceCreate amountMinor(int amountMinor);

  OpeningBalanceCreate note(String? note);

  OpeningBalanceCreate idempotencyKey(String idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OpeningBalanceCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OpeningBalanceCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  OpeningBalanceCreate call({
    String businessId,
    String locationId,
    String partyId,
    OpeningBalanceCreateAccountEnum account,
    int amountMinor,
    String? note,
    String idempotencyKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOpeningBalanceCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOpeningBalanceCreate.copyWith.fieldName(...)`
class _$OpeningBalanceCreateCWProxyImpl
    implements _$OpeningBalanceCreateCWProxy {
  const _$OpeningBalanceCreateCWProxyImpl(this._value);

  final OpeningBalanceCreate _value;

  @override
  OpeningBalanceCreate businessId(String businessId) =>
      this(businessId: businessId);

  @override
  OpeningBalanceCreate locationId(String locationId) =>
      this(locationId: locationId);

  @override
  OpeningBalanceCreate partyId(String partyId) => this(partyId: partyId);

  @override
  OpeningBalanceCreate account(OpeningBalanceCreateAccountEnum account) =>
      this(account: account);

  @override
  OpeningBalanceCreate amountMinor(int amountMinor) =>
      this(amountMinor: amountMinor);

  @override
  OpeningBalanceCreate note(String? note) => this(note: note);

  @override
  OpeningBalanceCreate idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OpeningBalanceCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OpeningBalanceCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  OpeningBalanceCreate call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
    Object? partyId = const $CopyWithPlaceholder(),
    Object? account = const $CopyWithPlaceholder(),
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
  }) {
    return OpeningBalanceCreate(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String,
      partyId: partyId == const $CopyWithPlaceholder()
          ? _value.partyId
          // ignore: cast_nullable_to_non_nullable
          : partyId as String,
      account: account == const $CopyWithPlaceholder()
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as OpeningBalanceCreateAccountEnum,
      amountMinor: amountMinor == const $CopyWithPlaceholder()
          ? _value.amountMinor
          // ignore: cast_nullable_to_non_nullable
          : amountMinor as int,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
    );
  }
}

extension $OpeningBalanceCreateCopyWith on OpeningBalanceCreate {
  /// Returns a callable class that can be used as follows: `instanceOfOpeningBalanceCreate.copyWith(...)` or like so:`instanceOfOpeningBalanceCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OpeningBalanceCreateCWProxy get copyWith =>
      _$OpeningBalanceCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpeningBalanceCreate _$OpeningBalanceCreateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'OpeningBalanceCreate',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'business_id',
        'location_id',
        'party_id',
        'account',
        'amount_minor',
        'idempotency_key',
      ],
    );
    final val = OpeningBalanceCreate(
      businessId: $checkedConvert('business_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
      partyId: $checkedConvert('party_id', (v) => v as String),
      account: $checkedConvert(
        'account',
        (v) => $enumDecode(_$OpeningBalanceCreateAccountEnumEnumMap, v),
      ),
      amountMinor: $checkedConvert('amount_minor', (v) => (v as num).toInt()),
      note: $checkedConvert('note', (v) => v as String?),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'locationId': 'location_id',
    'partyId': 'party_id',
    'amountMinor': 'amount_minor',
    'idempotencyKey': 'idempotency_key',
  },
);

Map<String, dynamic> _$OpeningBalanceCreateToJson(
  OpeningBalanceCreate instance,
) => <String, dynamic>{
  'business_id': instance.businessId,
  'location_id': instance.locationId,
  'party_id': instance.partyId,
  'account': _$OpeningBalanceCreateAccountEnumEnumMap[instance.account]!,
  'amount_minor': instance.amountMinor,
  'note': ?instance.note,
  'idempotency_key': instance.idempotencyKey,
};

const _$OpeningBalanceCreateAccountEnumEnumMap = {
  OpeningBalanceCreateAccountEnum.RECEIVABLE: 'RECEIVABLE',
  OpeningBalanceCreateAccountEnum.PAYABLE: 'PAYABLE',
};
