import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/config.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:uuid/uuid.dart';

abstract interface class DukaanRepository {
  Future<List<BusinessLocation>> fetchLocations();
  Future<DashboardSummary> fetchDashboard(String locationId);
  Future<List<BusinessEntry>> fetchEntries(String locationId);
  Future<List<Product>> fetchProducts(String locationId);
  Future<List<Party>> fetchParties(String locationId);
  Future<AssistantProposal> interpret({
    required AssistantInput input,
    required String locationId,
    required String locale,
  });
  Future<AssistantProposal> refreshProposal(AssistantProposal proposal);
  Future<PostedResult> confirmProposal(AssistantProposal proposal);
  Future<PostedResult> createSale(SaleDraft draft);
}

class ApiDukaanRepository implements DukaanRepository {
  ApiDukaanRepository(this._dio);

  final Dio _dio;
  String? _businessId;

  Future<String> _resolveBusinessId() async {
    if (_businessId case final value?) return value;
    final response = await _dio.get<Object>('businesses/');
    final rows = _rows(response.data);
    if (rows.isEmpty) {
      throw StateError('No business is available for this account.');
    }
    return _businessId = rows.first['id'].toString();
  }

  @override
  Future<List<BusinessLocation>> fetchLocations() async {
    final businessId = await _resolveBusinessId();
    final response = await _dio.get<Object>('locations/', queryParameters: {'business_id': businessId});
    return _rows(response.data)
        .map(
          (row) => BusinessLocation.fromJson({...row, 'business_id': businessId}),
        )
        .toList(growable: false);
  }

  @override
  Future<DashboardSummary> fetchDashboard(String locationId) async {
    final businessId = await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'reports/dashboard/',
      queryParameters: {'business_id': businessId, 'location_id': locationId},
    );
    return DashboardSummary.fromJson(_object(response.data));
  }

  @override
  Future<List<BusinessEntry>> fetchEntries(String locationId) async {
    final businessId = await _resolveBusinessId();
    final query = {'business_id': businessId, 'location_id': locationId};
    final responses = await Future.wait([
      _dio.get<Object>('sales/', queryParameters: query),
      _dio.get<Object>('purchases/', queryParameters: query),
      _dio.get<Object>('expenses/', queryParameters: query),
      _dio.get<Object>('payments/', queryParameters: query),
    ]);
    final types = [EntryType.sale, EntryType.purchase, EntryType.expense, EntryType.payment];
    final entries = <BusinessEntry>[];
    for (var index = 0; index < responses.length; index++) {
      entries.addAll(
        _rows(responses[index].data).map((row) => _entryFromJson(row, types[index])),
      );
    }
    entries.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return entries;
  }

  @override
  Future<List<Product>> fetchProducts(String locationId) async {
    final businessId = await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'products/',
      queryParameters: {'business_id': businessId, 'location_id': locationId},
    );
    return _rows(response.data).map(Product.fromJson).toList(growable: false);
  }

  @override
  Future<List<Party>> fetchParties(String locationId) async {
    final businessId = await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'parties/',
      queryParameters: {'business_id': businessId, 'location_id': locationId},
    );
    return _rows(response.data).map(Party.fromJson).toList(growable: false);
  }

  @override
  Future<AssistantProposal> interpret({
    required AssistantInput input,
    required String locationId,
    required String locale,
  }) async {
    final businessId = await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'assistant/proposals/',
      data: {
        'business_id': businessId,
        'location_id': locationId,
        'input_type': input.type.apiValue,
        'content': input.content,
        'locale': locale,
      },
      options: Options(extra: {'locale': locale}),
    );
    return _proposalFromJson(_object(response.data));
  }

  @override
  Future<AssistantProposal> refreshProposal(AssistantProposal proposal) async {
    final response = await _dio.post<Object>(
      'assistant/proposals/${proposal.id}/revise/',
      data: {'version': proposal.version},
    );
    return _proposalFromJson(_object(response.data));
  }

  @override
  Future<PostedResult> confirmProposal(AssistantProposal proposal) async {
    final response = await _dio.post<Object>(
      'assistant/proposals/${proposal.id}/confirm/',
      data: {
        'version': proposal.version,
        'idempotency_key': 'proposal:${proposal.id}:v${proposal.version}',
      },
    );
    return _postedResult(_object(response.data));
  }

  @override
  Future<PostedResult> createSale(SaleDraft draft) async {
    final response = await _dio.post<Object>(
      'sales/',
      data: draft.toApiJson(const Uuid().v4()),
    );
    return _postedResult(_object(response.data));
  }

  static List<Map<String, dynamic>> _rows(Object? data) {
    final value = data is Map
        ? data['results'] ?? data['data'] ?? data['items'] ?? const []
        : data;
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  static Map<String, dynamic> _object(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('Expected a JSON object from the API.');
  }

  static BusinessEntry _entryFromJson(Map<String, dynamic> json, EntryType type) {
    final party = json['customer'] ?? json['supplier'] ?? json['party'];
    final partyName = party is Map ? party['name'] : json['party_name'];
    return BusinessEntry(
      id: json['id'].toString(),
      type: type,
      reference: (json['invoice_number'] ?? json['reference'] ?? json['number'] ??
              '#${json['id'].toString().substring(0, 8)}')
          .toString(),
      partyName: (partyName ?? 'Walk-in').toString(),
      totalMinor: minorFromRecord(
        json,
        type == EntryType.expense
            ? 'total_minor'
            : type == EntryType.payment
                ? 'amount_minor'
                : 'grand_total_minor',
        type == EntryType.expense ? 'total' : type == EntryType.payment ? 'amount' : 'grand_total',
      ),
      pendingMinor: minorFromRecord(json, 'due_total_minor', 'due_amount'),
      occurredAt: DateTime.tryParse(
            (json['occurred_at'] ?? json['invoice_date'] ?? json['created_at'] ?? '')
                .toString(),
          ) ??
          DateTime.now(),
      reversed: json['status'] == 'REVERSED' || json['is_reversed'] == true,
    );
  }

  static AssistantProposal _proposalFromJson(Map<String, dynamic> json) {
    final preview = json['preview'] is Map
        ? Map<String, dynamic>.from(json['preview'] as Map)
        : <String, dynamic>{};
    final facts = <ReviewFact>[];
    final rawFacts = preview['facts'] ?? preview['fields'];
    if (rawFacts is List) {
      for (final fact in rawFacts.whereType<Map>()) {
        facts.add(
          ReviewFact(
            (fact['label'] ?? fact['name'] ?? '').toString(),
            (fact['value'] ?? '').toString(),
            warning: fact['warning'] == true,
          ),
        );
      }
    } else {
      for (final entry in preview.entries) {
        if (const {'title', 'summary', 'facts', 'fields'}.contains(entry.key)) continue;
        if (entry.value is String || entry.value is num || entry.value is bool) {
          facts.add(ReviewFact(_humanize(entry.key), entry.value.toString()));
        }
      }
    }
    return AssistantProposal(
      id: json['id'].toString(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      commandType: (json['command_type'] ?? 'ENTRY').toString(),
      title: (preview['title'] ?? preview['summary'] ?? 'Proposed entry').toString(),
      facts: facts,
      warnings: _strings(json['warnings']),
      blockingQuestions: _strings(json['blocking_questions']),
      rawPayload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : const {},
    );
  }

  static List<String> _strings(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList(growable: false);
  }

  static String _humanize(String key) {
    final spaced = key.replaceAll('_', ' ');
    return spaced.isEmpty ? spaced : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  static PostedResult _postedResult(Map<String, dynamic> json) {
    final result = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;
    return PostedResult(
      id: (result['id'] ?? result['transaction_id'] ?? '').toString(),
      reference:
          (result['invoice_number'] ?? result['reference'] ?? result['id'] ?? 'Saved')
              .toString(),
      message: (json['message'] ?? 'Entry recorded').toString(),
    );
  }
}

class DemoDukaanRepository implements DukaanRepository {
  DemoDukaanRepository()
      : _entries = [
          BusinessEntry(
            id: 'sale-1042',
            type: EntryType.sale,
            reference: 'INV-1042',
            partyName: 'Ramesh Kumar',
            totalMinor: 240000,
            pendingMinor: 90000,
            occurredAt: DateTime.now().subtract(const Duration(minutes: 24)),
          ),
          BusinessEntry(
            id: 'sale-1041',
            type: EntryType.sale,
            reference: 'INV-1041',
            partyName: 'Walk-in',
            totalMinor: 76000,
            pendingMinor: 0,
            occurredAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          BusinessEntry(
            id: 'expense-88',
            type: EntryType.expense,
            reference: 'EXP-0088',
            partyName: 'Shop electricity',
            totalMinor: 125000,
            pendingMinor: 0,
            occurredAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ];

  static const _uuid = Uuid();
  final List<BusinessEntry> _entries;

  static const locations = [
    BusinessLocation(
      id: 'loc-main',
      businessId: 'business-demo',
      name: 'Main Market',
      isPrimary: true,
    ),
    BusinessLocation(
      id: 'loc-godown',
      businessId: 'business-demo',
      name: 'Godown',
    ),
  ];

  static final products = [
    Product(
      id: 'product-shirt-blue',
      packId: 'pack-shirt-blue',
      name: 'Blue cotton shirt',
      sku: 'SH-BLU-40',
      unit: 'pcs',
      stock: Decimal.parse('18'),
      lowStockAt: Decimal.parse('5'),
      retailPriceMinor: 80000,
      wholesalePriceMinor: 68000,
    ),
    Product(
      id: 'product-rice',
      packId: 'pack-rice-5kg',
      name: 'Basmati rice 5 kg',
      sku: 'RICE-BAS-5',
      unit: 'bags',
      stock: Decimal.parse('4'),
      lowStockAt: Decimal.parse('8'),
      retailPriceMinor: 72000,
      wholesalePriceMinor: 65000,
    ),
    Product(
      id: 'product-oil',
      packId: 'pack-oil-1l',
      name: 'Mustard oil 1 L',
      sku: 'OIL-MUS-1',
      unit: 'bottles',
      stock: Decimal.parse('31'),
      lowStockAt: Decimal.parse('10'),
      retailPriceMinor: 18500,
      wholesalePriceMinor: 16900,
    ),
  ];

  static final parties = [
    Party(
      id: 'party-ramesh',
      name: 'Ramesh Kumar',
      phone: '+91 98765 43210',
      kind: PartyKind.customer,
      toReceiveMinor: 328000,
      toPayMinor: 0,
    ),
    Party(
      id: 'party-sharma',
      name: 'Sharma Distributors',
      phone: '+91 98111 22334',
      kind: PartyKind.supplier,
      toReceiveMinor: 0,
      toPayMinor: 1240000,
    ),
    Party(
      id: 'party-neha',
      name: 'Neha Stores',
      phone: '+91 98990 11223',
      kind: PartyKind.both,
      toReceiveMinor: 110000,
      toPayMinor: 46000,
    ),
  ];

  Future<T> _pause<T>(T value) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return value;
  }

  @override
  Future<List<BusinessLocation>> fetchLocations() => _pause(locations);

  @override
  Future<DashboardSummary> fetchDashboard(String locationId) {
    return _pause(
      DashboardSummary(
        salesMinor: locationId == 'loc-main' ? 1846000 : 386000,
        expensesMinor: 125000,
        toReceiveMinor: 438000,
        toPayMinor: 1286000,
        lowStockCount: products.where((product) => product.isLowStock).length,
        asOf: DateTime.now(),
        summary:
            'Sales are strongest in shirts today. Basmati rice is below its minimum stock level, and ₹900 from Ramesh remains pending.',
      ),
    );
  }

  @override
  Future<List<BusinessEntry>> fetchEntries(String locationId) =>
      _pause(List.unmodifiable(_entries));

  @override
  Future<List<Party>> fetchParties(String locationId) => _pause(parties);

  @override
  Future<List<Product>> fetchProducts(String locationId) => _pause(products);

  @override
  Future<AssistantProposal> interpret({
    required AssistantInput input,
    required String locationId,
    required String locale,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final isTooShort = input.type != AssistantInputType.image && input.content.trim().length < 6;
    return AssistantProposal(
      id: _uuid.v4(),
      version: 1,
      commandType: input.type == AssistantInputType.image ? 'PURCHASE' : 'SALE',
      title: input.type == AssistantInputType.image
          ? 'Purchase from scanned bill'
          : 'Sale to Ramesh Kumar',
      facts: input.type == AssistantInputType.image
          ? const [
              ReviewFact('Source', 'Uploaded bill'),
              ReviewFact('Total', '₹1,850'),
              ReviewFact('Stock effect', '+12 units'),
            ]
          : const [
              ReviewFact('Items', '3 × Blue cotton shirt'),
              ReviewFact('Total', '₹2,400'),
              ReviewFact('Paid externally', '₹1,500'),
              ReviewFact('You will receive', '₹900'),
              ReviewFact('Stock effect', '−3 at Main Market'),
            ],
      warnings: const ['Check the product match and GST before recording.'],
      blockingQuestions: isTooShort ? const ['What product and quantity should be recorded?'] : const [],
      rawPayload: {'input': input.toJson(), 'location_id': locationId},
    );
  }

  @override
  Future<AssistantProposal> refreshProposal(AssistantProposal proposal) async => proposal;

  @override
  Future<PostedResult> confirmProposal(AssistantProposal proposal) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final id = _uuid.v4();
    _entries.insert(
      0,
      BusinessEntry(
        id: id,
        type: proposal.commandType == 'PURCHASE' ? EntryType.purchase : EntryType.sale,
        reference: 'DEMO-${1000 + _entries.length}',
        partyName: proposal.commandType == 'PURCHASE' ? 'Scanned supplier' : 'Ramesh Kumar',
        totalMinor: proposal.commandType == 'PURCHASE' ? 185000 : 240000,
        pendingMinor: proposal.commandType == 'PURCHASE' ? 0 : 90000,
        occurredAt: DateTime.now(),
      ),
    );
    return PostedResult(id: id, reference: 'DEMO-${1000 + _entries.length}', message: 'Saved');
  }

  @override
  Future<PostedResult> createSale(SaleDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final id = _uuid.v4();
    final reference = 'DEMO-${1000 + _entries.length}';
    _entries.insert(
      0,
      BusinessEntry(
        id: id,
        type: EntryType.sale,
        reference: reference,
        partyName: draft.customerName ?? 'Walk-in',
        totalMinor: draft.totalMinor,
        pendingMinor: draft.pendingMinor,
        occurredAt: DateTime.now(),
      ),
    );
    return PostedResult(id: id, reference: reference, message: 'Sale recorded');
  }
}

bool get isDemoRepositoryEnabled => AppConfig.demoMode;
