// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_allocation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentAllocationCWProxy {
  PaymentAllocation id(String id);

  PaymentAllocation sale(String? sale);

  PaymentAllocation purchase(String? purchase);

  PaymentAllocation amountMinor(int amountMinor);

  PaymentAllocation documentType(
    PaymentAllocationDocumentTypeEnum documentType,
  );

  PaymentAllocation documentId(String? documentId);

  PaymentAllocation documentNumber(String? documentNumber);

  PaymentAllocation documentTotalMinor(int? documentTotalMinor);

  PaymentAllocation documentPaidTotalMinor(int? documentPaidTotalMinor);

  PaymentAllocation documentDueTotalMinor(int? documentDueTotalMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentAllocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentAllocation(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentAllocation call({
    String id,
    String? sale,
    String? purchase,
    int amountMinor,
    PaymentAllocationDocumentTypeEnum documentType,
    String? documentId,
    String? documentNumber,
    int? documentTotalMinor,
    int? documentPaidTotalMinor,
    int? documentDueTotalMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaymentAllocation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaymentAllocation.copyWith.fieldName(...)`
class _$PaymentAllocationCWProxyImpl implements _$PaymentAllocationCWProxy {
  const _$PaymentAllocationCWProxyImpl(this._value);

  final PaymentAllocation _value;

  @override
  PaymentAllocation id(String id) => this(id: id);

  @override
  PaymentAllocation sale(String? sale) => this(sale: sale);

  @override
  PaymentAllocation purchase(String? purchase) => this(purchase: purchase);

  @override
  PaymentAllocation amountMinor(int amountMinor) =>
      this(amountMinor: amountMinor);

  @override
  PaymentAllocation documentType(
    PaymentAllocationDocumentTypeEnum documentType,
  ) => this(documentType: documentType);

  @override
  PaymentAllocation documentId(String? documentId) =>
      this(documentId: documentId);

  @override
  PaymentAllocation documentNumber(String? documentNumber) =>
      this(documentNumber: documentNumber);

  @override
  PaymentAllocation documentTotalMinor(int? documentTotalMinor) =>
      this(documentTotalMinor: documentTotalMinor);

  @override
  PaymentAllocation documentPaidTotalMinor(int? documentPaidTotalMinor) =>
      this(documentPaidTotalMinor: documentPaidTotalMinor);

  @override
  PaymentAllocation documentDueTotalMinor(int? documentDueTotalMinor) =>
      this(documentDueTotalMinor: documentDueTotalMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentAllocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentAllocation(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentAllocation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? sale = const $CopyWithPlaceholder(),
    Object? purchase = const $CopyWithPlaceholder(),
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? documentType = const $CopyWithPlaceholder(),
    Object? documentId = const $CopyWithPlaceholder(),
    Object? documentNumber = const $CopyWithPlaceholder(),
    Object? documentTotalMinor = const $CopyWithPlaceholder(),
    Object? documentPaidTotalMinor = const $CopyWithPlaceholder(),
    Object? documentDueTotalMinor = const $CopyWithPlaceholder(),
  }) {
    return PaymentAllocation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      sale: sale == const $CopyWithPlaceholder()
          ? _value.sale
          // ignore: cast_nullable_to_non_nullable
          : sale as String?,
      purchase: purchase == const $CopyWithPlaceholder()
          ? _value.purchase
          // ignore: cast_nullable_to_non_nullable
          : purchase as String?,
      amountMinor: amountMinor == const $CopyWithPlaceholder()
          ? _value.amountMinor
          // ignore: cast_nullable_to_non_nullable
          : amountMinor as int,
      documentType: documentType == const $CopyWithPlaceholder()
          ? _value.documentType
          // ignore: cast_nullable_to_non_nullable
          : documentType as PaymentAllocationDocumentTypeEnum,
      documentId: documentId == const $CopyWithPlaceholder()
          ? _value.documentId
          // ignore: cast_nullable_to_non_nullable
          : documentId as String?,
      documentNumber: documentNumber == const $CopyWithPlaceholder()
          ? _value.documentNumber
          // ignore: cast_nullable_to_non_nullable
          : documentNumber as String?,
      documentTotalMinor: documentTotalMinor == const $CopyWithPlaceholder()
          ? _value.documentTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : documentTotalMinor as int?,
      documentPaidTotalMinor:
          documentPaidTotalMinor == const $CopyWithPlaceholder()
          ? _value.documentPaidTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : documentPaidTotalMinor as int?,
      documentDueTotalMinor:
          documentDueTotalMinor == const $CopyWithPlaceholder()
          ? _value.documentDueTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : documentDueTotalMinor as int?,
    );
  }
}

extension $PaymentAllocationCopyWith on PaymentAllocation {
  /// Returns a callable class that can be used as follows: `instanceOfPaymentAllocation.copyWith(...)` or like so:`instanceOfPaymentAllocation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentAllocationCWProxy get copyWith =>
      _$PaymentAllocationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentAllocation _$PaymentAllocationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PaymentAllocation',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'amount_minor',
        'document_type',
        'document_id',
        'document_number',
        'document_total_minor',
        'document_paid_total_minor',
        'document_due_total_minor',
      ],
    );
    final val = PaymentAllocation(
      id: $checkedConvert('id', (v) => v as String),
      sale: $checkedConvert('sale', (v) => v as String?),
      purchase: $checkedConvert('purchase', (v) => v as String?),
      amountMinor: $checkedConvert('amount_minor', (v) => (v as num).toInt()),
      documentType: $checkedConvert(
        'document_type',
        (v) => $enumDecode(_$PaymentAllocationDocumentTypeEnumEnumMap, v),
      ),
      documentId: $checkedConvert('document_id', (v) => v as String?),
      documentNumber: $checkedConvert('document_number', (v) => v as String?),
      documentTotalMinor: $checkedConvert(
        'document_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
      documentPaidTotalMinor: $checkedConvert(
        'document_paid_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
      documentDueTotalMinor: $checkedConvert(
        'document_due_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'amountMinor': 'amount_minor',
    'documentType': 'document_type',
    'documentId': 'document_id',
    'documentNumber': 'document_number',
    'documentTotalMinor': 'document_total_minor',
    'documentPaidTotalMinor': 'document_paid_total_minor',
    'documentDueTotalMinor': 'document_due_total_minor',
  },
);

Map<String, dynamic> _$PaymentAllocationToJson(PaymentAllocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sale': ?instance.sale,
      'purchase': ?instance.purchase,
      'amount_minor': instance.amountMinor,
      'document_type':
          _$PaymentAllocationDocumentTypeEnumEnumMap[instance.documentType]!,
      'document_id': instance.documentId,
      'document_number': instance.documentNumber,
      'document_total_minor': instance.documentTotalMinor,
      'document_paid_total_minor': instance.documentPaidTotalMinor,
      'document_due_total_minor': instance.documentDueTotalMinor,
    };

const _$PaymentAllocationDocumentTypeEnumEnumMap = {
  PaymentAllocationDocumentTypeEnum.SALE: 'SALE',
  PaymentAllocationDocumentTypeEnum.PURCHASE: 'PURCHASE',
};
