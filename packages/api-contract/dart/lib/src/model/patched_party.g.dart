// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patched_party.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PatchedPartyCWProxy {
  PatchedParty id(String? id);

  PatchedParty business(String? business);

  PatchedParty name(String? name);

  PatchedParty kind(PatchedPartyKindEnum? kind);

  PatchedParty phoneE164(String? phoneE164);

  PatchedParty gstin(String? gstin);

  PatchedParty stateCode(String? stateCode);

  PatchedParty address(String? address);

  PatchedParty isActive(bool? isActive);

  PatchedParty receivableMinor(int? receivableMinor);

  PatchedParty payableMinor(int? payableMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedParty(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedParty(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedParty call({
    String? id,
    String? business,
    String? name,
    PatchedPartyKindEnum? kind,
    String? phoneE164,
    String? gstin,
    String? stateCode,
    String? address,
    bool? isActive,
    int? receivableMinor,
    int? payableMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPatchedParty.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPatchedParty.copyWith.fieldName(...)`
class _$PatchedPartyCWProxyImpl implements _$PatchedPartyCWProxy {
  const _$PatchedPartyCWProxyImpl(this._value);

  final PatchedParty _value;

  @override
  PatchedParty id(String? id) => this(id: id);

  @override
  PatchedParty business(String? business) => this(business: business);

  @override
  PatchedParty name(String? name) => this(name: name);

  @override
  PatchedParty kind(PatchedPartyKindEnum? kind) => this(kind: kind);

  @override
  PatchedParty phoneE164(String? phoneE164) => this(phoneE164: phoneE164);

  @override
  PatchedParty gstin(String? gstin) => this(gstin: gstin);

  @override
  PatchedParty stateCode(String? stateCode) => this(stateCode: stateCode);

  @override
  PatchedParty address(String? address) => this(address: address);

  @override
  PatchedParty isActive(bool? isActive) => this(isActive: isActive);

  @override
  PatchedParty receivableMinor(int? receivableMinor) =>
      this(receivableMinor: receivableMinor);

  @override
  PatchedParty payableMinor(int? payableMinor) =>
      this(payableMinor: payableMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedParty(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedParty(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedParty call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? phoneE164 = const $CopyWithPlaceholder(),
    Object? gstin = const $CopyWithPlaceholder(),
    Object? stateCode = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
    Object? receivableMinor = const $CopyWithPlaceholder(),
    Object? payableMinor = const $CopyWithPlaceholder(),
  }) {
    return PatchedParty(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as PatchedPartyKindEnum?,
      phoneE164: phoneE164 == const $CopyWithPlaceholder()
          ? _value.phoneE164
          // ignore: cast_nullable_to_non_nullable
          : phoneE164 as String?,
      gstin: gstin == const $CopyWithPlaceholder()
          ? _value.gstin
          // ignore: cast_nullable_to_non_nullable
          : gstin as String?,
      stateCode: stateCode == const $CopyWithPlaceholder()
          ? _value.stateCode
          // ignore: cast_nullable_to_non_nullable
          : stateCode as String?,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String?,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool?,
      receivableMinor: receivableMinor == const $CopyWithPlaceholder()
          ? _value.receivableMinor
          // ignore: cast_nullable_to_non_nullable
          : receivableMinor as int?,
      payableMinor: payableMinor == const $CopyWithPlaceholder()
          ? _value.payableMinor
          // ignore: cast_nullable_to_non_nullable
          : payableMinor as int?,
    );
  }
}

extension $PatchedPartyCopyWith on PatchedParty {
  /// Returns a callable class that can be used as follows: `instanceOfPatchedParty.copyWith(...)` or like so:`instanceOfPatchedParty.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PatchedPartyCWProxy get copyWith => _$PatchedPartyCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchedParty _$PatchedPartyFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PatchedParty',
      json,
      ($checkedConvert) {
        final val = PatchedParty(
          id: $checkedConvert('id', (v) => v as String?),
          business: $checkedConvert('business', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String?),
          kind: $checkedConvert(
            'kind',
            (v) => $enumDecodeNullable(_$PatchedPartyKindEnumEnumMap, v),
          ),
          phoneE164: $checkedConvert('phone_e164', (v) => v as String?),
          gstin: $checkedConvert('gstin', (v) => v as String?),
          stateCode: $checkedConvert('state_code', (v) => v as String?),
          address: $checkedConvert('address', (v) => v as String?),
          isActive: $checkedConvert('is_active', (v) => v as bool?),
          receivableMinor: $checkedConvert(
            'receivable_minor',
            (v) => (v as num?)?.toInt() ?? 0,
          ),
          payableMinor: $checkedConvert(
            'payable_minor',
            (v) => (v as num?)?.toInt() ?? 0,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'phoneE164': 'phone_e164',
        'stateCode': 'state_code',
        'isActive': 'is_active',
        'receivableMinor': 'receivable_minor',
        'payableMinor': 'payable_minor',
      },
    );

Map<String, dynamic> _$PatchedPartyToJson(PatchedParty instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'business': ?instance.business,
      'name': ?instance.name,
      'kind': ?_$PatchedPartyKindEnumEnumMap[instance.kind],
      'phone_e164': ?instance.phoneE164,
      'gstin': ?instance.gstin,
      'state_code': ?instance.stateCode,
      'address': ?instance.address,
      'is_active': ?instance.isActive,
      'receivable_minor': ?instance.receivableMinor,
      'payable_minor': ?instance.payableMinor,
    };

const _$PatchedPartyKindEnumEnumMap = {
  PatchedPartyKindEnum.CUSTOMER: 'CUSTOMER',
  PatchedPartyKindEnum.SUPPLIER: 'SUPPLIER',
  PatchedPartyKindEnum.BOTH: 'BOTH',
};
