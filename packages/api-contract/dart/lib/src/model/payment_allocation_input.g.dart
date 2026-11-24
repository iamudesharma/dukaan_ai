// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_allocation_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentAllocationInputCWProxy {
  PaymentAllocationInput amountMinor(int amountMinor);

  PaymentAllocationInput saleId(String? saleId);

  PaymentAllocationInput purchaseId(String? purchaseId);

  PaymentAllocationInput documentType(
    PaymentAllocationInputDocumentTypeEnum? documentType,
  );

  PaymentAllocationInput documentId(String? documentId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentAllocationInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentAllocationInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentAllocationInput call({
    int amountMinor,
    String? saleId,
    String? purchaseId,
    PaymentAllocationInputDocumentTypeEnum? documentType,
    String? documentId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaymentAllocationInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaymentAllocationInput.copyWith.fieldName(...)`
class _$PaymentAllocationInputCWProxyImpl
    implements _$PaymentAllocationInputCWProxy {
  const _$PaymentAllocationInputCWProxyImpl(this._value);

  final PaymentAllocationInput _value;

  @override
  PaymentAllocationInput amountMinor(int amountMinor) =>
      this(amountMinor: amountMinor);

  @override
  PaymentAllocationInput saleId(String? saleId) => this(saleId: saleId);

  @override
  PaymentAllocationInput purchaseId(String? purchaseId) =>
      this(purchaseId: purchaseId);

  @override
  PaymentAllocationInput documentType(
    PaymentAllocationInputDocumentTypeEnum? documentType,
  ) => this(documentType: documentType);

  @override
  PaymentAllocationInput documentId(String? documentId) =>
      this(documentId: documentId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentAllocationInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentAllocationInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentAllocationInput call({
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? saleId = const $CopyWithPlaceholder(),
    Object? purchaseId = const $CopyWithPlaceholder(),
    Object? documentType = const $CopyWithPlaceholder(),
    Object? documentId = const $CopyWithPlaceholder(),
  }) {
    return PaymentAllocationInput(
      amountMinor: amountMinor == const $CopyWithPlaceholder()
          ? _value.amountMinor
          // ignore: cast_nullable_to_non_nullable
          : amountMinor as int,
      saleId: saleId == const $CopyWithPlaceholder()
          ? _value.saleId
          // ignore: cast_nullable_to_non_nullable
          : saleId as String?,
      purchaseId: purchaseId == const $CopyWithPlaceholder()
          ? _value.purchaseId
          // ignore: cast_nullable_to_non_nullable
          : purchaseId as String?,
      documentType: documentType == const $CopyWithPlaceholder()
          ? _value.documentType
          // ignore: cast_nullable_to_non_nullable
          : documentType as PaymentAllocationInputDocumentTypeEnum?,
      documentId: documentId == const $CopyWithPlaceholder()
          ? _value.documentId
          // ignore: cast_nullable_to_non_nullable
          : documentId as String?,
    );
  }
}

extension $PaymentAllocationInputCopyWith on PaymentAllocationInput {
  /// Returns a callable class that can be used as follows: `instanceOfPaymentAllocationInput.copyWith(...)` or like so:`instanceOfPaymentAllocationInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentAllocationInputCWProxy get copyWith =>
      _$PaymentAllocationInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentAllocationInput _$PaymentAllocationInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PaymentAllocationInput',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['amount_minor']);
    final val = PaymentAllocationInput(
      amountMinor: $checkedConvert('amount_minor', (v) => (v as num).toInt()),
      saleId: $checkedConvert('sale_id', (v) => v as String?),
      purchaseId: $checkedConvert('purchase_id', (v) => v as String?),
      documentType: $checkedConvert(
        'document_type',
        (v) => $enumDecodeNullable(
          _$PaymentAllocationInputDocumentTypeEnumEnumMap,
          v,
        ),
      ),
      documentId: $checkedConvert('document_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'amountMinor': 'amount_minor',
    'saleId': 'sale_id',
    'purchaseId': 'purchase_id',
    'documentType': 'document_type',
    'documentId': 'document_id',
  },
);

Map<String, dynamic> _$PaymentAllocationInputToJson(
  PaymentAllocationInput instance,
) => <String, dynamic>{
  'amount_minor': instance.amountMinor,
  'sale_id': ?instance.saleId,
  'purchase_id': ?instance.purchaseId,
  'document_type':
      ?_$PaymentAllocationInputDocumentTypeEnumEnumMap[instance.documentType],
  'document_id': ?instance.documentId,
};

const _$PaymentAllocationInputDocumentTypeEnumEnumMap = {
  PaymentAllocationInputDocumentTypeEnum.SALE: 'SALE',
  PaymentAllocationInputDocumentTypeEnum.PURCHASE: 'PURCHASE',
};
