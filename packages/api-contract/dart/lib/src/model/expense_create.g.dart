// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExpenseCreateCWProxy {
  ExpenseCreate businessId(String businessId);

  ExpenseCreate locationId(String locationId);

  ExpenseCreate expenseDate(DateTime? expenseDate);

  ExpenseCreate category(String category);

  ExpenseCreate payee(String? payee);

  ExpenseCreate note(String? note);

  ExpenseCreate amountMinor(int amountMinor);

  ExpenseCreate taxAmountMinor(int? taxAmountMinor);

  ExpenseCreate paymentMethod(ExpenseCreatePaymentMethodEnum paymentMethod);

  ExpenseCreate idempotencyKey(String idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExpenseCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExpenseCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  ExpenseCreate call({
    String businessId,
    String locationId,
    DateTime? expenseDate,
    String category,
    String? payee,
    String? note,
    int amountMinor,
    int? taxAmountMinor,
    ExpenseCreatePaymentMethodEnum paymentMethod,
    String idempotencyKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExpenseCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExpenseCreate.copyWith.fieldName(...)`
class _$ExpenseCreateCWProxyImpl implements _$ExpenseCreateCWProxy {
  const _$ExpenseCreateCWProxyImpl(this._value);

  final ExpenseCreate _value;

  @override
  ExpenseCreate businessId(String businessId) => this(businessId: businessId);

  @override
  ExpenseCreate locationId(String locationId) => this(locationId: locationId);

  @override
  ExpenseCreate expenseDate(DateTime? expenseDate) =>
      this(expenseDate: expenseDate);

  @override
  ExpenseCreate category(String category) => this(category: category);

  @override
  ExpenseCreate payee(String? payee) => this(payee: payee);

  @override
  ExpenseCreate note(String? note) => this(note: note);

  @override
  ExpenseCreate amountMinor(int amountMinor) => this(amountMinor: amountMinor);

  @override
  ExpenseCreate taxAmountMinor(int? taxAmountMinor) =>
      this(taxAmountMinor: taxAmountMinor);

  @override
  ExpenseCreate paymentMethod(ExpenseCreatePaymentMethodEnum paymentMethod) =>
      this(paymentMethod: paymentMethod);

  @override
  ExpenseCreate idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExpenseCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExpenseCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  ExpenseCreate call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
    Object? expenseDate = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? payee = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? taxAmountMinor = const $CopyWithPlaceholder(),
    Object? paymentMethod = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
  }) {
    return ExpenseCreate(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String,
      expenseDate: expenseDate == const $CopyWithPlaceholder()
          ? _value.expenseDate
          // ignore: cast_nullable_to_non_nullable
          : expenseDate as DateTime?,
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
      paymentMethod: paymentMethod == const $CopyWithPlaceholder()
          ? _value.paymentMethod
          // ignore: cast_nullable_to_non_nullable
          : paymentMethod as ExpenseCreatePaymentMethodEnum,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
    );
  }
}

extension $ExpenseCreateCopyWith on ExpenseCreate {
  /// Returns a callable class that can be used as follows: `instanceOfExpenseCreate.copyWith(...)` or like so:`instanceOfExpenseCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExpenseCreateCWProxy get copyWith => _$ExpenseCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseCreate _$ExpenseCreateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ExpenseCreate',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'business_id',
        'location_id',
        'category',
        'amount_minor',
        'payment_method',
        'idempotency_key',
      ],
    );
    final val = ExpenseCreate(
      businessId: $checkedConvert('business_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
      expenseDate: $checkedConvert(
        'expense_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      category: $checkedConvert('category', (v) => v as String),
      payee: $checkedConvert('payee', (v) => v as String?),
      note: $checkedConvert('note', (v) => v as String?),
      amountMinor: $checkedConvert('amount_minor', (v) => (v as num).toInt()),
      taxAmountMinor: $checkedConvert(
        'tax_amount_minor',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      paymentMethod: $checkedConvert(
        'payment_method',
        (v) => $enumDecode(_$ExpenseCreatePaymentMethodEnumEnumMap, v),
      ),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'locationId': 'location_id',
    'expenseDate': 'expense_date',
    'amountMinor': 'amount_minor',
    'taxAmountMinor': 'tax_amount_minor',
    'paymentMethod': 'payment_method',
    'idempotencyKey': 'idempotency_key',
  },
);

Map<String, dynamic> _$ExpenseCreateToJson(ExpenseCreate instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'location_id': instance.locationId,
      'expense_date': ?instance.expenseDate?.toIso8601String(),
      'category': instance.category,
      'payee': ?instance.payee,
      'note': ?instance.note,
      'amount_minor': instance.amountMinor,
      'tax_amount_minor': ?instance.taxAmountMinor,
      'payment_method':
          _$ExpenseCreatePaymentMethodEnumEnumMap[instance.paymentMethod]!,
      'idempotency_key': instance.idempotencyKey,
    };

const _$ExpenseCreatePaymentMethodEnumEnumMap = {
  ExpenseCreatePaymentMethodEnum.CASH: 'CASH',
  ExpenseCreatePaymentMethodEnum.UPI: 'UPI',
  ExpenseCreatePaymentMethodEnum.CARD: 'CARD',
  ExpenseCreatePaymentMethodEnum.BANK: 'BANK',
  ExpenseCreatePaymentMethodEnum.OTHER: 'OTHER',
};
