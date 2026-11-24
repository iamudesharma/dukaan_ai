//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExpenseCreate {
  /// Returns a new [ExpenseCreate] instance.
  ExpenseCreate({
    required this.businessId,

    required this.locationId,

    this.expenseDate,

    required this.category,

    this.payee,

    this.note,

    required this.amountMinor,

    this.taxAmountMinor = 0,

    required this.paymentMethod,

    required this.idempotencyKey,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: true, includeIfNull: false)
  final String locationId;

  @JsonKey(name: r'expense_date', required: false, includeIfNull: false)
  final DateTime? expenseDate;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  @JsonKey(name: r'payee', required: false, includeIfNull: false)
  final String? payee;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  // minimum: 1
  @JsonKey(name: r'amount_minor', required: true, includeIfNull: false)
  final int amountMinor;

  // minimum: 0
  @JsonKey(
    defaultValue: 0,
    name: r'tax_amount_minor',
    required: false,
    includeIfNull: false,
  )
  final int? taxAmountMinor;

  /// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
  @JsonKey(name: r'payment_method', required: true, includeIfNull: false)
  final ExpenseCreatePaymentMethodEnum paymentMethod;

  @JsonKey(name: r'idempotency_key', required: true, includeIfNull: false)
  final String idempotencyKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCreate &&
          other.businessId == businessId &&
          other.locationId == locationId &&
          other.expenseDate == expenseDate &&
          other.category == category &&
          other.payee == payee &&
          other.note == note &&
          other.amountMinor == amountMinor &&
          other.taxAmountMinor == taxAmountMinor &&
          other.paymentMethod == paymentMethod &&
          other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode =>
      businessId.hashCode +
      locationId.hashCode +
      expenseDate.hashCode +
      category.hashCode +
      payee.hashCode +
      note.hashCode +
      amountMinor.hashCode +
      taxAmountMinor.hashCode +
      paymentMethod.hashCode +
      idempotencyKey.hashCode;

  factory ExpenseCreate.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCreateFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
enum ExpenseCreatePaymentMethodEnum {
  @JsonValue(r'CASH')
  CASH(r'CASH'),
  @JsonValue(r'UPI')
  UPI(r'UPI'),
  @JsonValue(r'CARD')
  CARD(r'CARD'),
  @JsonValue(r'BANK')
  BANK(r'BANK'),
  @JsonValue(r'OTHER')
  OTHER(r'OTHER');

  const ExpenseCreatePaymentMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
