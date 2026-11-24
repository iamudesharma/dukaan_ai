//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'party_ledger_entry.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartyLedgerEntry {
  /// Returns a new [PartyLedgerEntry] instance.
  PartyLedgerEntry({
    required this.id,

    required this.business,

    required this.location,

    required this.party,

    required this.account,

    required this.amountMinor,

    required this.sourceType,

    required this.sourceId,

    this.note,

    required this.occurredAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'location', required: true, includeIfNull: false)
  final String location;

  @JsonKey(name: r'party', required: true, includeIfNull: false)
  final String party;

  /// * `RECEIVABLE` - Customer receivable * `PAYABLE` - Supplier payable
  @JsonKey(name: r'account', required: true, includeIfNull: false)
  final PartyLedgerEntryAccountEnum account;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'amount_minor', required: true, includeIfNull: false)
  final int amountMinor;

  @JsonKey(name: r'source_type', required: true, includeIfNull: false)
  final String sourceType;

  @JsonKey(name: r'source_id', required: true, includeIfNull: false)
  final String sourceId;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'occurred_at', required: true, includeIfNull: false)
  final DateTime occurredAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyLedgerEntry &&
          other.id == id &&
          other.business == business &&
          other.location == location &&
          other.party == party &&
          other.account == account &&
          other.amountMinor == amountMinor &&
          other.sourceType == sourceType &&
          other.sourceId == sourceId &&
          other.note == note &&
          other.occurredAt == occurredAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      location.hashCode +
      party.hashCode +
      account.hashCode +
      amountMinor.hashCode +
      sourceType.hashCode +
      sourceId.hashCode +
      note.hashCode +
      occurredAt.hashCode;

  factory PartyLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$PartyLedgerEntryFromJson(json);

  Map<String, dynamic> toJson() => _$PartyLedgerEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `RECEIVABLE` - Customer receivable * `PAYABLE` - Supplier payable
enum PartyLedgerEntryAccountEnum {
  @JsonValue(r'RECEIVABLE')
  RECEIVABLE(r'RECEIVABLE'),
  @JsonValue(r'PAYABLE')
  PAYABLE(r'PAYABLE');

  const PartyLedgerEntryAccountEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
