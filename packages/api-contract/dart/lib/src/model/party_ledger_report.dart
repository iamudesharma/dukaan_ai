//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/party_ledger_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'party_ledger_report.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartyLedgerReport {
  /// Returns a new [PartyLedgerReport] instance.
  PartyLedgerReport({
    required this.partyId,

    required this.balance,

    required this.entries,
  });

  @JsonKey(name: r'party_id', required: true, includeIfNull: false)
  final String partyId;

  @JsonKey(name: r'balance', required: true, includeIfNull: false)
  final int balance;

  @JsonKey(name: r'entries', required: true, includeIfNull: false)
  final List<PartyLedgerEntry> entries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyLedgerReport &&
          other.partyId == partyId &&
          other.balance == balance &&
          other.entries == entries;

  @override
  int get hashCode => partyId.hashCode + balance.hashCode + entries.hashCode;

  factory PartyLedgerReport.fromJson(Map<String, dynamic> json) =>
      _$PartyLedgerReportFromJson(json);

  Map<String, dynamic> toJson() => _$PartyLedgerReportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
