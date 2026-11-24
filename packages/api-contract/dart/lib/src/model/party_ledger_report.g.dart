// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_ledger_report.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PartyLedgerReportCWProxy {
  PartyLedgerReport partyId(String partyId);

  PartyLedgerReport balance(int balance);

  PartyLedgerReport entries(List<PartyLedgerEntry> entries);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PartyLedgerReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PartyLedgerReport(...).copyWith(id: 12, name: "My name")
  /// ````
  PartyLedgerReport call({
    String partyId,
    int balance,
    List<PartyLedgerEntry> entries,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPartyLedgerReport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPartyLedgerReport.copyWith.fieldName(...)`
class _$PartyLedgerReportCWProxyImpl implements _$PartyLedgerReportCWProxy {
  const _$PartyLedgerReportCWProxyImpl(this._value);

  final PartyLedgerReport _value;

  @override
  PartyLedgerReport partyId(String partyId) => this(partyId: partyId);

  @override
  PartyLedgerReport balance(int balance) => this(balance: balance);

  @override
  PartyLedgerReport entries(List<PartyLedgerEntry> entries) =>
      this(entries: entries);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PartyLedgerReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PartyLedgerReport(...).copyWith(id: 12, name: "My name")
  /// ````
  PartyLedgerReport call({
    Object? partyId = const $CopyWithPlaceholder(),
    Object? balance = const $CopyWithPlaceholder(),
    Object? entries = const $CopyWithPlaceholder(),
  }) {
    return PartyLedgerReport(
      partyId: partyId == const $CopyWithPlaceholder()
          ? _value.partyId
          // ignore: cast_nullable_to_non_nullable
          : partyId as String,
      balance: balance == const $CopyWithPlaceholder()
          ? _value.balance
          // ignore: cast_nullable_to_non_nullable
          : balance as int,
      entries: entries == const $CopyWithPlaceholder()
          ? _value.entries
          // ignore: cast_nullable_to_non_nullable
          : entries as List<PartyLedgerEntry>,
    );
  }
}

extension $PartyLedgerReportCopyWith on PartyLedgerReport {
  /// Returns a callable class that can be used as follows: `instanceOfPartyLedgerReport.copyWith(...)` or like so:`instanceOfPartyLedgerReport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PartyLedgerReportCWProxy get copyWith =>
      _$PartyLedgerReportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartyLedgerReport _$PartyLedgerReportFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PartyLedgerReport', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['party_id', 'balance', 'entries']);
      final val = PartyLedgerReport(
        partyId: $checkedConvert('party_id', (v) => v as String),
        balance: $checkedConvert('balance', (v) => (v as num).toInt()),
        entries: $checkedConvert(
          'entries',
          (v) => (v as List<dynamic>)
              .map((e) => PartyLedgerEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'partyId': 'party_id'});

Map<String, dynamic> _$PartyLedgerReportToJson(PartyLedgerReport instance) =>
    <String, dynamic>{
      'party_id': instance.partyId,
      'balance': instance.balance,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };
