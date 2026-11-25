// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_ledger_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PartyLedgerEntryCWProxy {
  PartyLedgerEntry id(String id);

  PartyLedgerEntry business(String business);

  PartyLedgerEntry location(String location);

  PartyLedgerEntry party(String party);

  PartyLedgerEntry account(PartyLedgerEntryAccountEnum account);

  PartyLedgerEntry amountMinor(int amountMinor);

  PartyLedgerEntry sourceType(String sourceType);

  PartyLedgerEntry sourceId(String sourceId);

  PartyLedgerEntry note(String? note);

  PartyLedgerEntry occurredAt(DateTime occurredAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PartyLedgerEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PartyLedgerEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  PartyLedgerEntry call({
    String id,
    String business,
    String location,
    String party,
    PartyLedgerEntryAccountEnum account,
    int amountMinor,
    String sourceType,
    String sourceId,
    String? note,
    DateTime occurredAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPartyLedgerEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPartyLedgerEntry.copyWith.fieldName(...)`
class _$PartyLedgerEntryCWProxyImpl implements _$PartyLedgerEntryCWProxy {
  const _$PartyLedgerEntryCWProxyImpl(this._value);

  final PartyLedgerEntry _value;

  @override
  PartyLedgerEntry id(String id) => this(id: id);

  @override
  PartyLedgerEntry business(String business) => this(business: business);

  @override
  PartyLedgerEntry location(String location) => this(location: location);

  @override
  PartyLedgerEntry party(String party) => this(party: party);

  @override
  PartyLedgerEntry account(PartyLedgerEntryAccountEnum account) =>
      this(account: account);

  @override
  PartyLedgerEntry amountMinor(int amountMinor) =>
      this(amountMinor: amountMinor);

  @override
  PartyLedgerEntry sourceType(String sourceType) =>
      this(sourceType: sourceType);

  @override
  PartyLedgerEntry sourceId(String sourceId) => this(sourceId: sourceId);

  @override
  PartyLedgerEntry note(String? note) => this(note: note);

  @override
  PartyLedgerEntry occurredAt(DateTime occurredAt) =>
      this(occurredAt: occurredAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PartyLedgerEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PartyLedgerEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  PartyLedgerEntry call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? party = const $CopyWithPlaceholder(),
    Object? account = const $CopyWithPlaceholder(),
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? sourceType = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? occurredAt = const $CopyWithPlaceholder(),
  }) {
    return PartyLedgerEntry(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as String,
      party: party == const $CopyWithPlaceholder()
          ? _value.party
          // ignore: cast_nullable_to_non_nullable
          : party as String,
      account: account == const $CopyWithPlaceholder()
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as PartyLedgerEntryAccountEnum,
      amountMinor: amountMinor == const $CopyWithPlaceholder()
          ? _value.amountMinor
          // ignore: cast_nullable_to_non_nullable
          : amountMinor as int,
      sourceType: sourceType == const $CopyWithPlaceholder()
          ? _value.sourceType
          // ignore: cast_nullable_to_non_nullable
          : sourceType as String,
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      occurredAt: occurredAt == const $CopyWithPlaceholder()
          ? _value.occurredAt
          // ignore: cast_nullable_to_non_nullable
          : occurredAt as DateTime,
    );
  }
}

extension $PartyLedgerEntryCopyWith on PartyLedgerEntry {
  /// Returns a callable class that can be used as follows: `instanceOfPartyLedgerEntry.copyWith(...)` or like so:`instanceOfPartyLedgerEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PartyLedgerEntryCWProxy get copyWith => _$PartyLedgerEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartyLedgerEntry _$PartyLedgerEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PartyLedgerEntry',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'business',
            'location',
            'party',
            'account',
            'amount_minor',
            'source_type',
            'source_id',
            'occurred_at',
          ],
        );
        final val = PartyLedgerEntry(
          id: $checkedConvert('id', (v) => v as String),
          business: $checkedConvert('business', (v) => v as String),
          location: $checkedConvert('location', (v) => v as String),
          party: $checkedConvert('party', (v) => v as String),
          account: $checkedConvert(
            'account',
            (v) => $enumDecode(_$PartyLedgerEntryAccountEnumEnumMap, v),
          ),
          amountMinor: $checkedConvert(
            'amount_minor',
            (v) => (v as num).toInt(),
          ),
          sourceType: $checkedConvert('source_type', (v) => v as String),
          sourceId: $checkedConvert('source_id', (v) => v as String),
          note: $checkedConvert('note', (v) => v as String?),
          occurredAt: $checkedConvert(
            'occurred_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'amountMinor': 'amount_minor',
        'sourceType': 'source_type',
        'sourceId': 'source_id',
        'occurredAt': 'occurred_at',
      },
    );

Map<String, dynamic> _$PartyLedgerEntryToJson(PartyLedgerEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business': instance.business,
      'location': instance.location,
      'party': instance.party,
      'account': _$PartyLedgerEntryAccountEnumEnumMap[instance.account]!,
      'amount_minor': instance.amountMinor,
      'source_type': instance.sourceType,
      'source_id': instance.sourceId,
      'note': ?instance.note,
      'occurred_at': instance.occurredAt.toIso8601String(),
    };

const _$PartyLedgerEntryAccountEnumEnumMap = {
  PartyLedgerEntryAccountEnum.RECEIVABLE: 'RECEIVABLE',
  PartyLedgerEntryAccountEnum.PAYABLE: 'PAYABLE',
};
