//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_today.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardToday {
  /// Returns a new [DashboardToday] instance.
  DashboardToday({
    required this.salesMinor,

    required this.purchasesMinor,

    required this.expensesMinor,

    required this.receiptsMinor,
  });

  @JsonKey(name: r'sales_minor', required: true, includeIfNull: false)
  final int salesMinor;

  @JsonKey(name: r'purchases_minor', required: true, includeIfNull: false)
  final int purchasesMinor;

  @JsonKey(name: r'expenses_minor', required: true, includeIfNull: false)
  final int expensesMinor;

  @JsonKey(name: r'receipts_minor', required: true, includeIfNull: false)
  final int receiptsMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardToday &&
          other.salesMinor == salesMinor &&
          other.purchasesMinor == purchasesMinor &&
          other.expensesMinor == expensesMinor &&
          other.receiptsMinor == receiptsMinor;

  @override
  int get hashCode =>
      salesMinor.hashCode +
      purchasesMinor.hashCode +
      expensesMinor.hashCode +
      receiptsMinor.hashCode;

  factory DashboardToday.fromJson(Map<String, dynamic> json) =>
      _$DashboardTodayFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardTodayToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
