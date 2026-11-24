// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_party_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaginatedPartyListCWProxy {
  PaginatedPartyList count(int count);

  PaginatedPartyList next(String? next);

  PaginatedPartyList previous(String? previous);

  PaginatedPartyList results(List<Party> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaginatedPartyList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaginatedPartyList(...).copyWith(id: 12, name: "My name")
  /// ````
  PaginatedPartyList call({
    int count,
    String? next,
    String? previous,
    List<Party> results,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaginatedPartyList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaginatedPartyList.copyWith.fieldName(...)`
class _$PaginatedPartyListCWProxyImpl implements _$PaginatedPartyListCWProxy {
  const _$PaginatedPartyListCWProxyImpl(this._value);

  final PaginatedPartyList _value;

  @override
  PaginatedPartyList count(int count) => this(count: count);

  @override
  PaginatedPartyList next(String? next) => this(next: next);

  @override
  PaginatedPartyList previous(String? previous) => this(previous: previous);

  @override
  PaginatedPartyList results(List<Party> results) => this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaginatedPartyList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaginatedPartyList(...).copyWith(id: 12, name: "My name")
  /// ````
  PaginatedPartyList call({
    Object? count = const $CopyWithPlaceholder(),
    Object? next = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? results = const $CopyWithPlaceholder(),
  }) {
    return PaginatedPartyList(
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
          : results as List<Party>,
    );
  }
}

extension $PaginatedPartyListCopyWith on PaginatedPartyList {
  /// Returns a callable class that can be used as follows: `instanceOfPaginatedPartyList.copyWith(...)` or like so:`instanceOfPaginatedPartyList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaginatedPartyListCWProxy get copyWith =>
      _$PaginatedPartyListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedPartyList _$PaginatedPartyListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PaginatedPartyList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['count', 'results']);
      final val = PaginatedPartyList(
        count: $checkedConvert('count', (v) => (v as num).toInt()),
        next: $checkedConvert('next', (v) => v as String?),
        previous: $checkedConvert('previous', (v) => v as String?),
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => Party.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PaginatedPartyListToJson(PaginatedPartyList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': ?instance.next,
      'previous': ?instance.previous,
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
