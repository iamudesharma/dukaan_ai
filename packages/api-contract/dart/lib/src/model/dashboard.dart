//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/dashboard_today.dart';
import 'package:dukaanai_api_client/src/model/dashboard_books.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Dashboard {
  /// Returns a new [Dashboard] instance.
  Dashboard({
    required this.businessId,

    required this.asOf,

    required this.today,

    required this.books,

    required this.lowStockCount,

    required this.grossProfitMinor,

    required this.summary,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'as_of', required: true, includeIfNull: false)
  final DateTime asOf;

  @JsonKey(name: r'today', required: true, includeIfNull: false)
  final DashboardToday today;

  @JsonKey(name: r'books', required: true, includeIfNull: false)
  final DashboardBooks books;

  @JsonKey(name: r'low_stock_count', required: true, includeIfNull: false)
  final int lowStockCount;

  @JsonKey(name: r'gross_profit_minor', required: true, includeIfNull: true)
  final int? grossProfitMinor;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dashboard &&
          other.businessId == businessId &&
          other.asOf == asOf &&
          other.today == today &&
          other.books == books &&
          other.lowStockCount == lowStockCount &&
          other.grossProfitMinor == grossProfitMinor &&
          other.summary == summary;

  @override
  int get hashCode =>
      businessId.hashCode +
      asOf.hashCode +
      today.hashCode +
      books.hashCode +
      lowStockCount.hashCode +
      (grossProfitMinor == null ? 0 : grossProfitMinor.hashCode) +
      summary.hashCode;

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
