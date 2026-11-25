// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_extracted.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GmailExtractedCWProxy {
  GmailExtracted kind(GmailExtractedKindEnum kind);

  GmailExtracted direction(GmailExtractedDirectionEnum direction);

  GmailExtracted partyName(String partyName);

  GmailExtracted amountMinor(int? amountMinor);

  GmailExtracted reference(String reference);

  GmailExtracted confidence(double? confidence);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailExtracted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailExtracted(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailExtracted call({
    GmailExtractedKindEnum kind,
    GmailExtractedDirectionEnum direction,
    String partyName,
    int? amountMinor,
    String reference,
    double? confidence,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGmailExtracted.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGmailExtracted.copyWith.fieldName(...)`
class _$GmailExtractedCWProxyImpl implements _$GmailExtractedCWProxy {
  const _$GmailExtractedCWProxyImpl(this._value);

  final GmailExtracted _value;

  @override
  GmailExtracted kind(GmailExtractedKindEnum kind) => this(kind: kind);

  @override
  GmailExtracted direction(GmailExtractedDirectionEnum direction) =>
      this(direction: direction);

  @override
  GmailExtracted partyName(String partyName) => this(partyName: partyName);

  @override
  GmailExtracted amountMinor(int? amountMinor) =>
      this(amountMinor: amountMinor);

  @override
  GmailExtracted reference(String reference) => this(reference: reference);

  @override
  GmailExtracted confidence(double? confidence) => this(confidence: confidence);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailExtracted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailExtracted(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailExtracted call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? direction = const $CopyWithPlaceholder(),
    Object? partyName = const $CopyWithPlaceholder(),
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? reference = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
  }) {
    return GmailExtracted(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as GmailExtractedKindEnum,
      direction: direction == const $CopyWithPlaceholder()
          ? _value.direction
          // ignore: cast_nullable_to_non_nullable
          : direction as GmailExtractedDirectionEnum,
      partyName: partyName == const $CopyWithPlaceholder()
          ? _value.partyName
          // ignore: cast_nullable_to_non_nullable
          : partyName as String,
      amountMinor: amountMinor == const $CopyWithPlaceholder()
          ? _value.amountMinor
          // ignore: cast_nullable_to_non_nullable
          : amountMinor as int?,
      reference: reference == const $CopyWithPlaceholder()
          ? _value.reference
          // ignore: cast_nullable_to_non_nullable
          : reference as String,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as double?,
    );
  }
}

extension $GmailExtractedCopyWith on GmailExtracted {
  /// Returns a callable class that can be used as follows: `instanceOfGmailExtracted.copyWith(...)` or like so:`instanceOfGmailExtracted.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GmailExtractedCWProxy get copyWith => _$GmailExtractedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GmailExtracted _$GmailExtractedFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GmailExtracted',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'kind',
        'direction',
        'party_name',
        'amount_minor',
        'reference',
        'confidence',
      ],
    );
    final val = GmailExtracted(
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$GmailExtractedKindEnumEnumMap, v),
      ),
      direction: $checkedConvert(
        'direction',
        (v) => $enumDecode(_$GmailExtractedDirectionEnumEnumMap, v),
      ),
      partyName: $checkedConvert('party_name', (v) => v as String),
      amountMinor: $checkedConvert('amount_minor', (v) => (v as num?)?.toInt()),
      reference: $checkedConvert('reference', (v) => v as String),
      confidence: $checkedConvert('confidence', (v) => (v as num?)?.toDouble()),
    );
    return val;
  },
  fieldKeyMap: const {'partyName': 'party_name', 'amountMinor': 'amount_minor'},
);

Map<String, dynamic> _$GmailExtractedToJson(GmailExtracted instance) =>
    <String, dynamic>{
      'kind': _$GmailExtractedKindEnumEnumMap[instance.kind]!,
      'direction': _$GmailExtractedDirectionEnumEnumMap[instance.direction]!,
      'party_name': instance.partyName,
      'amount_minor': instance.amountMinor,
      'reference': instance.reference,
      'confidence': instance.confidence,
    };

const _$GmailExtractedKindEnumEnumMap = {
  GmailExtractedKindEnum.PAYMENT: 'PAYMENT',
  GmailExtractedKindEnum.RECEIPT: 'RECEIPT',
  GmailExtractedKindEnum.EXPENSE: 'EXPENSE',
  GmailExtractedKindEnum.UNKNOWN: 'UNKNOWN',
};

const _$GmailExtractedDirectionEnumEnumMap = {
  GmailExtractedDirectionEnum.RECEIPT: 'RECEIPT',
  GmailExtractedDirectionEnum.PAYMENT: 'PAYMENT',
  GmailExtractedDirectionEnum.empty: '',
};
