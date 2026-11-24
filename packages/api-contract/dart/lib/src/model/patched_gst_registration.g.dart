// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patched_gst_registration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PatchedGSTRegistrationCWProxy {
  PatchedGSTRegistration id(String? id);

  PatchedGSTRegistration business(String? business);

  PatchedGSTRegistration gstin(String? gstin);

  PatchedGSTRegistration legalName(String? legalName);

  PatchedGSTRegistration address(String? address);

  PatchedGSTRegistration stateCode(String? stateCode);

  PatchedGSTRegistration invoicePrefix(String? invoicePrefix);

  PatchedGSTRegistration isActive(bool? isActive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedGSTRegistration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedGSTRegistration(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedGSTRegistration call({
    String? id,
    String? business,
    String? gstin,
    String? legalName,
    String? address,
    String? stateCode,
    String? invoicePrefix,
    bool? isActive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPatchedGSTRegistration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPatchedGSTRegistration.copyWith.fieldName(...)`
class _$PatchedGSTRegistrationCWProxyImpl
    implements _$PatchedGSTRegistrationCWProxy {
  const _$PatchedGSTRegistrationCWProxyImpl(this._value);

  final PatchedGSTRegistration _value;

  @override
  PatchedGSTRegistration id(String? id) => this(id: id);

  @override
  PatchedGSTRegistration business(String? business) => this(business: business);

  @override
  PatchedGSTRegistration gstin(String? gstin) => this(gstin: gstin);

  @override
  PatchedGSTRegistration legalName(String? legalName) =>
      this(legalName: legalName);

  @override
  PatchedGSTRegistration address(String? address) => this(address: address);

  @override
  PatchedGSTRegistration stateCode(String? stateCode) =>
      this(stateCode: stateCode);

  @override
  PatchedGSTRegistration invoicePrefix(String? invoicePrefix) =>
      this(invoicePrefix: invoicePrefix);

  @override
  PatchedGSTRegistration isActive(bool? isActive) => this(isActive: isActive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedGSTRegistration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedGSTRegistration(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedGSTRegistration call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? gstin = const $CopyWithPlaceholder(),
    Object? legalName = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? stateCode = const $CopyWithPlaceholder(),
    Object? invoicePrefix = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
  }) {
    return PatchedGSTRegistration(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String?,
      gstin: gstin == const $CopyWithPlaceholder()
          ? _value.gstin
          // ignore: cast_nullable_to_non_nullable
          : gstin as String?,
      legalName: legalName == const $CopyWithPlaceholder()
          ? _value.legalName
          // ignore: cast_nullable_to_non_nullable
          : legalName as String?,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String?,
      stateCode: stateCode == const $CopyWithPlaceholder()
          ? _value.stateCode
          // ignore: cast_nullable_to_non_nullable
          : stateCode as String?,
      invoicePrefix: invoicePrefix == const $CopyWithPlaceholder()
          ? _value.invoicePrefix
          // ignore: cast_nullable_to_non_nullable
          : invoicePrefix as String?,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool?,
    );
  }
}

extension $PatchedGSTRegistrationCopyWith on PatchedGSTRegistration {
  /// Returns a callable class that can be used as follows: `instanceOfPatchedGSTRegistration.copyWith(...)` or like so:`instanceOfPatchedGSTRegistration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PatchedGSTRegistrationCWProxy get copyWith =>
      _$PatchedGSTRegistrationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchedGSTRegistration _$PatchedGSTRegistrationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PatchedGSTRegistration',
  json,
  ($checkedConvert) {
    final val = PatchedGSTRegistration(
      id: $checkedConvert('id', (v) => v as String?),
      business: $checkedConvert('business', (v) => v as String?),
      gstin: $checkedConvert('gstin', (v) => v as String?),
      legalName: $checkedConvert('legal_name', (v) => v as String?),
      address: $checkedConvert('address', (v) => v as String?),
      stateCode: $checkedConvert('state_code', (v) => v as String?),
      invoicePrefix: $checkedConvert('invoice_prefix', (v) => v as String?),
      isActive: $checkedConvert('is_active', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'legalName': 'legal_name',
    'stateCode': 'state_code',
    'invoicePrefix': 'invoice_prefix',
    'isActive': 'is_active',
  },
);

Map<String, dynamic> _$PatchedGSTRegistrationToJson(
  PatchedGSTRegistration instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'business': ?instance.business,
  'gstin': ?instance.gstin,
  'legal_name': ?instance.legalName,
  'address': ?instance.address,
  'state_code': ?instance.stateCode,
  'invoice_prefix': ?instance.invoicePrefix,
  'is_active': ?instance.isActive,
};
