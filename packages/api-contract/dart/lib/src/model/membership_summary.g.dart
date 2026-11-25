// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MembershipSummaryCWProxy {
  MembershipSummary businessId(String businessId);

  MembershipSummary businessName(String businessName);

  MembershipSummary role(MembershipSummaryRoleEnum role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MembershipSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MembershipSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  MembershipSummary call({
    String businessId,
    String businessName,
    MembershipSummaryRoleEnum role,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMembershipSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMembershipSummary.copyWith.fieldName(...)`
class _$MembershipSummaryCWProxyImpl implements _$MembershipSummaryCWProxy {
  const _$MembershipSummaryCWProxyImpl(this._value);

  final MembershipSummary _value;

  @override
  MembershipSummary businessId(String businessId) =>
      this(businessId: businessId);

  @override
  MembershipSummary businessName(String businessName) =>
      this(businessName: businessName);

  @override
  MembershipSummary role(MembershipSummaryRoleEnum role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MembershipSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MembershipSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  MembershipSummary call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? businessName = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return MembershipSummary(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      businessName: businessName == const $CopyWithPlaceholder()
          ? _value.businessName
          // ignore: cast_nullable_to_non_nullable
          : businessName as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as MembershipSummaryRoleEnum,
    );
  }
}

extension $MembershipSummaryCopyWith on MembershipSummary {
  /// Returns a callable class that can be used as follows: `instanceOfMembershipSummary.copyWith(...)` or like so:`instanceOfMembershipSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MembershipSummaryCWProxy get copyWith =>
      _$MembershipSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipSummary _$MembershipSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MembershipSummary',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['business_id', 'business_name', 'role'],
        );
        final val = MembershipSummary(
          businessId: $checkedConvert('business_id', (v) => v as String),
          businessName: $checkedConvert('business_name', (v) => v as String),
          role: $checkedConvert(
            'role',
            (v) => $enumDecode(_$MembershipSummaryRoleEnumEnumMap, v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'businessId': 'business_id',
        'businessName': 'business_name',
      },
    );

Map<String, dynamic> _$MembershipSummaryToJson(MembershipSummary instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'business_name': instance.businessName,
      'role': _$MembershipSummaryRoleEnumEnumMap[instance.role]!,
    };

const _$MembershipSummaryRoleEnumEnumMap = {
  MembershipSummaryRoleEnum.OWNER: 'OWNER',
  MembershipSummaryRoleEnum.MANAGER: 'MANAGER',
  MembershipSummaryRoleEnum.CASHIER: 'CASHIER',
};
