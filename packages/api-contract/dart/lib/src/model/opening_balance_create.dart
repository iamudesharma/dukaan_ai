//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'opening_balance_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OpeningBalanceCreate {
  /// Returns a new [OpeningBalanceCreate] instance.
  OpeningBalanceCreate({
    required this.businessId,

    required this.locationId,

    required this.partyId,

    required this.account,

    required this.amountMinor,

    this.note,

    required this.idempotencyKey,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: true, includeIfNull: false)
  final String locationId;

  @JsonKey(name: r'party_id', required: true, includeIfNull: false)
  final String partyId;

  /// * `RECEIVABLE` - Customer receivable * `PAYABLE` - Supplier payable
  @JsonKey(name: r'account', required: true, includeIfNull: false)
  final OpeningBalanceCreateAccountEnum account;

  // minimum: 0
  @JsonKey(name: r'amount_minor', required: true, includeIfNull: false)
  final int amountMinor;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'idempotency_key', required: true, includeIfNull: false)
  final String idempotencyKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpeningBalanceCreate &&
          other.businessId == businessId &&
          other.locationId == locationId &&
          other.partyId == partyId &&
          other.account == account &&
          other.amountMinor == amountMinor &&
          other.note == note &&
          other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode =>
      businessId.hashCode +
      locationId.hashCode +
      partyId.hashCode +
      account.hashCode +
      amountMinor.hashCode +
      note.hashCode +
      idempotencyKey.hashCode;

  factory OpeningBalanceCreate.fromJson(Map<String, dynamic> json) =>
      _$OpeningBalanceCreateFromJson(json);

  Map<String, dynamic> toJson() => _$OpeningBalanceCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `RECEIVABLE` - Customer receivable * `PAYABLE` - Supplier payable
enum OpeningBalanceCreateAccountEnum {
  @JsonValue(r'RECEIVABLE')
  RECEIVABLE(r'RECEIVABLE'),
  @JsonValue(r'PAYABLE')
  PAYABLE(r'PAYABLE');

  const OpeningBalanceCreateAccountEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
