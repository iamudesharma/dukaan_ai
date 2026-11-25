// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_report_row.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StockReportRowCWProxy {
  StockReportRow productId(String productId);

  StockReportRow name(String name);

  StockReportRow unit(String unit);

  StockReportRow quantity(double quantity);

  StockReportRow lowStockThreshold(double lowStockThreshold);

  StockReportRow isLowStock(bool isLowStock);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StockReportRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StockReportRow(...).copyWith(id: 12, name: "My name")
  /// ````
  StockReportRow call({
    String productId,
    String name,
    String unit,
    double quantity,
    double lowStockThreshold,
    bool isLowStock,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStockReportRow.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStockReportRow.copyWith.fieldName(...)`
class _$StockReportRowCWProxyImpl implements _$StockReportRowCWProxy {
  const _$StockReportRowCWProxyImpl(this._value);

  final StockReportRow _value;

  @override
  StockReportRow productId(String productId) => this(productId: productId);

  @override
  StockReportRow name(String name) => this(name: name);

  @override
  StockReportRow unit(String unit) => this(unit: unit);

  @override
  StockReportRow quantity(double quantity) => this(quantity: quantity);

  @override
  StockReportRow lowStockThreshold(double lowStockThreshold) =>
      this(lowStockThreshold: lowStockThreshold);

  @override
  StockReportRow isLowStock(bool isLowStock) => this(isLowStock: isLowStock);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StockReportRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StockReportRow(...).copyWith(id: 12, name: "My name")
  /// ````
  StockReportRow call({
    Object? productId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? unit = const $CopyWithPlaceholder(),
    Object? quantity = const $CopyWithPlaceholder(),
    Object? lowStockThreshold = const $CopyWithPlaceholder(),
    Object? isLowStock = const $CopyWithPlaceholder(),
  }) {
    return StockReportRow(
      productId: productId == const $CopyWithPlaceholder()
          ? _value.productId
          // ignore: cast_nullable_to_non_nullable
          : productId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      unit: unit == const $CopyWithPlaceholder()
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as String,
      quantity: quantity == const $CopyWithPlaceholder()
          ? _value.quantity
          // ignore: cast_nullable_to_non_nullable
          : quantity as double,
      lowStockThreshold: lowStockThreshold == const $CopyWithPlaceholder()
          ? _value.lowStockThreshold
          // ignore: cast_nullable_to_non_nullable
          : lowStockThreshold as double,
      isLowStock: isLowStock == const $CopyWithPlaceholder()
          ? _value.isLowStock
          // ignore: cast_nullable_to_non_nullable
          : isLowStock as bool,
    );
  }
}

extension $StockReportRowCopyWith on StockReportRow {
  /// Returns a callable class that can be used as follows: `instanceOfStockReportRow.copyWith(...)` or like so:`instanceOfStockReportRow.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StockReportRowCWProxy get copyWith => _$StockReportRowCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockReportRow _$StockReportRowFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'StockReportRow',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'product_id',
            'name',
            'unit',
            'quantity',
            'low_stock_threshold',
            'is_low_stock',
          ],
        );
        final val = StockReportRow(
          productId: $checkedConvert('product_id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          unit: $checkedConvert('unit', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => (v as num).toDouble()),
          lowStockThreshold: $checkedConvert(
            'low_stock_threshold',
            (v) => (v as num).toDouble(),
          ),
          isLowStock: $checkedConvert('is_low_stock', (v) => v as bool),
        );
        return val;
      },
      fieldKeyMap: const {
        'productId': 'product_id',
        'lowStockThreshold': 'low_stock_threshold',
        'isLowStock': 'is_low_stock',
      },
    );

Map<String, dynamic> _$StockReportRowToJson(StockReportRow instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'name': instance.name,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'low_stock_threshold': instance.lowStockThreshold,
      'is_low_stock': instance.isLowStock,
    };
