import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter/foundation.dart';

Map<String, dynamic> _record(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> _records(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false)
    : const [];

DateTime? _date(Object? value) => DateTime.tryParse(value?.toString() ?? '');

int? _nullableMinor(Object? value) => value == null ? null : minorFrom(value);

@immutable
class Invitation {
  const Invitation({
    required this.id,
    required this.businessId,
    required this.inviteePhone,
    required this.role,
    required this.status,
    required this.expiresAt,
    this.locations = const [],
    this.inviter,
    this.acceptedBy,
    this.acceptedAt,
    this.revokedAt,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  final String id;
  final String businessId;
  final String inviteePhone;
  final String role;
  final String status;
  final DateTime expiresAt;
  final List<String> locations;
  final String? inviter;
  final String? acceptedBy;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Returned only by the create response. Never persist or log this value.
  final String? token;

  bool get isPending => status == 'PENDING';

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
        id: (json['id'] ?? '').toString(),
        businessId: (json['business'] ?? json['business_id'] ?? '').toString(),
        inviteePhone: (json['invitee_phone'] ?? '').toString(),
        role: (json['role'] ?? '').toString(),
        status: (json['status'] ?? '').toString().toUpperCase(),
        expiresAt:
            _date(json['expires_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        locations: json['locations'] is List
            ? (json['locations'] as List)
                .map((value) => value.toString())
                .toList(growable: false)
            : const [],
        inviter: json['inviter']?.toString(),
        acceptedBy: json['accepted_by']?.toString(),
        acceptedAt: _date(json['accepted_at']),
        revokedAt: _date(json['revoked_at']),
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
        token: json['token']?.toString(),
      );
}

@immutable
class SaleInvoicePdf {
  const SaleInvoicePdf({required this.bytes, required this.filename});

  final List<int> bytes;
  final String filename;
}

enum CsvImportKind { product, party }

extension CsvImportKindApi on CsvImportKind {
  String get apiValue => name.toUpperCase();
  String get label => name == 'product' ? 'Products' : 'Parties';
}

@immutable
class ImportPreviewRow {
  const ImportPreviewRow({required this.row, required this.action});

  final int row;
  final String action;

  factory ImportPreviewRow.fromJson(Map<String, dynamic> json) =>
      ImportPreviewRow(
        row: int.tryParse(json['row']?.toString() ?? '') ?? 0,
        action: (json['action'] ?? '').toString().toUpperCase(),
      );
}

@immutable
class ImportDryRun {
  const ImportDryRun({
    required this.kind,
    required this.duplicateStrategy,
    required this.rowCount,
    required this.validRowCount,
    required this.errorCount,
    required this.createdCount,
    required this.updatedCount,
    required this.skippedCount,
    required this.errors,
    required this.preview,
  });

  final String kind;
  final String duplicateStrategy;
  final int rowCount;
  final int validRowCount;
  final int errorCount;
  final int createdCount;
  final int updatedCount;
  final int skippedCount;
  final List<Map<String, dynamic>> errors;
  final List<ImportPreviewRow> preview;

  bool get canPrepare => errorCount == 0 && validRowCount > 0;

  factory ImportDryRun.fromJson(Map<String, dynamic> json) => ImportDryRun(
        kind: (json['kind'] ?? '').toString().toUpperCase(),
        duplicateStrategy:
            (json['duplicate_strategy'] ?? 'UPDATE').toString().toUpperCase(),
        rowCount: int.tryParse(json['row_count']?.toString() ?? '') ?? 0,
        validRowCount:
            int.tryParse(json['valid_row_count']?.toString() ?? '') ?? 0,
        errorCount: int.tryParse(json['error_count']?.toString() ?? '') ?? 0,
        createdCount:
            int.tryParse(json['created_count']?.toString() ?? '') ?? 0,
        updatedCount:
            int.tryParse(json['updated_count']?.toString() ?? '') ?? 0,
        skippedCount:
            int.tryParse(json['skipped_count']?.toString() ?? '') ?? 0,
        errors: _records(json['errors']),
        preview: (json['preview'] is List)
            ? (json['preview'] as List)
                .whereType<Map>()
                .map((row) =>
                    ImportPreviewRow.fromJson(Map<String, dynamic>.from(row)))
                .toList(growable: false)
            : const [],
      );
}

@immutable
class ImportJob {
  const ImportJob({
    required this.id,
    required this.businessId,
    required this.kind,
    required this.status,
    required this.duplicateStrategy,
    required this.rowCount,
    required this.validRowCount,
    required this.errorCount,
    required this.createdCount,
    required this.updatedCount,
    required this.skippedCount,
    required this.errors,
    required this.originalFilename,
    required this.fileSizeBytes,
    this.userId,
    this.confirmedBy,
    this.fileSha256 = '',
    this.createdAt,
    this.updatedAt,
    this.confirmedAt,
  });

  final String id;
  final String businessId;
  final String kind;
  final String status;
  final String duplicateStrategy;
  final int rowCount;
  final int validRowCount;
  final int errorCount;
  final int createdCount;
  final int updatedCount;
  final int skippedCount;
  final List<Map<String, dynamic>> errors;
  final String originalFilename;
  final int fileSizeBytes;
  final String? userId;
  final String? confirmedBy;
  final String fileSha256;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;

  bool get canConfirm =>
      status == 'READY' && errorCount == 0 && validRowCount > 0;

  factory ImportJob.fromJson(Map<String, dynamic> json) => ImportJob(
        id: (json['id'] ?? '').toString(),
        businessId: (json['business'] ?? json['business_id'] ?? '').toString(),
        kind: (json['kind'] ?? '').toString().toUpperCase(),
        status: (json['status'] ?? '').toString().toUpperCase(),
        duplicateStrategy:
            (json['duplicate_strategy'] ?? 'UPDATE').toString().toUpperCase(),
        rowCount: int.tryParse(json['row_count']?.toString() ?? '') ?? 0,
        validRowCount:
            int.tryParse(json['valid_row_count']?.toString() ?? '') ?? 0,
        errorCount: int.tryParse(json['error_count']?.toString() ?? '') ?? 0,
        createdCount:
            int.tryParse(json['created_count']?.toString() ?? '') ?? 0,
        updatedCount:
            int.tryParse(json['updated_count']?.toString() ?? '') ?? 0,
        skippedCount:
            int.tryParse(json['skipped_count']?.toString() ?? '') ?? 0,
        errors: _records(json['errors']),
        originalFilename:
            (json['original_filename'] ?? 'import.csv').toString(),
        fileSizeBytes:
            int.tryParse(json['file_size_bytes']?.toString() ?? '') ?? 0,
        userId: json['user']?.toString(),
        confirmedBy: json['confirmed_by']?.toString(),
        fileSha256: (json['file_sha256'] ?? '').toString(),
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
        confirmedAt: _date(json['confirmed_at']),
      );
}

@immutable
class ImportConfirmation {
  const ImportConfirmation({required this.job, required this.replayed});

  final ImportJob job;
  final bool replayed;

  factory ImportConfirmation.fromJson(Map<String, dynamic> json) =>
      ImportConfirmation(
        job: ImportJob.fromJson(_record(json['job'])),
        replayed: json['replayed'] == true,
      );
}

@immutable
class ValuationInventory {
  const ValuationInventory({
    required this.totalQuantity,
    required this.averageCostMinor,
    required this.totalValueMinor,
    required this.knownValueMinor,
    required this.costingComplete,
  });

  final Decimal totalQuantity;
  final int? averageCostMinor;
  final int? totalValueMinor;
  final int knownValueMinor;
  final bool costingComplete;

  factory ValuationInventory.fromJson(Map<String, dynamic> json) =>
      ValuationInventory(
        totalQuantity: decimalFrom(json['total_quantity']),
        averageCostMinor: _nullableMinor(json['average_cost_minor']),
        totalValueMinor: _nullableMinor(json['total_value_minor']),
        knownValueMinor: minorFrom(json['known_value_minor']),
        costingComplete: json['costing_complete'] == true,
      );
}

@immutable
class ValuationSales {
  const ValuationSales({
    required this.postedSaleCount,
    required this.lineCount,
    required this.netSalesMinor,
    required this.cogsMinor,
    required this.grossProfitMinor,
    required this.missingCostLineCount,
    required this.costingComplete,
  });

  final int postedSaleCount;
  final int lineCount;
  final int netSalesMinor;
  final int cogsMinor;
  final int? grossProfitMinor;
  final int missingCostLineCount;
  final bool costingComplete;

  factory ValuationSales.fromJson(Map<String, dynamic> json) => ValuationSales(
        postedSaleCount:
            int.tryParse(json['posted_sale_count']?.toString() ?? '') ?? 0,
        lineCount: int.tryParse(json['line_count']?.toString() ?? '') ?? 0,
        netSalesMinor: minorFrom(json['net_sales_minor']),
        cogsMinor: minorFrom(json['cogs_minor']),
        grossProfitMinor: _nullableMinor(json['gross_profit_minor']),
        missingCostLineCount:
            int.tryParse(json['missing_cost_line_count']?.toString() ?? '') ??
                0,
        costingComplete: json['costing_complete'] == true,
      );
}

@immutable
class ValuationRow {
  const ValuationRow({
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.averageCostMinor,
    required this.totalValueMinor,
    required this.knownValueMinor,
    required this.unknownCostQuantity,
    required this.costingComplete,
  });

  final String productId;
  final String name;
  final String unit;
  final Decimal quantity;
  final int? averageCostMinor;
  final int? totalValueMinor;
  final int knownValueMinor;
  final Decimal unknownCostQuantity;
  final bool costingComplete;

  factory ValuationRow.fromJson(Map<String, dynamic> json) => ValuationRow(
        productId: (json['product_id'] ?? '').toString(),
        name: (json['name'] ?? 'Product').toString(),
        unit: (json['unit'] ?? '').toString(),
        quantity: decimalFrom(json['quantity']),
        averageCostMinor: _nullableMinor(json['average_cost_minor']),
        totalValueMinor: _nullableMinor(json['total_value_minor']),
        knownValueMinor: minorFrom(json['known_value_minor']),
        unknownCostQuantity: decimalFrom(json['unknown_cost_quantity']),
        costingComplete: json['costing_complete'] == true,
      );
}

@immutable
class ValuationReport {
  const ValuationReport({
    required this.inventory,
    required this.sales,
    required this.rows,
  });

  final ValuationInventory inventory;
  final ValuationSales sales;
  final List<ValuationRow> rows;

  factory ValuationReport.fromJson(Map<String, dynamic> json) =>
      ValuationReport(
        inventory: ValuationInventory.fromJson(_record(json['inventory'])),
        sales: ValuationSales.fromJson(_record(json['sales'])),
        rows: (json['results'] is List)
            ? (json['results'] as List)
                .whereType<Map>()
                .map((row) =>
                    ValuationRow.fromJson(Map<String, dynamic>.from(row)))
                .toList(growable: false)
            : const [],
      );
}

@immutable
class PaymentAllocation {
  const PaymentAllocation({
    required this.id,
    required this.amountMinor,
    required this.documentType,
    this.documentId,
    this.documentNumber,
    this.documentTotalMinor,
    this.documentPaidTotalMinor,
    this.documentDueTotalMinor,
    this.saleId,
    this.purchaseId,
  });

  final String id;
  final int amountMinor;
  final String documentType;
  final String? documentId;
  final String? documentNumber;
  final int? documentTotalMinor;
  final int? documentPaidTotalMinor;
  final int? documentDueTotalMinor;
  final String? saleId;
  final String? purchaseId;

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) =>
      PaymentAllocation(
        id: (json['id'] ?? '').toString(),
        amountMinor: minorFrom(json['amount_minor']),
        documentType: (json['document_type'] ?? '').toString().toUpperCase(),
        documentId: json['document_id']?.toString(),
        documentNumber: json['document_number']?.toString(),
        documentTotalMinor: _nullableMinor(json['document_total_minor']),
        documentPaidTotalMinor:
            _nullableMinor(json['document_paid_total_minor']),
        documentDueTotalMinor: _nullableMinor(json['document_due_total_minor']),
        saleId: json['sale']?.toString(),
        purchaseId: json['purchase']?.toString(),
      );
}

@immutable
class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.businessId,
    required this.locationId,
    required this.partyId,
    required this.direction,
    required this.method,
    required this.amountMinor,
    required this.status,
    required this.allocatedTotalMinor,
    required this.unallocatedTotalMinor,
    required this.allocations,
    this.reference = '',
    this.note = '',
    this.paymentDate,
    this.reversalReason,
    this.reversedAt,
  });

  final String id;
  final String businessId;
  final String locationId;
  final String partyId;
  final String direction;
  final String method;
  final int amountMinor;
  final String status;
  final int allocatedTotalMinor;
  final int unallocatedTotalMinor;
  final List<PaymentAllocation> allocations;
  final String reference;
  final String note;
  final DateTime? paymentDate;
  final String? reversalReason;
  final DateTime? reversedAt;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: (json['id'] ?? '').toString(),
        businessId: (json['business'] ?? json['business_id'] ?? '').toString(),
        locationId: (json['location'] ?? json['location_id'] ?? '').toString(),
        partyId: (json['party'] ?? json['party_id'] ?? '').toString(),
        direction: (json['direction'] ?? '').toString().toUpperCase(),
        method: (json['method'] ?? '').toString().toUpperCase(),
        amountMinor: minorFrom(json['amount_minor']),
        status: (json['status'] ?? '').toString().toUpperCase(),
        allocatedTotalMinor: minorFrom(json['allocated_total_minor']),
        unallocatedTotalMinor: minorFrom(json['unallocated_total_minor']),
        allocations: (json['allocations'] is List)
            ? (json['allocations'] as List)
                .whereType<Map>()
                .map((row) =>
                    PaymentAllocation.fromJson(Map<String, dynamic>.from(row)))
                .toList(growable: false)
            : const [],
        reference: (json['reference'] ?? '').toString(),
        note: (json['note'] ?? '').toString(),
        paymentDate: _date(json['payment_date']),
        reversalReason: json['reversal_reason']?.toString(),
        reversedAt: _date(json['reversed_at']),
      );
}

@immutable
class AllocationReviewTotals {
  const AllocationReviewTotals({
    required this.paymentCount,
    required this.paymentTotalMinor,
    required this.allocatedTotalMinor,
    required this.unallocatedTotalMinor,
    required this.outstandingDocumentCount,
    required this.outstandingTotalMinor,
  });

  final int paymentCount;
  final int paymentTotalMinor;
  final int allocatedTotalMinor;
  final int unallocatedTotalMinor;
  final int outstandingDocumentCount;
  final int outstandingTotalMinor;

  factory AllocationReviewTotals.fromJson(Map<String, dynamic> json) =>
      AllocationReviewTotals(
        paymentCount:
            int.tryParse(json['payment_count']?.toString() ?? '') ?? 0,
        paymentTotalMinor: minorFrom(json['payment_total_minor']),
        allocatedTotalMinor: minorFrom(json['allocated_total_minor']),
        unallocatedTotalMinor: minorFrom(json['unallocated_total_minor']),
        outstandingDocumentCount: int.tryParse(
                json['outstanding_document_count']?.toString() ?? '') ??
            0,
        outstandingTotalMinor: minorFrom(json['outstanding_total_minor']),
      );
}

@immutable
class OutstandingDocument {
  const OutstandingDocument({
    required this.documentType,
    required this.documentId,
    required this.number,
    required this.grandTotalMinor,
    required this.paidTotalMinor,
    required this.dueTotalMinor,
    this.documentDate,
    this.partyId,
    this.partyName,
  });

  final String documentType;
  final String documentId;
  final String number;
  final int grandTotalMinor;
  final int paidTotalMinor;
  final int dueTotalMinor;
  final DateTime? documentDate;
  final String? partyId;
  final String? partyName;

  factory OutstandingDocument.fromJson(Map<String, dynamic> json) =>
      OutstandingDocument(
        documentType: (json['document_type'] ?? '').toString().toUpperCase(),
        documentId: (json['document_id'] ?? '').toString(),
        number: (json['number'] ?? '').toString(),
        grandTotalMinor: minorFrom(json['grand_total_minor']),
        paidTotalMinor: minorFrom(json['paid_total_minor']),
        dueTotalMinor: minorFrom(json['due_total_minor']),
        documentDate: _date(json['document_date']),
        partyId: json['party_id']?.toString(),
        partyName: json['party_name']?.toString(),
      );
}

@immutable
class PaymentAllocationReview {
  const PaymentAllocationReview({
    required this.payments,
    required this.totals,
    required this.outstandingDocuments,
  });

  final List<PaymentRecord> payments;
  final AllocationReviewTotals totals;
  final List<OutstandingDocument> outstandingDocuments;

  factory PaymentAllocationReview.fromJson(Map<String, dynamic> json) =>
      PaymentAllocationReview(
        payments: _records(json['results'])
            .map(PaymentRecord.fromJson)
            .toList(growable: false),
        totals: AllocationReviewTotals.fromJson(_record(json['totals'])),
        outstandingDocuments: _records(json['outstanding_documents'])
            .map(OutstandingDocument.fromJson)
            .toList(growable: false),
      );
}

@immutable
class NotificationDevice {
  const NotificationDevice({
    required this.id,
    required this.businessId,
    required this.platform,
    required this.status,
    required this.tokenSuffix,
    this.locationId,
    this.lastSeenAt,
    this.unregisteredAt,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String businessId;
  final String? locationId;
  final String platform;
  final String status;
  final String tokenSuffix;
  final DateTime? lastSeenAt;
  final DateTime? unregisteredAt;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory NotificationDevice.fromJson(Map<String, dynamic> json) =>
      NotificationDevice(
        id: (json['id'] ?? '').toString(),
        businessId: (json['business'] ?? json['business_id'] ?? '').toString(),
        locationId: json['location']?.toString(),
        platform: (json['platform'] ?? '').toString().toUpperCase(),
        status: (json['status'] ?? '').toString().toUpperCase(),
        tokenSuffix: (json['token_suffix'] ?? '').toString(),
        lastSeenAt: _date(json['last_seen_at']),
        unregisteredAt: _date(json['unregistered_at']),
        metadata: _record(json['metadata']),
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
      );
}

@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.businessId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.status,
    this.locationId,
    this.kind = 'USER',
    this.dedupeKey = '',
    this.data = const {},
    this.metadata = const {},
    this.queuedAt,
    this.sentAt,
    this.cancelledAt,
    this.lastError = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String businessId;
  final String? locationId;
  final String kind;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String status;
  final String dedupeKey;
  final Map<String, dynamic> data;
  final Map<String, dynamic> metadata;
  final DateTime? queuedAt;
  final DateTime? sentAt;
  final DateTime? cancelledAt;
  final String lastError;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isScheduled => status == 'SCHEDULED';

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: (json['id'] ?? '').toString(),
        businessId: (json['business'] ?? json['business_id'] ?? '').toString(),
        locationId: json['location']?.toString(),
        kind: (json['kind'] ?? 'USER').toString().toUpperCase(),
        title: (json['title'] ?? '').toString(),
        body: (json['body'] ?? '').toString(),
        scheduledAt: _date(json['scheduled_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        status: (json['status'] ?? '').toString().toUpperCase(),
        dedupeKey: (json['dedupe_key'] ?? '').toString(),
        data: _record(json['data']),
        metadata: _record(json['metadata']),
        queuedAt: _date(json['queued_at']),
        sentAt: _date(json['sent_at']),
        cancelledAt: _date(json['cancelled_at']),
        lastError: (json['last_error'] ?? '').toString(),
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
      );
}
