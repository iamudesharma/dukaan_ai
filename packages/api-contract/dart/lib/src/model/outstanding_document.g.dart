// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outstanding_document.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OutstandingDocumentCWProxy {
  OutstandingDocument documentType(
    OutstandingDocumentDocumentTypeEnum documentType,
  );

  OutstandingDocument documentId(String documentId);

  OutstandingDocument number(String number);

  OutstandingDocument documentDate(DateTime documentDate);

  OutstandingDocument partyId(String? partyId);

  OutstandingDocument partyName(String? partyName);

  OutstandingDocument grandTotalMinor(int grandTotalMinor);

  OutstandingDocument paidTotalMinor(int paidTotalMinor);

  OutstandingDocument dueTotalMinor(int dueTotalMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OutstandingDocument(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OutstandingDocument(...).copyWith(id: 12, name: "My name")
  /// ````
  OutstandingDocument call({
    OutstandingDocumentDocumentTypeEnum documentType,
    String documentId,
    String number,
    DateTime documentDate,
    String? partyId,
    String? partyName,
    int grandTotalMinor,
    int paidTotalMinor,
    int dueTotalMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOutstandingDocument.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOutstandingDocument.copyWith.fieldName(...)`
class _$OutstandingDocumentCWProxyImpl implements _$OutstandingDocumentCWProxy {
  const _$OutstandingDocumentCWProxyImpl(this._value);

  final OutstandingDocument _value;

  @override
  OutstandingDocument documentType(
    OutstandingDocumentDocumentTypeEnum documentType,
  ) => this(documentType: documentType);

  @override
  OutstandingDocument documentId(String documentId) =>
      this(documentId: documentId);

  @override
  OutstandingDocument number(String number) => this(number: number);

  @override
  OutstandingDocument documentDate(DateTime documentDate) =>
      this(documentDate: documentDate);

  @override
  OutstandingDocument partyId(String? partyId) => this(partyId: partyId);

  @override
  OutstandingDocument partyName(String? partyName) =>
      this(partyName: partyName);

  @override
  OutstandingDocument grandTotalMinor(int grandTotalMinor) =>
      this(grandTotalMinor: grandTotalMinor);

  @override
  OutstandingDocument paidTotalMinor(int paidTotalMinor) =>
      this(paidTotalMinor: paidTotalMinor);

  @override
  OutstandingDocument dueTotalMinor(int dueTotalMinor) =>
      this(dueTotalMinor: dueTotalMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OutstandingDocument(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OutstandingDocument(...).copyWith(id: 12, name: "My name")
  /// ````
  OutstandingDocument call({
    Object? documentType = const $CopyWithPlaceholder(),
    Object? documentId = const $CopyWithPlaceholder(),
    Object? number = const $CopyWithPlaceholder(),
    Object? documentDate = const $CopyWithPlaceholder(),
    Object? partyId = const $CopyWithPlaceholder(),
    Object? partyName = const $CopyWithPlaceholder(),
    Object? grandTotalMinor = const $CopyWithPlaceholder(),
    Object? paidTotalMinor = const $CopyWithPlaceholder(),
    Object? dueTotalMinor = const $CopyWithPlaceholder(),
  }) {
    return OutstandingDocument(
      documentType: documentType == const $CopyWithPlaceholder()
          ? _value.documentType
          // ignore: cast_nullable_to_non_nullable
          : documentType as OutstandingDocumentDocumentTypeEnum,
      documentId: documentId == const $CopyWithPlaceholder()
          ? _value.documentId
          // ignore: cast_nullable_to_non_nullable
          : documentId as String,
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as String,
      documentDate: documentDate == const $CopyWithPlaceholder()
          ? _value.documentDate
          // ignore: cast_nullable_to_non_nullable
          : documentDate as DateTime,
      partyId: partyId == const $CopyWithPlaceholder()
          ? _value.partyId
          // ignore: cast_nullable_to_non_nullable
          : partyId as String?,
      partyName: partyName == const $CopyWithPlaceholder()
          ? _value.partyName
          // ignore: cast_nullable_to_non_nullable
          : partyName as String?,
      grandTotalMinor: grandTotalMinor == const $CopyWithPlaceholder()
          ? _value.grandTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : grandTotalMinor as int,
      paidTotalMinor: paidTotalMinor == const $CopyWithPlaceholder()
          ? _value.paidTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : paidTotalMinor as int,
      dueTotalMinor: dueTotalMinor == const $CopyWithPlaceholder()
          ? _value.dueTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : dueTotalMinor as int,
    );
  }
}

extension $OutstandingDocumentCopyWith on OutstandingDocument {
  /// Returns a callable class that can be used as follows: `instanceOfOutstandingDocument.copyWith(...)` or like so:`instanceOfOutstandingDocument.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OutstandingDocumentCWProxy get copyWith =>
      _$OutstandingDocumentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutstandingDocument _$OutstandingDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'OutstandingDocument',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'document_type',
            'document_id',
            'number',
            'document_date',
            'party_id',
            'party_name',
            'grand_total_minor',
            'paid_total_minor',
            'due_total_minor',
          ],
        );
        final val = OutstandingDocument(
          documentType: $checkedConvert(
            'document_type',
            (v) => $enumDecode(_$OutstandingDocumentDocumentTypeEnumEnumMap, v),
          ),
          documentId: $checkedConvert('document_id', (v) => v as String),
          number: $checkedConvert('number', (v) => v as String),
          documentDate: $checkedConvert(
            'document_date',
            (v) => DateTime.parse(v as String),
          ),
          partyId: $checkedConvert('party_id', (v) => v as String?),
          partyName: $checkedConvert('party_name', (v) => v as String?),
          grandTotalMinor: $checkedConvert(
            'grand_total_minor',
            (v) => (v as num).toInt(),
          ),
          paidTotalMinor: $checkedConvert(
            'paid_total_minor',
            (v) => (v as num).toInt(),
          ),
          dueTotalMinor: $checkedConvert(
            'due_total_minor',
            (v) => (v as num).toInt(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'documentType': 'document_type',
        'documentId': 'document_id',
        'documentDate': 'document_date',
        'partyId': 'party_id',
        'partyName': 'party_name',
        'grandTotalMinor': 'grand_total_minor',
        'paidTotalMinor': 'paid_total_minor',
        'dueTotalMinor': 'due_total_minor',
      },
    );

Map<String, dynamic> _$OutstandingDocumentToJson(
  OutstandingDocument instance,
) => <String, dynamic>{
  'document_type':
      _$OutstandingDocumentDocumentTypeEnumEnumMap[instance.documentType]!,
  'document_id': instance.documentId,
  'number': instance.number,
  'document_date': instance.documentDate.toIso8601String(),
  'party_id': instance.partyId,
  'party_name': instance.partyName,
  'grand_total_minor': instance.grandTotalMinor,
  'paid_total_minor': instance.paidTotalMinor,
  'due_total_minor': instance.dueTotalMinor,
};

const _$OutstandingDocumentDocumentTypeEnumEnumMap = {
  OutstandingDocumentDocumentTypeEnum.SALE: 'SALE',
  OutstandingDocumentDocumentTypeEnum.PURCHASE: 'PURCHASE',
};
