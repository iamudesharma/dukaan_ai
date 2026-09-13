import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

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
int minorFromRecord(Map<String, dynamic> json, String minorKey, String majorKey) {
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
    (Decimal.fromInt(minor) / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 2);

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
    final today = json['today'] is Map
        ? Map<String, dynamic>.from(json['today'] as Map)
        : <String, dynamic>{};
    final books = json['books'] is Map
        ? Map<String, dynamic>.from(json['books'] as Map)
        : <String, dynamic>{};
    return DashboardSummary(
      salesMinor: minorFrom(
        today['sales'] ??
            json['sales_today'] ??
            json['sales'] ??
            json['salesMinor'] ??
            json['sales_minor'],
      ),
      expensesMinor: minorFrom(
        today['expenses'] ??
            json['expenses_today'] ??
            json['expenses'] ??
            json['expensesMinor'] ??
            json['expenses_minor'],
      ),
      toReceiveMinor: minorFrom(
        books['receivable'] ??
            json['receivables'] ??
            json['to_receive'] ??
            json['receivable'] ??
            json['receivableMinor'],
      ),
      toPayMinor: minorFrom(
        books['payable'] ??
            json['payables'] ??
            json['to_pay'] ??
            json['payable'] ??
            json['payableMinor'],
      ),
      lowStockCount: (json['low_stock_count'] as num?)?.toInt() ?? 0,
      asOf: DateTime.tryParse((json['as_of'] ?? '').toString()) ?? DateTime.now(),
      summary: (json['summary'] ?? json['ai_summary'] ?? '').toString(),
    );
  }
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
      packId: (json['default_pack_id'] ?? firstPack['id'] ?? json['pack_id'] ?? json['id'])
          .toString(),
      name: (json['name'] ?? 'Product').toString(),
      sku: (json['sku'] ?? '').toString(),
      unit: (json['unit'] ?? firstPack['unit_name'] ?? 'pcs').toString(),
      stock: decimalFrom(
        json['stock_quantity'] ?? json['stock'] ?? json['quantity_on_hand'],
      ),
      lowStockAt: decimalFrom(json['low_stock_threshold'] ?? json['reorder_level']),
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
      phone: (json['phone'] ?? json['phone_e164'] ?? '').toString(),
      kind: switch (rawKind) {
        'SUPPLIER' => PartyKind.supplier,
        'BOTH' => PartyKind.both,
        _ => PartyKind.customer,
      },
      toReceiveMinor: json['receivable_minor'] != null
          ? minorFrom(json['receivable_minor'])
          : minorFromRecord(json, 'to_receive_minor', 'receivable_balance'),
      toPayMinor: json['payable_minor'] != null
          ? minorFrom(json['payable_minor'])
          : minorFromRecord(json, 'to_pay_minor', 'payable_balance'),
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

  int get totalMinor => (quantity * Decimal.fromInt(unitPriceMinor)).round().toBigInt().toInt();

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
        unitPriceMinor: minorFrom(json['unit_price_minor'] ?? json['unit_price']),
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
            .map((line) => SaleLineDraft.fromJson(Map<String, dynamic>.from(line as Map)))
            .toList(),
        paidAmountMinor: minorFrom(json['paid_amount_minor'] ?? json['paid_amount']),
        priceMode: PriceMode.values.byName((json['price_mode'] ?? 'retail').toString()),
        paymentMethod:
            PaymentMethod.values.byName((json['payment_method'] ?? 'cash').toString()),
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
}

@immutable
class ReviewFact {
  const ReviewFact(this.label, this.value, {this.warning = false});

  final String label;
  final String value;
  final bool warning;
}

@immutable
class AssistantProposal {
  const AssistantProposal({
    required this.id,
    required this.version,
    required this.commandType,
    required this.title,
    required this.facts,
    required this.warnings,
    required this.blockingQuestions,
    required this.rawPayload,
  });

  final String id;
  final int version;
  final String commandType;
  final String title;
  final List<ReviewFact> facts;
  final List<String> warnings;
  final List<String> blockingQuestions;
  final Map<String, dynamic> rawPayload;

  bool get canConfirm => blockingQuestions.isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'version': version,
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
      };
}

@immutable
class PostedResult {
  const PostedResult({required this.id, required this.reference, required this.message});

  final String id;
  final String reference;
  final String message;
}

enum DraftKind { assistant, sale }

@immutable
class LocalDraft {
  const LocalDraft({
    required this.id,
    required this.kind,
    required this.locationId,
    required this.label,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final DraftKind kind;
  final String locationId;
  final String label;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

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

  factory GstRegistration.fromJson(Map<String, dynamic> json) => GstRegistration(
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

  factory ProposalSummary.fromJson(Map<String, dynamic> json) => ProposalSummary(
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

  factory ProposalRevision.fromJson(Map<String, dynamic> json) => ProposalRevision(
        version: (json['version'] as num?)?.toInt() ?? 1,
        snapshot: json['snapshot'] is Map
            ? Map<String, dynamic>.from(json['snapshot'] as Map)
            : <String, dynamic>{},
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      );
}
