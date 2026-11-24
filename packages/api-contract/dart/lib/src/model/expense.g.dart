// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExpenseCWProxy {
  Expense id(String id);

  Expense business(String business);

  Expense location(String location);

  Expense status(ExpenseStatusEnum? status);

  Expense number(String number);

  Expense documentDate(DateTime documentDate);

  Expense category(String category);

  Expense payee(String? payee);

  Expense note(String? note);

  Expense amountMinor(int amountMinor);

  Expense taxAmountMinor(int? taxAmountMinor);

  Expense totalMinor(int totalMinor);

  Expense paymentMethod(ExpensePaymentMethodEnum paymentMethod);

  Expense source_(String? source_);

  Expense postedAt(DateTime postedAt);

  Expense reversalReason(String? reversalReason);

  Expense reversedAt(DateTime? reversedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Expense(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Expense(...).copyWith(id: 12, name: "My name")
  /// ````
  Expense call({
    String id,
    String business,
    String location,
    ExpenseStatusEnum? status,
    String number,
    DateTime documentDate,
    String category,
    String? payee,
    String? note,
    int amountMinor,
    int? taxAmountMinor,
    int totalMinor,
    ExpensePaymentMethodEnum paymentMethod,
    String? source_,
    DateTime postedAt,
    String? reversalReason,
    DateTime? reversedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExpense.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExpense.copyWith.fieldName(...)`
class _$ExpenseCWProxyImpl implements _$ExpenseCWProxy {
  const _$ExpenseCWProxyImpl(this._value);

  final Expense _value;

  @override
  Expense id(String id) => this(id: id);

  @override
  Expense business(String business) => this(business: business);

  @override
  Expense location(String location) => this(location: location);

  @override
  Expense status(ExpenseStatusEnum? status) => this(status: status);

  @override
  Expense number(String number) => this(number: number);

  @override
  Expense documentDate(DateTime documentDate) =>
      this(documentDate: documentDate);

  @override
  Expense category(String category) => this(category: category);

  @override
  Expense payee(String? payee) => this(payee: payee);

  @override
  Expense note(String? note) => this(note: note);

  @override
  Expense amountMinor(int amountMinor) => this(amountMinor: amountMinor);

  @override
  Expense taxAmountMinor(int? taxAmountMinor) =>
      this(taxAmountMinor: taxAmountMinor);

  @override
  Expense totalMinor(int totalMinor) => this(totalMinor: totalMinor);

  @override
  Expense paymentMethod(ExpensePaymentMethodEnum paymentMethod) =>
      this(paymentMethod: paymentMethod);

  @override
  Expense source_(String? source_) => this(source_: source_);

  @override
  Expense postedAt(DateTime postedAt) => this(postedAt: postedAt);

  @override
  Expense reversalReason(String? reversalReason) =>
      this(reversalReason: reversalReason);

  @override
  Expense reversedAt(DateTime? reversedAt) => this(reversedAt: reversedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Expense(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Expense(...).copyWith(id: 12, name: "My name")
  /// ````
  Expense call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? number = const $CopyWithPlaceholder(),
    Object? documentDate = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? payee = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? taxAmountMinor = const $CopyWithPlaceholder(),
    Object? totalMinor = const $CopyWithPlaceholder(),
    Object? paymentMethod = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? postedAt = const $CopyWithPlaceholder(),
    Object? reversalReason = const $CopyWithPlaceholder(),
    Object? reversedAt = const $CopyWithPlaceholder(),
  }) {
    return Expense(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ExpenseStatusEnum?,
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as String,
      documentDate: documentDate == const $CopyWithPlaceholder()
          ? _value.documentDate
          // ignore: cast_nullable_to_non_nullable
          : documentDate as DateTime,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String,
      payee: payee == const $CopyWithPlaceholder()
          ? _value.payee
          // ignore: cast_nullable_to_non_nullable
          : payee as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      amountMinor: amountMinor == const $CopyWithPlaceholder()
          ? _value.amountMinor
          // ignore: cast_nullable_to_non_nullable
          : amountMinor as int,
      taxAmountMinor: taxAmountMinor == const $CopyWithPlaceholder()
          ? _value.taxAmountMinor
          // ignore: cast_nullable_to_non_nullable
          : taxAmountMinor as int?,
      totalMinor: totalMinor == const $CopyWithPlaceholder()
          ? _value.totalMinor
          // ignore: cast_nullable_to_non_nullable
          : totalMinor as int,
      paymentMethod: paymentMethod == const $CopyWithPlaceholder()
          ? _value.paymentMethod
          // ignore: cast_nullable_to_non_nullable
          : paymentMethod as ExpensePaymentMethodEnum,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String?,
      postedAt: postedAt == const $CopyWithPlaceholder()
          ? _value.postedAt
          // ignore: cast_nullable_to_non_nullable
          : postedAt as DateTime,
      reversalReason: reversalReason == const $CopyWithPlaceholder()
          ? _value.reversalReason
          // ignore: cast_nullable_to_non_nullable
          : reversalReason as String?,
      reversedAt: reversedAt == const $CopyWithPlaceholder()
          ? _value.reversedAt
          // ignore: cast_nullable_to_non_nullable
          : reversedAt as DateTime?,
    );
  }
}

extension $ExpenseCopyWith on Expense {
  /// Returns a callable class that can be used as follows: `instanceOfExpense.copyWith(...)` or like so:`instanceOfExpense.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExpenseCWProxy get copyWith => _$ExpenseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Expense',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'location',
        'number',
        'document_date',
        'category',
        'amount_minor',
        'total_minor',
        'payment_method',
        'posted_at',
      ],
    );
    final val = Expense(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      location: $checkedConvert('location', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$ExpenseStatusEnumEnumMap, v),
      ),
      number: $checkedConvert('number', (v) => v as String),
      documentDate: $checkedConvert(
        'document_date',
        (v) => DateTime.parse(v as String),
      ),
      category: $checkedConvert('category', (v) => v as String),
      payee: $checkedConvert('payee', (v) => v as String?),
      note: $checkedConvert('note', (v) => v as String?),
      amountMinor: $checkedConvert('amount_minor', (v) => (v as num).toInt()),
      taxAmountMinor: $checkedConvert(
        'tax_amount_minor',
        (v) => (v as num?)?.toInt(),
      ),
      totalMinor: $checkedConvert('total_minor', (v) => (v as num).toInt()),
      paymentMethod: $checkedConvert(
        'payment_method',
        (v) => $enumDecode(_$ExpensePaymentMethodEnumEnumMap, v),
      ),
      source_: $checkedConvert('source', (v) => v as String?),
      postedAt: $checkedConvert(
        'posted_at',
        (v) => DateTime.parse(v as String),
      ),
      reversalReason: $checkedConvert('reversal_reason', (v) => v as String?),
      reversedAt: $checkedConvert(
        'reversed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'documentDate': 'document_date',
    'amountMinor': 'amount_minor',
    'taxAmountMinor': 'tax_amount_minor',
    'totalMinor': 'total_minor',
    'paymentMethod': 'payment_method',
    'source_': 'source',
    'postedAt': 'posted_at',
    'reversalReason': 'reversal_reason',
    'reversedAt': 'reversed_at',
  },
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'location': instance.location,
  'status': ?_$ExpenseStatusEnumEnumMap[instance.status],
  'number': instance.number,
  'document_date': instance.documentDate.toIso8601String(),
  'category': instance.category,
  'payee': ?instance.payee,
  'note': ?instance.note,
  'amount_minor': instance.amountMinor,
  'tax_amount_minor': ?instance.taxAmountMinor,
  'total_minor': instance.totalMinor,
  'payment_method': _$ExpensePaymentMethodEnumEnumMap[instance.paymentMethod]!,
  'source': ?instance.source_,
  'posted_at': instance.postedAt.toIso8601String(),
  'reversal_reason': ?instance.reversalReason,
  'reversed_at': ?instance.reversedAt?.toIso8601String(),
};

const _$ExpenseStatusEnumEnumMap = {
  ExpenseStatusEnum.DRAFT: 'DRAFT',
  ExpenseStatusEnum.POSTED: 'POSTED',
  ExpenseStatusEnum.REVERSED: 'REVERSED',
};

const _$ExpensePaymentMethodEnumEnumMap = {
  ExpensePaymentMethodEnum.CASH: 'CASH',
  ExpensePaymentMethodEnum.UPI: 'UPI',
  ExpensePaymentMethodEnum.CARD: 'CARD',
  ExpensePaymentMethodEnum.BANK: 'BANK',
  ExpensePaymentMethodEnum.OTHER: 'OTHER',
};
