// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gst_registration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GSTRegistrationCWProxy {
  GSTRegistration id(String id);

  GSTRegistration business(String business);

  GSTRegistration gstin(String gstin);

  GSTRegistration legalName(String legalName);

  GSTRegistration address(String? address);

  GSTRegistration stateCode(String stateCode);

  GSTRegistration invoicePrefix(String? invoicePrefix);

  GSTRegistration isActive(bool? isActive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GSTRegistration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GSTRegistration(...).copyWith(id: 12, name: "My name")
  /// ````
  GSTRegistration call({
    String id,
    String business,
    String gstin,
    String legalName,
    String? address,
    String stateCode,
    String? invoicePrefix,
    bool? isActive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGSTRegistration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGSTRegistration.copyWith.fieldName(...)`
class _$GSTRegistrationCWProxyImpl implements _$GSTRegistrationCWProxy {
  const _$GSTRegistrationCWProxyImpl(this._value);

  final GSTRegistration _value;

  @override
  GSTRegistration id(String id) => this(id: id);

  @override
  GSTRegistration business(String business) => this(business: business);

  @override
  GSTRegistration gstin(String gstin) => this(gstin: gstin);

  @override
  GSTRegistration legalName(String legalName) => this(legalName: legalName);

  @override
  GSTRegistration address(String? address) => this(address: address);

  @override
  GSTRegistration stateCode(String stateCode) => this(stateCode: stateCode);

  @override
  GSTRegistration invoicePrefix(String? invoicePrefix) =>
      this(invoicePrefix: invoicePrefix);

  @override
  GSTRegistration isActive(bool? isActive) => this(isActive: isActive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GSTRegistration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GSTRegistration(...).copyWith(id: 12, name: "My name")
  /// ````
  GSTRegistration call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? gstin = const $CopyWithPlaceholder(),
    Object? legalName = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? stateCode = const $CopyWithPlaceholder(),
    Object? invoicePrefix = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
  }) {
    return GSTRegistration(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      gstin: gstin == const $CopyWithPlaceholder()
          ? _value.gstin
          // ignore: cast_nullable_to_non_nullable
          : gstin as String,
      legalName: legalName == const $CopyWithPlaceholder()
          ? _value.legalName
          // ignore: cast_nullable_to_non_nullable
          : legalName as String,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String?,
      stateCode: stateCode == const $CopyWithPlaceholder()
          ? _value.stateCode
          // ignore: cast_nullable_to_non_nullable
          : stateCode as String,
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

extension $GSTRegistrationCopyWith on GSTRegistration {
  /// Returns a callable class that can be used as follows: `instanceOfGSTRegistration.copyWith(...)` or like so:`instanceOfGSTRegistration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GSTRegistrationCWProxy get copyWith => _$GSTRegistrationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GSTRegistration _$GSTRegistrationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'GSTRegistration',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'business',
            'gstin',
            'legal_name',
            'state_code',
          ],
        );
        final val = GSTRegistration(
          id: $checkedConvert('id', (v) => v as String),
          business: $checkedConvert('business', (v) => v as String),
          gstin: $checkedConvert('gstin', (v) => v as String),
          legalName: $checkedConvert('legal_name', (v) => v as String),
          address: $checkedConvert('address', (v) => v as String?),
          stateCode: $checkedConvert('state_code', (v) => v as String),
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

Map<String, dynamic> _$GSTRegistrationToJson(GSTRegistration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business': instance.business,
      'gstin': instance.gstin,
      'legal_name': instance.legalName,
      'address': ?instance.address,
      'state_code': instance.stateCode,
      'invoice_prefix': ?instance.invoicePrefix,
      'is_active': ?instance.isActive,
    };
