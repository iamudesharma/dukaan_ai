//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_books.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardBooks {
  /// Returns a new [DashboardBooks] instance.
  DashboardBooks({
    required this.salesMinor,

    required this.purchasesMinor,

    required this.expensesMinor,

    required this.receiptsMinor,

    required this.supplierPaymentsMinor,

    required this.receivableMinor,

    required this.payableMinor,

    required this.cashFlowMinor,
  });

  @JsonKey(name: r'sales_minor', required: true, includeIfNull: false)
  final int salesMinor;

  @JsonKey(name: r'purchases_minor', required: true, includeIfNull: false)
  final int purchasesMinor;

  @JsonKey(name: r'expenses_minor', required: true, includeIfNull: false)
  final int expensesMinor;

  @JsonKey(name: r'receipts_minor', required: true, includeIfNull: false)
  final int receiptsMinor;

  @JsonKey(
    name: r'supplier_payments_minor',
    required: true,
    includeIfNull: false,
  )
  final int supplierPaymentsMinor;

  @JsonKey(name: r'receivable_minor', required: true, includeIfNull: false)
  final int receivableMinor;

  @JsonKey(name: r'payable_minor', required: true, includeIfNull: false)
  final int payableMinor;

  @JsonKey(name: r'cash_flow_minor', required: true, includeIfNull: false)
  final int cashFlowMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardBooks &&
          other.salesMinor == salesMinor &&
          other.purchasesMinor == purchasesMinor &&
          other.expensesMinor == expensesMinor &&
          other.receiptsMinor == receiptsMinor &&
          other.supplierPaymentsMinor == supplierPaymentsMinor &&
          other.receivableMinor == receivableMinor &&
          other.payableMinor == payableMinor &&
          other.cashFlowMinor == cashFlowMinor;

  @override
  int get hashCode =>
      salesMinor.hashCode +
      purchasesMinor.hashCode +
      expensesMinor.hashCode +
      receiptsMinor.hashCode +
      supplierPaymentsMinor.hashCode +
      receivableMinor.hashCode +
      payableMinor.hashCode +
      cashFlowMinor.hashCode;

  factory DashboardBooks.fromJson(Map<String, dynamic> json) =>
      _$DashboardBooksFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardBooksToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
