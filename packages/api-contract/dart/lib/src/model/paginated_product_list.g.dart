// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_product_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaginatedProductListCWProxy {
  PaginatedProductList count(int count);

  PaginatedProductList next(String? next);

  PaginatedProductList previous(String? previous);

  PaginatedProductList results(List<Product> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaginatedProductList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaginatedProductList(...).copyWith(id: 12, name: "My name")
  /// ````
  PaginatedProductList call({
    int count,
    String? next,
    String? previous,
    List<Product> results,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaginatedProductList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaginatedProductList.copyWith.fieldName(...)`
class _$PaginatedProductListCWProxyImpl
    implements _$PaginatedProductListCWProxy {
  const _$PaginatedProductListCWProxyImpl(this._value);

  final PaginatedProductList _value;

  @override
  PaginatedProductList count(int count) => this(count: count);

  @override
  PaginatedProductList next(String? next) => this(next: next);

  @override
  PaginatedProductList previous(String? previous) => this(previous: previous);

  @override
  PaginatedProductList results(List<Product> results) => this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaginatedProductList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaginatedProductList(...).copyWith(id: 12, name: "My name")
  /// ````
  PaginatedProductList call({
    Object? count = const $CopyWithPlaceholder(),
    Object? next = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? results = const $CopyWithPlaceholder(),
  }) {
    return PaginatedProductList(
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
      next: next == const $CopyWithPlaceholder()
          ? _value.next
          // ignore: cast_nullable_to_non_nullable
          : next as String?,
      previous: previous == const $CopyWithPlaceholder()
          ? _value.previous
          // ignore: cast_nullable_to_non_nullable
          : previous as String?,
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<Product>,
    );
  }
}

extension $PaginatedProductListCopyWith on PaginatedProductList {
  /// Returns a callable class that can be used as follows: `instanceOfPaginatedProductList.copyWith(...)` or like so:`instanceOfPaginatedProductList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaginatedProductListCWProxy get copyWith =>
      _$PaginatedProductListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedProductList _$PaginatedProductListFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PaginatedProductList', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['count', 'results']);
  final val = PaginatedProductList(
    count: $checkedConvert('count', (v) => (v as num).toInt()),
    next: $checkedConvert('next', (v) => v as String?),
    previous: $checkedConvert('previous', (v) => v as String?),
    results: $checkedConvert(
      'results',
      (v) => (v as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$PaginatedProductListToJson(
  PaginatedProductList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': ?instance.next,
  'previous': ?instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};
