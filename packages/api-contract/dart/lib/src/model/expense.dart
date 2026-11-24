//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Expense {
  /// Returns a new [Expense] instance.
  Expense({
    required this.id,

    required this.business,

    required this.location,

    this.status,

    required this.number,

    required this.documentDate,

    required this.category,

    this.payee,

    this.note,

    required this.amountMinor,

    this.taxAmountMinor,

    required this.totalMinor,

    required this.paymentMethod,

    this.source_,

    required this.postedAt,

    this.reversalReason,

    this.reversedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'location', required: true, includeIfNull: false)
  final String location;

  /// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final ExpenseStatusEnum? status;

  @JsonKey(name: r'number', required: true, includeIfNull: false)
  final String number;

  @JsonKey(name: r'document_date', required: true, includeIfNull: false)
  final DateTime documentDate;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  @JsonKey(name: r'payee', required: false, includeIfNull: false)
  final String? payee;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'amount_minor', required: true, includeIfNull: false)
  final int amountMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'tax_amount_minor', required: false, includeIfNull: false)
  final int? taxAmountMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'total_minor', required: true, includeIfNull: false)
  final int totalMinor;

  /// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
  @JsonKey(name: r'payment_method', required: true, includeIfNull: false)
  final ExpensePaymentMethodEnum paymentMethod;

  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final String? source_;

  @JsonKey(name: r'posted_at', required: true, includeIfNull: false)
  final DateTime postedAt;

  @JsonKey(name: r'reversal_reason', required: false, includeIfNull: false)
  final String? reversalReason;

  @JsonKey(name: r'reversed_at', required: false, includeIfNull: false)
  final DateTime? reversedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          other.id == id &&
          other.business == business &&
          other.location == location &&
          other.status == status &&
          other.number == number &&
          other.documentDate == documentDate &&
          other.category == category &&
          other.payee == payee &&
          other.note == note &&
          other.amountMinor == amountMinor &&
          other.taxAmountMinor == taxAmountMinor &&
          other.totalMinor == totalMinor &&
          other.paymentMethod == paymentMethod &&
          other.source_ == source_ &&
          other.postedAt == postedAt &&
          other.reversalReason == reversalReason &&
          other.reversedAt == reversedAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      location.hashCode +
      status.hashCode +
      number.hashCode +
      documentDate.hashCode +
      category.hashCode +
      payee.hashCode +
      note.hashCode +
      amountMinor.hashCode +
      taxAmountMinor.hashCode +
      totalMinor.hashCode +
      paymentMethod.hashCode +
      source_.hashCode +
      postedAt.hashCode +
      reversalReason.hashCode +
      (reversedAt == null ? 0 : reversedAt.hashCode);

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
enum ExpenseStatusEnum {
  @JsonValue(r'DRAFT')
  DRAFT(r'DRAFT'),
  @JsonValue(r'POSTED')
  POSTED(r'POSTED'),
  @JsonValue(r'REVERSED')
  REVERSED(r'REVERSED');

  const ExpenseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
enum ExpensePaymentMethodEnum {
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

  const ExpensePaymentMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
