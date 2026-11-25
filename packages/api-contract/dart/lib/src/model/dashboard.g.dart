// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardCWProxy {
  Dashboard businessId(String businessId);

  Dashboard asOf(DateTime asOf);

  Dashboard today(DashboardToday today);

  Dashboard books(DashboardBooks books);

  Dashboard lowStockCount(int lowStockCount);

  Dashboard grossProfitMinor(int? grossProfitMinor);

  Dashboard summary(String summary);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Dashboard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Dashboard(...).copyWith(id: 12, name: "My name")
  /// ````
  Dashboard call({
    String businessId,
    DateTime asOf,
    DashboardToday today,
    DashboardBooks books,
    int lowStockCount,
    int? grossProfitMinor,
    String summary,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboard.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboard.copyWith.fieldName(...)`
class _$DashboardCWProxyImpl implements _$DashboardCWProxy {
  const _$DashboardCWProxyImpl(this._value);

  final Dashboard _value;

  @override
  Dashboard businessId(String businessId) => this(businessId: businessId);

  @override
  Dashboard asOf(DateTime asOf) => this(asOf: asOf);

  @override
  Dashboard today(DashboardToday today) => this(today: today);

  @override
  Dashboard books(DashboardBooks books) => this(books: books);

  @override
  Dashboard lowStockCount(int lowStockCount) =>
      this(lowStockCount: lowStockCount);

  @override
  Dashboard grossProfitMinor(int? grossProfitMinor) =>
      this(grossProfitMinor: grossProfitMinor);

  @override
  Dashboard summary(String summary) => this(summary: summary);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Dashboard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Dashboard(...).copyWith(id: 12, name: "My name")
  /// ````
  Dashboard call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? asOf = const $CopyWithPlaceholder(),
    Object? today = const $CopyWithPlaceholder(),
    Object? books = const $CopyWithPlaceholder(),
    Object? lowStockCount = const $CopyWithPlaceholder(),
    Object? grossProfitMinor = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
  }) {
    return Dashboard(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      asOf: asOf == const $CopyWithPlaceholder()
          ? _value.asOf
          // ignore: cast_nullable_to_non_nullable
          : asOf as DateTime,
      today: today == const $CopyWithPlaceholder()
          ? _value.today
          // ignore: cast_nullable_to_non_nullable
          : today as DashboardToday,
      books: books == const $CopyWithPlaceholder()
          ? _value.books
          // ignore: cast_nullable_to_non_nullable
          : books as DashboardBooks,
      lowStockCount: lowStockCount == const $CopyWithPlaceholder()
          ? _value.lowStockCount
          // ignore: cast_nullable_to_non_nullable
          : lowStockCount as int,
      grossProfitMinor: grossProfitMinor == const $CopyWithPlaceholder()
          ? _value.grossProfitMinor
          // ignore: cast_nullable_to_non_nullable
          : grossProfitMinor as int?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
    );
  }
}

extension $DashboardCopyWith on Dashboard {
  /// Returns a callable class that can be used as follows: `instanceOfDashboard.copyWith(...)` or like so:`instanceOfDashboard.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardCWProxy get copyWith => _$DashboardCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dashboard _$DashboardFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Dashboard',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'business_id',
        'as_of',
        'today',
        'books',
        'low_stock_count',
        'gross_profit_minor',
        'summary',
      ],
    );
    final val = Dashboard(
      businessId: $checkedConvert('business_id', (v) => v as String),
      asOf: $checkedConvert('as_of', (v) => DateTime.parse(v as String)),
      today: $checkedConvert(
        'today',
        (v) => DashboardToday.fromJson(v as Map<String, dynamic>),
      ),
      books: $checkedConvert(
        'books',
        (v) => DashboardBooks.fromJson(v as Map<String, dynamic>),
      ),
      lowStockCount: $checkedConvert(
        'low_stock_count',
        (v) => (v as num).toInt(),
      ),
      grossProfitMinor: $checkedConvert(
        'gross_profit_minor',
        (v) => (v as num?)?.toInt(),
      ),
      summary: $checkedConvert('summary', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'asOf': 'as_of',
    'lowStockCount': 'low_stock_count',
    'grossProfitMinor': 'gross_profit_minor',
  },
);

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
  'business_id': instance.businessId,
  'as_of': instance.asOf.toIso8601String(),
  'today': instance.today.toJson(),
  'books': instance.books.toJson(),
  'low_stock_count': instance.lowStockCount,
  'gross_profit_minor': instance.grossProfitMinor,
  'summary': instance.summary,
};
