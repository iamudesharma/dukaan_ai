// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeCWProxy {
  Me id(String id);

  Me phone(String phone);

  Me displayName(String displayName);

  Me memberships(List<MembershipSummary> memberships);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Me(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Me(...).copyWith(id: 12, name: "My name")
  /// ````
  Me call({
    String id,
    String phone,
    String displayName,
    List<MembershipSummary> memberships,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMe.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMe.copyWith.fieldName(...)`
class _$MeCWProxyImpl implements _$MeCWProxy {
  const _$MeCWProxyImpl(this._value);

  final Me _value;

  @override
  Me id(String id) => this(id: id);

  @override
  Me phone(String phone) => this(phone: phone);

  @override
  Me displayName(String displayName) => this(displayName: displayName);

  @override
  Me memberships(List<MembershipSummary> memberships) =>
      this(memberships: memberships);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Me(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Me(...).copyWith(id: 12, name: "My name")
  /// ````
  Me call({
    Object? id = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? memberships = const $CopyWithPlaceholder(),
  }) {
    return Me(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String,
      memberships: memberships == const $CopyWithPlaceholder()
          ? _value.memberships
          // ignore: cast_nullable_to_non_nullable
          : memberships as List<MembershipSummary>,
    );
  }
}

extension $MeCopyWith on Me {
  /// Returns a callable class that can be used as follows: `instanceOfMe.copyWith(...)` or like so:`instanceOfMe.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeCWProxy get copyWith => _$MeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Me _$MeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Me', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'phone', 'display_name', 'memberships'],
      );
      final val = Me(
        id: $checkedConvert('id', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String),
        displayName: $checkedConvert('display_name', (v) => v as String),
        memberships: $checkedConvert(
          'memberships',
          (v) => (v as List<dynamic>)
              .map((e) => MembershipSummary.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'displayName': 'display_name'});

Map<String, dynamic> _$MeToJson(Me instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'display_name': instance.displayName,
  'memberships': instance.memberships.map((e) => e.toJson()).toList(),
};
