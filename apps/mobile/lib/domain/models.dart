import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:flutter/foundation.dart';

/// Maximum attachment size accepted by the API for voice and image uploads.
const maxAttachmentBytes = 8 * 1024 * 1024;

const voiceMimeType = 'audio/m4a';

/// Money is exchanged and stored as integer paise (minor units). Quantities
/// stay exact with the decimal package; prices and totals never use doubles.
int minorFrom(Object? value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.round();
  final parsed = int.tryParse(value.toString());
  if (parsed != null) return parsed;
  final decimal = Decimal.tryParse(value.toString());
  if (decimal == null) return fallback;
  return (decimal * Decimal.fromInt(100)).round().toBigInt().toInt();
}

/// Legacy server payloads may still carry rupee decimals. Prefer the
/// `<name>Minor` field and convert only as a fallback.
int minorFromRecord(
    Map<String, dynamic> json, String minorKey, String majorKey) {
  final minor = json[minorKey];
  if (minor != null) return minorFrom(minor);
  final major = json[majorKey];
  return minorFrom(major);
}

Decimal decimalFrom(Object? value, [String fallback = '0']) {
  return Decimal.tryParse(value?.toString() ?? '') ?? Decimal.parse(fallback);
}

/// Convert integer paise to whole rupees for display. Fractional paise are
/// not representable in this contract and round half away from zero.
Decimal rupeesFromMinor(int minor) =>
    (Decimal.fromInt(minor) / Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 2);

@immutable
class BusinessLocation {
  const BusinessLocation({
    required this.id,
    required this.businessId,
    required this.name,
    this.isPrimary = false,
  });

  final String id;
  final String businessId;
  final String name;
  final bool isPrimary;

  factory BusinessLocation.fromJson(Map<String, dynamic> json) {
    return BusinessLocation(
      id: json['id'].toString(),
      businessId: (json['business_id'] ?? json['business'] ?? '').toString(),
      name: (json['name'] ?? 'Location').toString(),
      isPrimary: json['is_primary'] == true,
    );
  }
}

enum BusinessRole {
  owner,
  manager,
  cashier;

  /// Unknown or unavailable roles fail closed to the cashier surface. The
  /// server remains the authority for every write.
  factory BusinessRole.fromJson(Object? value) =>
      switch (value?.toString().trim().toUpperCase()) {
        'OWNER' => BusinessRole.owner,
        'MANAGER' => BusinessRole.manager,
        _ => BusinessRole.cashier,
      };

  bool get canManageOperations => this != BusinessRole.cashier;
  bool get canViewSuppliers => canManageOperations;
  bool get canUseWholesalePrices => canManageOperations;

  bool canUsePriceMode(PriceMode mode) =>
      mode == PriceMode.retail || canUseWholesalePrices;

  bool canConfirmAssistantCommand(String commandType) {
    if (canManageOperations) {
      return const {'SALE', 'PURCHASE', 'EXPENSE'}.contains(commandType);
    }
    return commandType == 'SALE';
  }
}

@immutable
class CurrentMembership {
  const CurrentMembership({
    required this.businessId,
    required this.businessName,
    required this.role,
  });

  final String businessId;
  final String businessName;
  final BusinessRole role;

  factory CurrentMembership.fromJson(Map<String, dynamic> json) =>
      CurrentMembership(
        businessId: (json['business_id'] ?? json['business'] ?? '').toString(),
        businessName: (json['business_name'] ?? '').toString(),
        role: BusinessRole.fromJson(json['role']),
      );
}

@immutable
class CurrentUser {
  const CurrentUser({
    required this.id,
    this.phone = '',
    this.displayName = '',
    this.memberships = const [],
  });

  final String id;
  final String phone;
  final String displayName;
  final List<CurrentMembership> memberships;

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    final memberships = json['memberships'];
    return CurrentUser(
      id: (json['id'] ?? json['user_id'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_e164'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['name'] ?? '').toString(),
      memberships: memberships is List
          ? memberships
              .whereType<Map>()
              .map((row) =>
                  CurrentMembership.fromJson(Map<String, dynamic>.from(row)))
              .toList(growable: false)
          : const [],
    );
  }
}

@immutable
class BusinessBootstrap {
  const BusinessBootstrap({
    required this.userId,
    required this.businessId,
    required this.role,
    this.permissions = const [],
  });

  final String userId;
  final String businessId;
  final BusinessRole role;
  final List<String> permissions;

  factory BusinessBootstrap.fromJson(Map<String, dynamic> json) {
    final user = _record(json['user']) ?? const <String, dynamic>{};
    final business = _record(json['business']) ?? const <String, dynamic>{};
    final permissions = json['permissions'];
    return BusinessBootstrap(
      userId: (user['id'] ?? user['user_id'] ?? '').toString(),
      businessId: (business['id'] ?? business['business_id'] ?? '').toString(),
      role: BusinessRole.fromJson(user['role'] ?? json['role']),
      permissions: permissions is List
          ? permissions.map((permission) => permission.toString()).toList()
          : const [],
    );
  }
}

@immutable
class DashboardSummary {
  const DashboardSummary({
    required this.salesMinor,
    required this.expensesMinor,
    required this.toReceiveMinor,
    required this.toPayMinor,
    required this.lowStockCount,
    required this.asOf,
    required this.summary,
  });

  final int salesMinor;
  final int expensesMinor;
  final int toReceiveMinor;
  final int toPayMinor;
  final int lowStockCount;
  final DateTime asOf;
  final String summary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final today = _record(json['today']);
    final books = _record(json['books']);
    return DashboardSummary(
      salesMinor: _nestedMinor(
        json,
        today,
        'sales_minor',
        legacyNestedKeys: const ['sales'],
        legacyKeys: const ['sales_today', 'sales', 'salesMinor', 'sales_minor'],
      ),
      expensesMinor: _nestedMinor(
        json,
        today,
        'expenses_minor',
        legacyNestedKeys: const ['expenses'],
        legacyKeys: const [
          'expenses_today',
          'expenses',
          'expensesMinor',
          'expenses_minor'
        ],
      ),
      toReceiveMinor: _nestedMinor(
        json,
        books,
        'receivable_minor',
        legacyNestedKeys: const ['receivable'],
        legacyKeys: const [
          'receivables',
          'to_receive',
          'receivable',
          'receivableMinor',
          'receivable_minor',
        ],
      ),
      toPayMinor: _nestedMinor(
        json,
        books,
        'payable_minor',
        legacyNestedKeys: const ['payable'],
        legacyKeys: const [
          'payables',
          'to_pay',
          'payable',
          'payableMinor',
          'payable_minor',
        ],
      ),
      lowStockCount: _intFrom(json['low_stock_count']),
      asOf:
          DateTime.tryParse((json['as_of'] ?? '').toString()) ?? DateTime.now(),
      summary: json.containsKey('summary')
          ? (json['summary'] ?? '').toString()
          : (json['ai_summary'] ?? '').toString(),
    );
  }
}

Map<String, dynamic>? _record(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

/// Explicit nested minor-unit fields win. Legacy values are consulted only
/// when the canonical key is absent; a present null value stays explicit.
int _nestedMinor(
  Map<String, dynamic> json,
  Map<String, dynamic>? nested,
  String key, {
  required List<String> legacyNestedKeys,
  required List<String> legacyKeys,
}) {
  if (nested != null && nested.containsKey(key)) return minorFrom(nested[key]);
  for (final legacyKey in legacyNestedKeys) {
    if (nested != null && nested.containsKey(legacyKey)) {
      return minorFrom(nested[legacyKey]);
    }
  }
  for (final legacyKey in legacyKeys) {
    if (json.containsKey(legacyKey)) return minorFrom(json[legacyKey]);
  }
  return 0;
}

int _intFrom(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

enum EntryType { sale, purchase, expense, payment }

@immutable
class BusinessEntry {
  const BusinessEntry({
    required this.id,
    required this.type,
    required this.reference,
    required this.partyName,
    required this.totalMinor,
    required this.pendingMinor,
    required this.occurredAt,
    this.reversed = false,
  });

  final String id;
  final EntryType type;
  final String reference;
  final String partyName;
  final int totalMinor;
  final int pendingMinor;
  final DateTime occurredAt;
  final bool reversed;
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.packId,
    required this.name,
    required this.sku,
    required this.unit,
    required this.stock,
    required this.lowStockAt,
    required this.retailPriceMinor,
    required this.wholesalePriceMinor,
  });

  final String id;
  final String packId;
  final String name;
  final String sku;
  final String unit;
  final Decimal stock;
  final Decimal lowStockAt;
  final int retailPriceMinor;
  final int wholesalePriceMinor;

  bool get isLowStock => stock <= lowStockAt;

  factory Product.fromJson(Map<String, dynamic> json) {
    final packs = json['packs'];
    final firstPack = packs is List && packs.isNotEmpty && packs.first is Map
        ? Map<String, dynamic>.from(packs.first as Map)
        : <String, dynamic>{};
    return Product(
      id: json['id'].toString(),
      packId: (json['default_pack_id'] ??
              firstPack['id'] ??
              json['pack_id'] ??
              json['id'])
          .toString(),
      name: (json['name'] ?? 'Product').toString(),
      sku: (json['sku'] ?? '').toString(),
      unit: (json['unit'] ?? firstPack['unit_name'] ?? 'pcs').toString(),
      stock: json.containsKey('stock_quantity')
          ? decimalFrom(json['stock_quantity'])
          : decimalFrom(json['stock'] ?? json['quantity_on_hand']),
      lowStockAt:
          decimalFrom(json['low_stock_threshold'] ?? json['reorder_level']),
      retailPriceMinor: minorFromRecord(
        firstPack.isNotEmpty ? firstPack : json,
        'retail_price_minor',
        'retail_price',
      ),
      wholesalePriceMinor: minorFromRecord(
        firstPack.isNotEmpty ? firstPack : json,
        'wholesale_price_minor',
        'wholesale_price',
      ),
    );
  }
}

enum PartyKind { customer, supplier, both }

@immutable
class Party {
  const Party({
    required this.id,
    required this.name,
    required this.phone,
    required this.kind,
    required this.toReceiveMinor,
    required this.toPayMinor,
  });

  final String id;
  final String name;
  final String phone;
  final PartyKind kind;
  final int toReceiveMinor;
  final int toPayMinor;

  factory Party.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? json['party_type'] ?? 'CUSTOMER')
        .toString()
        .toUpperCase();
    return Party(
      id: json['id'].toString(),
      name: (json['name'] ?? 'Party').toString(),
      phone: (json['phone_e164'] ?? json['phone'] ?? '').toString(),
      kind: switch (rawKind) {
        'SUPPLIER' => PartyKind.supplier,
        'BOTH' => PartyKind.both,
        _ => PartyKind.customer,
      },
      toReceiveMinor: minorFrom(
        json['receivable_minor'] ??
            json['to_receive_minor'] ??
            json['receivable_balance'],
      ),
      toPayMinor: minorFrom(
        json['payable_minor'] ??
            json['to_pay_minor'] ??
            json['payable_balance'],
      ),
    );
  }
}

enum PriceMode { retail, wholesale }

extension PriceModeApi on PriceMode {
  String get apiValue => name.toUpperCase();
}

enum PaymentMethod { cash, upi, card, bank, other }

extension PaymentMethodApi on PaymentMethod {
  String get apiValue => name.toUpperCase();
}

@immutable
class SaleLineDraft {
  const SaleLineDraft({
    required this.productId,
    required this.packId,
    required this.productName,
    required this.quantity,
    required this.unitPriceMinor,
  });

  final String productId;
  final String packId;
  final String productName;
  final Decimal quantity;
  final int unitPriceMinor;

  int get totalMinor =>
      (quantity * Decimal.fromInt(unitPriceMinor)).round().toBigInt().toInt();

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'pack_id': packId,
        'product_name': productName,
        'quantity': quantity.toString(),
        'unit_price_minor': unitPriceMinor,
      };

  factory SaleLineDraft.fromJson(Map<String, dynamic> json) => SaleLineDraft(
        productId: (json['product_id'] ?? '').toString(),
        packId: (json['pack_id'] ?? '').toString(),
        productName: (json['product_name'] ?? 'Product').toString(),
        quantity: decimalFrom(json['quantity'], '1'),
        unitPriceMinor:
            minorFrom(json['unit_price_minor'] ?? json['unit_price']),
      );
}

@immutable
class SaleDraft {
  const SaleDraft({
    required this.id,
    required this.businessId,
    required this.locationId,
    required this.lines,
    required this.paidAmountMinor,
    required this.priceMode,
    required this.paymentMethod,
    this.customerId,
    this.customerName,
    this.paymentReference,
    this.createdAt,
  });

  final String id;
  final String businessId;
  final String locationId;
  final String? customerId;
  final String? customerName;
  final List<SaleLineDraft> lines;
  final int paidAmountMinor;
  final PriceMode priceMode;
  final PaymentMethod paymentMethod;
  final String? paymentReference;
  final DateTime? createdAt;

  int get totalMinor => lines.fold(0, (sum, line) => sum + line.totalMinor);
  int get pendingMinor {
    final difference = totalMinor - paidAmountMinor;
    return difference < 0 ? 0 : difference;
  }

  Map<String, dynamic> toApiJson(String idempotencyKey) => {
        'business_id': businessId,
        'location_id': locationId,
        if (customerId != null) 'customer_id': customerId,
        'price_mode': priceMode.apiValue,
        'tax_inclusive': false,
        'discount_total_minor': 0,
        'negative_stock_acknowledged': false,
        'negative_stock_reason': '',
        'lines': lines
            .map(
              (line) => {
                'pack_id': line.packId,
                'quantity': line.quantity.toString(),
                'unit_price_minor': line.unitPriceMinor,
              },
            )
            .toList(),
        'paid_amount_minor': paidAmountMinor,
        'payment_method': paymentMethod.apiValue,
        if (paymentReference != null && paymentReference!.isNotEmpty)
          'payment_reference': paymentReference,
        'idempotency_key': idempotencyKey,
      };

  Map<String, dynamic> toLocalJson() => {
        'id': id,
        'business_id': businessId,
        'location_id': locationId,
        'customer_id': customerId,
        'customer_name': customerName,
        'lines': lines.map((line) => line.toJson()).toList(),
        'paid_amount_minor': paidAmountMinor,
        'price_mode': priceMode.name,
        'payment_method': paymentMethod.name,
        'payment_reference': paymentReference,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory SaleDraft.fromLocalJson(Map<String, dynamic> json) => SaleDraft(
        id: json['id'].toString(),
        businessId: json['business_id'].toString(),
        locationId: json['location_id'].toString(),
        customerId: json['customer_id']?.toString(),
        customerName: json['customer_name']?.toString(),
        lines: (json['lines'] as List? ?? const [])
            .map((line) =>
                SaleLineDraft.fromJson(Map<String, dynamic>.from(line as Map)))
            .toList(),
        paidAmountMinor:
            minorFrom(json['paid_amount_minor'] ?? json['paid_amount']),
        priceMode: PriceMode.values
            .byName((json['price_mode'] ?? 'retail').toString()),
        paymentMethod: PaymentMethod.values
            .byName((json['payment_method'] ?? 'cash').toString()),
        paymentReference: json['payment_reference']?.toString(),
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      );
}

enum AssistantInputType { text, voice, image }

extension AssistantInputTypeApi on AssistantInputType {
  String get apiValue => name.toUpperCase();
}

@immutable
class AssistantInput {
  const AssistantInput({
    required this.type,
    required this.content,
    required this.displayText,
  });

  final AssistantInputType type;
  final String content;
  final String displayText;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'content': content,
        'display_text': displayText,
      };

  factory AssistantInput.fromJson(Map<String, dynamic> json) => AssistantInput(
        type: AssistantInputType.values.byName(json['type'].toString()),
        content: (json['content'] ?? '').toString(),
        displayText: (json['display_text'] ?? json['content'] ?? '').toString(),
      );
}

@immutable
class ReviewFact {
  const ReviewFact(this.label, this.value, {this.warning = false});

  final String label;
  final String value;
  final bool warning;
}

@immutable
class AttachmentUploadTicket {
  const AttachmentUploadTicket({
    required this.attachmentId,
    required this.uploadUrl,
    required this.uploadHeaders,
    this.expiresAt,
  });

  final String attachmentId;
  final String uploadUrl;
  final Map<String, String> uploadHeaders;
  final DateTime? expiresAt;

  factory AttachmentUploadTicket.fromJson(Map<String, dynamic> json) {
    final attachment = _record(json['attachment']);
    final id = attachment?['id']?.toString() ?? '';
    final uploadUrl = json['upload_url']?.toString() ?? '';
    if (id.isEmpty || uploadUrl.isEmpty) {
      throw const FormatException('Invalid attachment upload ticket.');
    }
    final uri = Uri.tryParse(uploadUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException('Invalid attachment upload URL.');
    }
    final rawHeaders =
        _record(json['upload_headers']) ?? const <String, dynamic>{};
    return AttachmentUploadTicket(
      attachmentId: id,
      uploadUrl: uploadUrl,
      uploadHeaders:
          rawHeaders.map((key, value) => MapEntry(key, value.toString())),
      expiresAt: DateTime.tryParse((json['expires_at'] ?? '').toString()),
    );
  }
}

@immutable
class AssistantProposal {
  const AssistantProposal({
    required this.id,
    required this.version,
    required this.status,
    required this.commandType,
    required this.title,
    required this.facts,
    required this.warnings,
    required this.blockingQuestions,
    required this.rawPayload,
    this.transcript = '',
  });

  static const _confirmableCommands = {'SALE', 'PURCHASE', 'EXPENSE'};

  final String id;
  final int version;
  final String status;
  final String commandType;
  final String title;
  final List<ReviewFact> facts;
  final List<String> warnings;
  final List<String> blockingQuestions;
  final Map<String, dynamic> rawPayload;
  final String transcript;

  bool get canConfirm =>
      status == 'READY' &&
      _confirmableCommands.contains(commandType) &&
      blockingQuestions.isEmpty;

  bool canBeRecordedBy(BusinessRole role) {
    if (!role.canConfirmAssistantCommand(commandType)) return false;
    if (role.canUseWholesalePrices || commandType != 'SALE') return true;
    return rawPayload['price_mode']?.toString().toUpperCase() != 'WHOLESALE';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'version': version,
        'status': status,
        'command_type': commandType,
        'title': title,
        'facts': facts
            .map((fact) => {
                  'label': fact.label,
                  'value': fact.value,
                  'warning': fact.warning,
                })
            .toList(),
        'warnings': warnings,
        'blocking_questions': blockingQuestions,
        'payload': rawPayload,
        'content': transcript,
      };

  factory AssistantProposal.fromJson(Map<String, dynamic> json) {
    final preview = _record(json['preview']) ?? const <String, dynamic>{};
    final rawPayload = _record(json['payload']) ?? const <String, dynamic>{};
    final commandType = (json['command_type'] ?? '').toString().toUpperCase();
    final facts =
        _reviewFacts(json['facts'] ?? preview['facts'] ?? preview['fields']);
    if (facts.isEmpty) {
      for (final entry in preview.entries) {
        if (const {'title', 'summary', 'facts', 'fields'}.contains(entry.key)) {
          continue;
        }
        final value = entry.value;
        if (value is String || value is num || value is bool) {
          facts.add(ReviewFact(_humanize(entry.key), value.toString()));
        }
      }
    }
    final previewText =
        json['preview'] is String ? (json['preview'] as String).trim() : '';
    final explicitTitle =
        (json['title'] ?? preview['title'] ?? preview['summary'] ?? '')
            .toString()
            .trim();
    return AssistantProposal(
      id: json['id'].toString(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      status: (json['status'] ?? '').toString().toUpperCase(),
      commandType: commandType,
      title: explicitTitle.isNotEmpty
          ? explicitTitle
          : previewText.isNotEmpty
              ? previewText
              : 'Proposed entry',
      facts: facts.isEmpty ? _factsFromPayload(rawPayload, commandType) : facts,
      warnings: _stringList(json['warnings']),
      blockingQuestions: _stringList(json['blocking_questions']),
      rawPayload: rawPayload,
      transcript: (json['content'] ?? '').toString(),
    );
  }
}

List<ReviewFact> _reviewFacts(Object? value) {
  if (value is! List) return [];
  return value.whereType<Map>().map((fact) {
    return ReviewFact(
      (fact['label'] ?? fact['name'] ?? '').toString(),
      (fact['value'] ?? '').toString(),
      warning: fact['warning'] == true,
    );
  }).toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList(growable: false);
}

String _humanize(String key) {
  final spaced = key.replaceAll('_', ' ');
  return spaced.isEmpty
      ? spaced
      : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

String _paymentMethodLabel(Object? value) {
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return '';
  if (normalized == 'upi') return 'UPI';
  return _humanize(normalized);
}

String _decimalLabel(Decimal value) {
  final text = value.toString();
  if (!text.contains('.')) return text;
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// The API currently returns a human-readable preview string. Build a
/// structured review from the postable payload so the user still sees the
/// important amounts before confirming.
List<ReviewFact> _factsFromPayload(
    Map<String, dynamic> payload, String commandType) {
  final facts = <ReviewFact>[];
  void text(String label, Object? value) {
    final rendered = value?.toString().trim() ?? '';
    if (rendered.isNotEmpty) facts.add(ReviewFact(label, rendered));
  }

  if (commandType == 'EXPENSE') {
    text('Category', payload['category']);
    text('Payee', payload['payee']);
    if (payload.containsKey('amount_minor')) {
      facts.add(ReviewFact('Amount',
          formatExactMoney(minorFrom(payload['amount_minor']), 'en')));
    }
    text('Payment method', _paymentMethodLabel(payload['payment_method']));
    text('Date', payload['expense_date']);
    return facts;
  }

  if (commandType != 'SALE' && commandType != 'PURCHASE') return facts;

  final isSale = commandType == 'SALE';
  text(isSale ? 'Customer' : 'Supplier',
      payload[isSale ? 'new_customer_name' : 'new_supplier_name']);
  final rawLines = payload['lines'];
  final lines =
      rawLines is List ? rawLines.whereType<Map>().toList() : const <Map>[];
  if (lines.isNotEmpty) {
    final quantity = lines.fold<Decimal>(
      Decimal.zero,
      (sum, line) => sum + decimalFrom(line['quantity']),
    );
    facts.add(ReviewFact('Items', _decimalLabel(quantity)));
  }
  final total = _payloadTotalMinor(payload, commandType);
  if (total != null) {
    facts.add(ReviewFact('Total', formatExactMoney(total, 'en')));
  }
  if (payload.containsKey('paid_amount_minor')) {
    final paid = minorFrom(payload['paid_amount_minor']);
    facts.add(ReviewFact('Paid', formatExactMoney(paid, 'en')));
    if (total != null) {
      final pending = total - paid;
      facts.add(ReviewFact(
        'Pending',
        formatExactMoney(pending < 0 ? 0 : pending, 'en'),
        warning: pending < 0,
      ));
    }
  }
  text('Payment method', _paymentMethodLabel(payload['payment_method']));
  text('Date', payload[isSale ? 'invoice_date' : 'purchase_date']);
  return facts;
}

int? _payloadTotalMinor(Map<String, dynamic> payload, String commandType) {
  final explicitTotal = payload['total_minor'] ?? payload['grand_total_minor'];
  if (explicitTotal != null) return minorFrom(explicitTotal);
  final rawLines = payload['lines'];
  if (rawLines is! List || rawLines.isEmpty) return null;
  final priceKey =
      commandType == 'SALE' ? 'unit_price_minor' : 'unit_cost_minor';
  var total = 0;
  for (final rawLine in rawLines.whereType<Map>()) {
    final line = Map<String, dynamic>.from(rawLine);
    if (!line.containsKey(priceKey)) return null;
    final lineTotal = (decimalFrom(line['quantity']) *
            Decimal.fromInt(minorFrom(line[priceKey])))
        .round()
        .toBigInt()
        .toInt();
    total += lineTotal - minorFrom(line['discount_minor']);
  }
  total -= minorFrom(payload['discount_total_minor']);
  return total < 0 ? 0 : total;
}

@immutable
class PostedResult {
  const PostedResult(
      {required this.id, required this.reference, required this.message});

  final String id;
  final String reference;
  final String message;
}

enum DraftKind { assistant, sale, purchase, expense, payment, transfer }

enum OperationKind { purchase, expense, payment, transfer }

extension OperationKindDraft on OperationKind {
  DraftKind get draftKind => switch (this) {
        OperationKind.purchase => DraftKind.purchase,
        OperationKind.expense => DraftKind.expense,
        OperationKind.payment => DraftKind.payment,
        OperationKind.transfer => DraftKind.transfer,
      };
}

/// A reviewed operations form payload. It stays local until the user explicitly
/// sends it; [toApiJson] always re-applies the current business/location scope
/// and a stable idempotency key.
@immutable
class OperationDraft {
  const OperationDraft({
    required this.id,
    required this.kind,
    required this.businessId,
    required this.locationId,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final OperationKind kind;
  final String businessId;
  final String locationId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  bool get isReceipt =>
      kind == OperationKind.payment && payload['direction'] == 'RECEIPT';

  bool canBeRecordedBy(BusinessRole role) {
    if (role.canManageOperations) return true;
    return kind == OperationKind.payment && isReceipt;
  }

  Map<String, dynamic> toApiJson(String idempotencyKey) => {
        ...payload,
        'business_id': businessId,
        'location_id': locationId,
        'idempotency_key': idempotencyKey,
      };

  Map<String, dynamic> toLocalJson() => {
        'id': id,
        'operation': kind.name,
        'business_id': businessId,
        'location_id': locationId,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };

  factory OperationDraft.fromLocalJson(Map<String, dynamic> json) {
    final kind = OperationKind.values.byName(json['operation'].toString());
    final payload = json['payload'];
    return OperationDraft(
      id: (json['id'] ?? '').toString(),
      kind: kind,
      businessId: (json['business_id'] ?? '').toString(),
      locationId: (json['location_id'] ?? '').toString(),
      payload: payload is Map
          ? Map<String, dynamic>.from(payload)
          : const <String, dynamic>{},
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

@immutable
class LocalDraft {
  const LocalDraft({
    required this.id,
    required this.kind,
    required this.userId,
    required this.businessId,
    required this.locationId,
    required this.label,
    required this.payload,
    required this.createdAt,
  })  : assert(userId.length > 0),
        assert(businessId.length > 0);

  final String id;
  final DraftKind kind;
  final String userId;
  final String businessId;
  final String locationId;
  final String label;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  bool belongsTo({required String userId, required String businessId}) =>
      this.userId == userId && this.businessId == businessId;

  String get encodedPayload => jsonEncode(payload);
}

@immutable
class Business {
  const Business({
    required this.id,
    required this.name,
    this.legalName = '',
    this.currency = 'INR',
    this.timezone = 'Asia/Kolkata',
    this.role,
  });

  final String id;
  final String name;
  final String legalName;
  final String currency;
  final String timezone;
  final String? role;

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: json['id'].toString(),
        name: (json['name'] ?? 'Business').toString(),
        legalName: (json['legal_name'] ?? '').toString(),
        currency: (json['currency'] ?? 'INR').toString(),
        timezone: (json['timezone'] ?? 'Asia/Kolkata').toString(),
        role: json['role']?.toString(),
      );
}

@immutable
class Membership {
  const Membership({
    required this.id,
    required this.businessId,
    this.userId = '',
    required this.role,
    this.isActive = true,
  });

  final String id;
  final String businessId;
  final String userId;
  final String role;
  final bool isActive;

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        id: json['id'].toString(),
        businessId: (json['business'] ?? json['business_id'] ?? '').toString(),
        userId: (json['user'] ?? json['user_id'] ?? '').toString(),
        role: (json['role'] ?? '').toString(),
        isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
      );
}

@immutable
class GstRegistration {
  const GstRegistration({
    required this.id,
    required this.businessId,
    this.gstin = '',
    this.legalName = '',
    this.address = '',
    this.stateCode = '',
    this.invoicePrefix = '',
  });

  final String id;
  final String businessId;
  final String gstin;
  final String legalName;
  final String address;
  final String stateCode;
  final String invoicePrefix;

  factory GstRegistration.fromJson(Map<String, dynamic> json) =>
      GstRegistration(
        id: json['id'].toString(),
        businessId: (json['business'] ?? json['business_id'] ?? '').toString(),
        gstin: (json['gstin'] ?? '').toString(),
        legalName: (json['legal_name'] ?? '').toString(),
        address: (json['address'] ?? '').toString(),
        stateCode: (json['state_code'] ?? '').toString(),
        invoicePrefix: (json['invoice_prefix'] ?? '').toString(),
      );
}

@immutable
class StockRow {
  const StockRow({
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.lowStockThreshold,
    required this.isLowStock,
  });

  final String productId;
  final String name;
  final String unit;
  final Decimal quantity;
  final Decimal lowStockThreshold;
  final bool isLowStock;

  factory StockRow.fromJson(Map<String, dynamic> json) => StockRow(
        productId: (json['product_id'] ?? json['id'] ?? '').toString(),
        name: (json['name'] ?? 'Product').toString(),
        unit: (json['unit'] ?? json['base_unit'] ?? 'pcs').toString(),
        quantity: decimalFrom(json['quantity']),
        lowStockThreshold: decimalFrom(json['low_stock_threshold']),
        isLowStock: json['is_low_stock'] == true,
      );
}

@immutable
class LedgerReport {
  const LedgerReport({
    required this.partyId,
    required this.balanceMinor,
    required this.entries,
  });

  final String partyId;
  final int balanceMinor;
  final List<Map<String, dynamic>> entries;

  factory LedgerReport.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    return LedgerReport(
      partyId: (json['party_id'] ?? '').toString(),
      balanceMinor: minorFrom(json['balance']),
      entries: rawEntries is List
          ? rawEntries
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList(growable: false)
          : const [],
    );
  }
}

@immutable
class ProposalSummary {
  const ProposalSummary({
    required this.id,
    required this.version,
    required this.status,
  });

  final String id;
  final int version;
  final String status;

  factory ProposalSummary.fromJson(Map<String, dynamic> json) =>
      ProposalSummary(
        id: json['id'].toString(),
        version: (json['version'] as num?)?.toInt() ?? 1,
        status: (json['status'] ?? '').toString(),
      );
}

@immutable
class ProposalRevision {
  const ProposalRevision({
    required this.version,
    required this.snapshot,
    this.createdAt,
  });

  final int version;
  final Map<String, dynamic> snapshot;
  final DateTime? createdAt;

  factory ProposalRevision.fromJson(Map<String, dynamic> json) =>
      ProposalRevision(
        version: (json['version'] as num?)?.toInt() ?? 1,
        snapshot: json['snapshot'] is Map
            ? Map<String, dynamic>.from(json['snapshot'] as Map)
            : <String, dynamic>{},
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      );
}
