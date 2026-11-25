// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_assistant_proposal_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaginatedAssistantProposalListCWProxy {
  PaginatedAssistantProposalList count(int count);

  PaginatedAssistantProposalList next(String? next);

  PaginatedAssistantProposalList previous(String? previous);

  PaginatedAssistantProposalList results(List<AssistantProposal> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaginatedAssistantProposalList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaginatedAssistantProposalList(...).copyWith(id: 12, name: "My name")
  /// ````
  PaginatedAssistantProposalList call({
    int count,
    String? next,
    String? previous,
    List<AssistantProposal> results,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaginatedAssistantProposalList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaginatedAssistantProposalList.copyWith.fieldName(...)`
class _$PaginatedAssistantProposalListCWProxyImpl
    implements _$PaginatedAssistantProposalListCWProxy {
  const _$PaginatedAssistantProposalListCWProxyImpl(this._value);

  final PaginatedAssistantProposalList _value;

  @override
  PaginatedAssistantProposalList count(int count) => this(count: count);

  @override
  PaginatedAssistantProposalList next(String? next) => this(next: next);

  @override
  PaginatedAssistantProposalList previous(String? previous) =>
      this(previous: previous);

  @override
  PaginatedAssistantProposalList results(List<AssistantProposal> results) =>
      this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaginatedAssistantProposalList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaginatedAssistantProposalList(...).copyWith(id: 12, name: "My name")
  /// ````
  PaginatedAssistantProposalList call({
    Object? count = const $CopyWithPlaceholder(),
    Object? next = const $CopyWithPlaceholder(),
    Object? previous = const $CopyWithPlaceholder(),
    Object? results = const $CopyWithPlaceholder(),
  }) {
    return PaginatedAssistantProposalList(
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
          : results as List<AssistantProposal>,
    );
  }
}

extension $PaginatedAssistantProposalListCopyWith
    on PaginatedAssistantProposalList {
  /// Returns a callable class that can be used as follows: `instanceOfPaginatedAssistantProposalList.copyWith(...)` or like so:`instanceOfPaginatedAssistantProposalList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaginatedAssistantProposalListCWProxy get copyWith =>
      _$PaginatedAssistantProposalListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedAssistantProposalList _$PaginatedAssistantProposalListFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PaginatedAssistantProposalList', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['count', 'results']);
  final val = PaginatedAssistantProposalList(
    count: $checkedConvert('count', (v) => (v as num).toInt()),
    next: $checkedConvert('next', (v) => v as String?),
    previous: $checkedConvert('previous', (v) => v as String?),
    results: $checkedConvert(
      'results',
      (v) => (v as List<dynamic>)
          .map((e) => AssistantProposal.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$PaginatedAssistantProposalListToJson(
  PaginatedAssistantProposalList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': ?instance.next,
  'previous': ?instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};
