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

  // Common: current user + bootstrap.
  Future<Map<String, dynamic>> fetchMe();
  Future<Map<String, dynamic>> fetchBootstrap({String? businessId});

  // Tenancy.
  Future<List<Business>> listBusinesses();
  Future<Business> createBusiness(Map<String, dynamic> payload);
  Future<Business> fetchBusiness(String id);
  Future<List<BusinessLocation>> listLocations({String? businessId});
  Future<BusinessLocation> createLocation(Map<String, dynamic> payload);
  Future<BusinessLocation> updateLocation(String id, Map<String, dynamic> payload);
  Future<void> deleteLocation(String id);
  Future<List<GstRegistration>> listGst({String? businessId});
  Future<GstRegistration> createGst(Map<String, dynamic> payload);
  Future<GstRegistration> updateGst(String id, Map<String, dynamic> payload);
  Future<List<Membership>> listMemberships({String? businessId});
  Future<Membership> createMembership(Map<String, dynamic> payload);
  Future<Membership> updateMembership(String id, Map<String, dynamic> payload);
  Future<void> deleteMembership(String id);
  Future<Membership> revokeMembership(String id);
  Future<List<Invitation>> listInvitations({String? businessId});
  Future<Map<String, dynamic>> createInvitation(Map<String, dynamic> payload);
  Future<void> revokeInvitation(String id);
  Future<Membership> acceptInvitation({required String id, required String token});
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> fetchNotificationPrefs({String? businessId});
  Future<Map<String, dynamic>> updateNotificationPrefs(Map<String, dynamic> payload);

  // Phase 3: activity, reminders, async exports, invoice PDFs.
  Future<Map<String, dynamic>> fetchActivity({
    String? businessId,
    String kind = 'all',
    int limit = 50,
    int offset = 0,
  });
  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> fetchReminderSuggestions({String? businessId});
  Future<Map<String, dynamic>> createExport(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> fetchExport(String id);
  Future<Map<String, dynamic>> createSaleInvoice(String saleId);
  Future<Map<String, dynamic>> fetchAttachment(String id);
  Future<List<int>> downloadBytes(String path);

  // Catalog detail + write.
  Future<Product> fetchProduct(String id);
  Future<Product> createProduct(Map<String, dynamic> payload);
  Future<Product> updateProduct(String id, Map<String, dynamic> payload);
  Future<void> deleteProduct(String id);
  Future<Party> fetchParty(String id);
  Future<Party> createParty(Map<String, dynamic> payload);
  Future<Party> updateParty(String id, Map<String, dynamic> payload);
  Future<void> deleteParty(String id);

  // Operations detail.
  Future<Map<String, dynamic>> fetchSale(String id);
  Future<Map<String, dynamic>> fetchPurchase(String id);
  Future<Map<String, dynamic>> fetchPayment(String id);
  Future<Map<String, dynamic>> fetchExpense(String id);
  Future<Map<String, dynamic>> fetchTransfer(String id);

  // Operations writes (payloads already carry business_id/location_id;
  // idempotency_key is injected when absent).
  Future<PostedResult> createPurchase(Map<String, dynamic> payload);
  Future<PostedResult> createPayment(Map<String, dynamic> payload);
  Future<PostedResult> createExpense(Map<String, dynamic> payload);
  Future<PostedResult> createTransfer(Map<String, dynamic> payload);

  // Operations reversals.
  Future<Map<String, dynamic>> reverseSale({
    required String id,
    required String reason,
    String? idempotencyKey,
  });
  Future<Map<String, dynamic>> reversePurchase({
    required String id,
    required String reason,
    String? idempotencyKey,
  });
  Future<Map<String, dynamic>> reversePayment({
    required String id,
    required String reason,
    String? idempotencyKey,
  });
  Future<Map<String, dynamic>> reverseExpense({
    required String id,
    required String reason,
    String? idempotencyKey,
  });
  Future<Map<String, dynamic>> reverseTransfer({
    required String id,
    required String reason,
    String? idempotencyKey,
  });

  // Stock + ledger.
  Future<Map<String, dynamic>> adjustStock(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> postOpeningBalance(Map<String, dynamic> payload);
  Future<List<StockRow>> fetchStockReport({
    required String businessId,
    String? locationId,
  });
  Future<LedgerReport> fetchPartyLedger({
    required String businessId,
    required String partyId,
    String? account,
  });
  Future<DocumentReport> fetchDocumentReport({
    required String kind,
    required String locationId,
    String groupBy = 'day',
    DateTime? from,
    DateTime? to,
  });
  Future<List<StockMovement>> fetchStockMovements({
    required String locationId,
    String? productId,
  });

  // Assistant proposals.
  Future<List<ProposalSummary>> listProposals();
  Future<Map<String, dynamic>> fetchProposal(String id);
  Future<List<ProposalRevision>> fetchRevisions(String id);
  Future<Map<String, dynamic>> cancelProposal({
    required String id,
    required int version,
  });
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

  @override
  Future<Map<String, dynamic>> fetchMe() async {
    final response = await _dio.get<Object>('me/');
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchBootstrap({String? businessId}) async {
    final response = await _dio.get<Object>(
      'bootstrap/',
      queryParameters: {if (businessId != null) 'business_id': businessId},
    );
    return _object(response.data);
  }

  @override
  Future<List<Business>> listBusinesses() async {
    final response = await _dio.get<Object>('businesses/');
    return _rows(response.data).map(Business.fromJson).toList(growable: false);
  }

  @override
  Future<Business> createBusiness(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>('businesses/', data: payload);
    return Business.fromJson(_object(response.data));
  }

  @override
  Future<Business> fetchBusiness(String id) async {
    final response = await _dio.get<Object>('businesses/$id/');
    return Business.fromJson(_object(response.data));
  }

  @override
  Future<List<BusinessLocation>> listLocations({String? businessId}) async {
    final resolved = businessId ?? await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'locations/',
      queryParameters: {'business_id': resolved},
    );
    return _rows(response.data)
        .map((row) => BusinessLocation.fromJson({...row, 'business_id': resolved}))
        .toList(growable: false);
  }

  @override
  Future<BusinessLocation> createLocation(Map<String, dynamic> payload) async {
    final businessId = payload['business']?.toString() ?? await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'locations/',
      data: {...payload, 'business': businessId},
    );
    return BusinessLocation.fromJson({..._object(response.data), 'business_id': businessId});
  }

  @override
  Future<BusinessLocation> updateLocation(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Object>('locations/$id/', data: payload);
    final row = _object(response.data);
    return BusinessLocation.fromJson({
      ...row,
      'business_id': row['business_id'] ?? row['business'] ?? await _resolveBusinessId(),
    });
  }

  @override
  Future<void> deleteLocation(String id) async {
    await _dio.delete<Object>('locations/$id/');
  }

  @override
  Future<List<GstRegistration>> listGst({String? businessId}) async {
    final resolved = businessId ?? await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'gst-registrations/',
      queryParameters: {'business_id': resolved},
    );
    return _rows(response.data).map(GstRegistration.fromJson).toList(growable: false);
  }

  @override
  Future<GstRegistration> createGst(Map<String, dynamic> payload) async {
    final businessId = payload['business']?.toString() ?? await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'gst-registrations/',
      data: {...payload, 'business': businessId},
    );
    return GstRegistration.fromJson(_object(response.data));
  }

  @override
  Future<GstRegistration> updateGst(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Object>('gst-registrations/$id/', data: payload);
    return GstRegistration.fromJson(_object(response.data));
  }

  @override
  Future<List<Membership>> listMemberships({String? businessId}) async {
    final resolved = businessId ?? await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'memberships/',
      queryParameters: {'business_id': resolved},
    );
    return _rows(response.data).map(Membership.fromJson).toList(growable: false);
  }

  @override
  Future<Membership> createMembership(Map<String, dynamic> payload) async {
    final businessId = payload['business']?.toString() ?? await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'memberships/',
      data: {...payload, 'business': businessId},
    );
    return Membership.fromJson(_object(response.data));
  }

  @override
  Future<Membership> updateMembership(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Object>('memberships/$id/', data: payload);
    return Membership.fromJson(_object(response.data));
  }

  @override
  Future<void> deleteMembership(String id) async {
    await _dio.delete<Object>('memberships/$id/');
  }

  @override
  Future<Membership> revokeMembership(String id) async {
    final response = await _dio.post<Object>('memberships/$id/revoke/');
    return Membership.fromJson(_object(response.data));
  }

  @override
  Future<List<Invitation>> listInvitations({String? businessId}) async {
    final resolved = businessId ?? await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'invitations/',
      queryParameters: {'business_id': resolved, 'status': 'PENDING'},
    );
    return _rows(response.data).map(Invitation.fromJson).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> createInvitation(Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(payload);
    data['business'] ??= await _resolveBusinessId();
    final response = await _dio.post<Object>('invitations/', data: data);
    return _object(response.data);
  }

  @override
  Future<void> revokeInvitation(String id) async {
    await _dio.post<Object>('invitations/$id/revoke/');
  }

  @override
  Future<Membership> acceptInvitation({required String id, required String token}) async {
    final response = await _dio.post<Object>(
      'invitations/$id/accept/',
      data: {'token': token},
    );
    return Membership.fromJson(_object(response.data));
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    final response = await _dio.patch<Object>('me/', data: payload);
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchNotificationPrefs({String? businessId}) async {
    final resolved = businessId ?? await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'notification-preferences/',
      queryParameters: {'business_id': resolved},
    );
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateNotificationPrefs(Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(payload);
    data['business_id'] ??= await _resolveBusinessId();
    final response = await _dio.patch<Object>('notification-preferences/', data: data);
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchActivity({
    String? businessId,
    String kind = 'all',
    int limit = 50,
    int offset = 0,
  }) async {
    final resolved = businessId ?? await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'activity/',
      queryParameters: {
        'business_id': resolved,
        'kind': kind,
        'limit': limit,
        'offset': offset,
      },
    );
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(payload);
    data['business_id'] ??= await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'reminders/',
      data: _withIdempotency(data),
    );
    return _object(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReminderSuggestions({String? businessId}) async {
    final resolved = businessId ?? await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'reminders/suggestions/',
      queryParameters: {'business_id': resolved},
    );
    final rows = _object(response.data)['results'];
    if (rows is List) {
      return rows.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
    }
    return const [];
  }

  @override
  Future<Map<String, dynamic>> createExport(Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(payload);
    data['business_id'] ??= await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'exports/',
      data: _withIdempotency(data),
    );
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchExport(String id) async {
    final response = await _dio.get<Object>('exports/$id/');
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> createSaleInvoice(String saleId) async {
    final response = await _dio.post<Object>('sales/$saleId/invoice/');
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchAttachment(String id) async {
    final response = await _dio.get<Object>('attachments/$id/');
    return _object(response.data);
  }

  @override
  Future<List<int>> downloadBytes(String path) async {
    final response = await _dio.get<List<int>>(
      path,
      queryParameters: {'download': '1'},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

  @override
  Future<Product> fetchProduct(String id) async {
    final response = await _dio.get<Object>('products/$id/');
    return Product.fromJson(_object(response.data));
  }

  @override
  Future<Product> createProduct(Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(payload);
    data['business'] ??= await _resolveBusinessId();
    final response = await _dio.post<Object>('products/', data: data);
    return Product.fromJson(_object(response.data));
  }

  @override
  Future<Product> updateProduct(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Object>('products/$id/', data: payload);
    return Product.fromJson(_object(response.data));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _dio.delete<Object>('products/$id/');
  }

  @override
  Future<Party> fetchParty(String id) async {
    final response = await _dio.get<Object>('parties/$id/');
    return Party.fromJson(_object(response.data));
  }

  @override
  Future<Party> createParty(Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(payload);
    data['business'] ??= await _resolveBusinessId();
    final response = await _dio.post<Object>('parties/', data: data);
    return Party.fromJson(_object(response.data));
  }

  @override
  Future<Party> updateParty(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Object>('parties/$id/', data: payload);
    return Party.fromJson(_object(response.data));
  }

  @override
  Future<void> deleteParty(String id) async {
    await _dio.delete<Object>('parties/$id/');
  }

  @override
  Future<Map<String, dynamic>> fetchSale(String id) async {
    final response = await _dio.get<Object>('sales/$id/');
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchPurchase(String id) async {
    final response = await _dio.get<Object>('purchases/$id/');
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchPayment(String id) async {
    final response = await _dio.get<Object>('payments/$id/');
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchExpense(String id) async {
    final response = await _dio.get<Object>('expenses/$id/');
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchTransfer(String id) async {
    final response = await _dio.get<Object>('transfers/$id/');
    return _object(response.data);
  }

  @override
  Future<PostedResult> createPurchase(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>(
      'purchases/',
      data: _withIdempotency(payload),
    );
    return _postedResult(_object(response.data));
  }

  @override
  Future<PostedResult> createPayment(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>(
      'payments/',
      data: _withIdempotency(payload),
    );
    return _postedResult(_object(response.data));
  }

  @override
  Future<PostedResult> createExpense(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>(
      'expenses/',
      data: _withIdempotency(payload),
    );
    return _postedResult(_object(response.data));
  }

  @override
  Future<PostedResult> createTransfer(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>(
      'transfers/',
      data: _withIdempotency(payload),
    );
    return _postedResult(_object(response.data));
  }

  @override
  Future<Map<String, dynamic>> reverseSale({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async {
    return _reverse('sales', id, reason, idempotencyKey);
  }

  @override
  Future<Map<String, dynamic>> reversePurchase({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async {
    return _reverse('purchases', id, reason, idempotencyKey);
  }

  @override
  Future<Map<String, dynamic>> reversePayment({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async {
    return _reverse('payments', id, reason, idempotencyKey);
  }

  @override
  Future<Map<String, dynamic>> reverseExpense({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async {
    return _reverse('expenses', id, reason, idempotencyKey);
  }

  @override
  Future<Map<String, dynamic>> reverseTransfer({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async {
    return _reverse('transfers', id, reason, idempotencyKey);
  }

  @override
  Future<Map<String, dynamic>> adjustStock(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>(
      'stock/adjustments/',
      data: _withIdempotency(payload),
    );
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> postOpeningBalance(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>(
      'party-ledger/opening-balances/',
      data: _withIdempotency(payload),
    );
    return _object(response.data);
  }

  @override
  Future<List<StockRow>> fetchStockReport({
    required String businessId,
    String? locationId,
  }) async {
    final response = await _dio.get<Object>(
      'reports/stock/',
      queryParameters: {
        'business_id': businessId,
        if (locationId != null) 'location_id': locationId,
      },
    );
    return _rows(response.data).map(StockRow.fromJson).toList(growable: false);
  }

  @override
  Future<LedgerReport> fetchPartyLedger({
    required String businessId,
    required String partyId,
    String? account,
  }) async {
    final response = await _dio.get<Object>(
      'reports/party-ledger/',
      queryParameters: {
        'business_id': businessId,
        'party_id': partyId,
        if (account != null) 'account': account,
      },
    );
    return LedgerReport.fromJson(_object(response.data));
  }

  static String _dateParam(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Future<DocumentReport> fetchDocumentReport({
    required String kind,
    required String locationId,
    String groupBy = 'day',
    DateTime? from,
    DateTime? to,
  }) async {
    final businessId = await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'reports/$kind/',
      queryParameters: {
        'business_id': businessId,
        'location_id': locationId,
        'group_by': groupBy,
        if (from != null) 'from': _dateParam(from),
        if (to != null) 'to': _dateParam(to),
      },
    );
    return DocumentReport.fromJson(_object(response.data));
  }

  @override
  Future<List<StockMovement>> fetchStockMovements({
    required String locationId,
    String? productId,
  }) async {
    final businessId = await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'stock/movements/',
      queryParameters: {
        'business_id': businessId,
        'location_id': locationId,
        if (productId != null) 'product_id': productId,
      },
    );
    return _rows(response.data).map(StockMovement.fromJson).toList(growable: false);
  }

  @override
  Future<List<ProposalSummary>> listProposals() async {
    final response = await _dio.get<Object>('assistant/proposals/');
    return _rows(response.data).map(ProposalSummary.fromJson).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> fetchProposal(String id) async {
    final response = await _dio.get<Object>('assistant/proposals/$id/');
    return _object(response.data);
  }

  @override
  Future<List<ProposalRevision>> fetchRevisions(String id) async {
    final response = await _dio.get<Object>('assistant/proposals/$id/revisions/');
    return _rows(response.data).map(ProposalRevision.fromJson).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> cancelProposal({
    required String id,
    required int version,
  }) async {
    final response = await _dio.post<Object>(
      'assistant/proposals/$id/cancel/',
      data: {'version': version},
    );
    return _object(response.data);
  }

  Future<Map<String, dynamic>> _reverse(
    String resource,
    String id,
    String reason,
    String? idempotencyKey,
  ) async {
    final response = await _dio.post<Object>(
      '$resource/$id/reverse/',
      data: {
        'reason': reason,
        'idempotency_key': idempotencyKey ?? const Uuid().v4(),
      },
    );
    return _object(response.data);
  }

  static Map<String, dynamic> _withIdempotency(Map<String, dynamic> payload) {
    final data = Map<String, dynamic>.from(payload);
    data['idempotency_key'] ??= const Uuid().v4();
    return data;
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
    final partyName = party is Map
        ? party['name']
        : json['customer_name'] ?? json['supplier_name'] ?? json['party_name'];
    final partyId = party is String && party.isNotEmpty
        ? party
        : party is Map && party['id'] != null
            ? party['id'].toString()
            : null;
    final reference = [json['invoice_number'], json['reference'], json['number']]
        .map((value) => value?.toString() ?? '')
        .firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => '#${json['id'].toString().substring(0, 8)}',
        );
    return BusinessEntry(
      id: json['id'].toString(),
      type: type,
      reference: reference,
      partyName: (partyName ?? 'Walk-in').toString(),
      partyId: partyId,
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
    final previewSource = json['preview_data'] ?? json['preview'];
    final preview = previewSource is Map
        ? Map<String, dynamic>.from(previewSource)
        : <String, dynamic>{};
    final previewText = json['preview'] is String ? json['preview'] as String : '';
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
      title: (preview['title'] ??
              preview['summary'] ??
              (previewText.isNotEmpty ? previewText : 'Proposed entry'))
          .toString(),
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
          (result['invoice_number'] ?? result['reference'] ?? result['number'] ?? result['id'] ??
                  'Saved')
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

  @override
  Future<Map<String, dynamic>> fetchMe() => _pause(const {
        'id': 'user-demo',
        'phone': '+919876543210',
        'display_name': 'Demo User',
      });

  @override
  Future<Map<String, dynamic>> fetchBootstrap({String? businessId}) => _pause({
        'user': {
          'id': 'user-demo',
          'name': 'Demo User',
          'phone': '+919876543210',
          'role': 'OWNER',
        },
        'business': {
          'id': businessId ?? 'business-demo',
          'name': 'Demo Business',
          'currency': 'INR',
          'timezone': 'Asia/Kolkata',
        },
        'locations': [
          {'id': 'loc-main', 'name': 'Main Market', 'code': 'MAIN'},
          {'id': 'loc-godown', 'name': 'Godown', 'code': 'GODOWN'},
        ],
        'permissions': ['*'],
      });

  @override
  Future<List<Business>> listBusinesses() => _pause(const [
        Business(id: 'business-demo', name: 'Demo Business', role: 'OWNER'),
      ]);

  @override
  Future<Business> createBusiness(Map<String, dynamic> payload) => _pause(
        Business(id: _uuid.v4(), name: (payload['name'] ?? 'Business').toString()),
      );

  @override
  Future<Business> fetchBusiness(String id) => _pause(
        Business(id: id, name: 'Demo Business', role: 'OWNER'),
      );

  @override
  Future<List<BusinessLocation>> listLocations({String? businessId}) =>
      _pause(locations);

  @override
  Future<BusinessLocation> createLocation(Map<String, dynamic> payload) => _pause(
        BusinessLocation(
          id: _uuid.v4(),
          businessId: (payload['business'] ?? 'business-demo').toString(),
          name: (payload['name'] ?? 'Location').toString(),
        ),
      );

  @override
  Future<BusinessLocation> updateLocation(String id, Map<String, dynamic> payload) =>
      _pause(
        BusinessLocation(
          id: id,
          businessId: 'business-demo',
          name: (payload['name'] ?? 'Main Market').toString(),
        ),
      );

  @override
  Future<void> deleteLocation(String id) => _pause(null);

  @override
  Future<List<GstRegistration>> listGst({String? businessId}) => _pause(const []);

  @override
  Future<GstRegistration> createGst(Map<String, dynamic> payload) => _pause(
        GstRegistration(
          id: _uuid.v4(),
          businessId: (payload['business'] ?? 'business-demo').toString(),
          gstin: (payload['gstin'] ?? '').toString(),
        ),
      );

  @override
  Future<GstRegistration> updateGst(String id, Map<String, dynamic> payload) => _pause(
        GstRegistration(
          id: id,
          businessId: 'business-demo',
          gstin: (payload['gstin'] ?? '').toString(),
        ),
      );

  @override
  Future<List<Membership>> listMemberships({String? businessId}) => _pause(const [
        Membership(id: 'membership-demo', businessId: 'business-demo', role: 'OWNER'),
      ]);

  @override
  Future<Membership> createMembership(Map<String, dynamic> payload) => _pause(
        Membership(
          id: _uuid.v4(),
          businessId: (payload['business'] ?? 'business-demo').toString(),
          role: (payload['role'] ?? 'CASHIER').toString(),
        ),
      );

  @override
  Future<Membership> updateMembership(String id, Map<String, dynamic> payload) => _pause(
        Membership(
          id: id,
          businessId: 'business-demo',
          role: (payload['role'] ?? 'CASHIER').toString(),
        ),
      );

  @override
  Future<void> deleteMembership(String id) => _pause(null);

  @override
  Future<Membership> revokeMembership(String id) => _pause(
        const Membership(id: 'membership-demo', businessId: 'business-demo', role: 'OWNER'),
      );

  @override
  Future<List<Invitation>> listInvitations({String? businessId}) => _pause(const []);

  @override
  Future<Map<String, dynamic>> createInvitation(Map<String, dynamic> payload) => _pause(
        {'id': 'invitation-demo', 'token': 'demo-token'},
      );

  @override
  Future<void> revokeInvitation(String id) => _pause(null);

  @override
  Future<Membership> acceptInvitation({required String id, required String token}) => _pause(
        const Membership(id: 'membership-demo', businessId: 'business-demo', role: 'CASHIER'),
      );

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) => _pause(
        {'id': 'user-demo'},
      );

  @override
  Future<Map<String, dynamic>> fetchNotificationPrefs({String? businessId}) => _pause(
        {
          'push_enabled': true,
          'sms_enabled': true,
          'whatsapp_enabled': false,
          'daily_summary': true,
          'low_stock_alerts': true,
          'due_reminders': true,
        },
      );

  @override
  Future<Map<String, dynamic>> updateNotificationPrefs(Map<String, dynamic> payload) => _pause(
        {'business': 'business-demo'},
      );

  @override
  Future<Map<String, dynamic>> fetchActivity({
    String? businessId,
    String kind = 'all',
    int limit = 50,
    int offset = 0,
  }) =>
      _pause({'results': [], 'count': 0});

  @override
  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> payload) => _pause(
        {'id': 'reminder-demo', 'status': 'SENT', 'message': 'demo'},
      );

  @override
  Future<List<Map<String, dynamic>>> fetchReminderSuggestions({String? businessId}) =>
      _pause(const []);

  @override
  Future<Map<String, dynamic>> createExport(Map<String, dynamic> payload) => _pause(
        {'id': 'export-demo', 'status': 'READY'},
      );

  @override
  Future<Map<String, dynamic>> fetchExport(String id) => _pause(
        {'id': id, 'status': 'READY'},
      );

  @override
  Future<Map<String, dynamic>> createSaleInvoice(String saleId) => _pause(
        {'id': 'attachment-demo', 'status': 'READY'},
      );

  @override
  Future<Map<String, dynamic>> fetchAttachment(String id) => _pause(
        {'id': id, 'status': 'READY'},
      );

  @override
  Future<List<int>> downloadBytes(String path) => _pause(const []);

  @override
  Future<Product> fetchProduct(String id) =>
      _pause(products.firstWhere((product) => product.id == id, orElse: () => products.first));

  @override
  Future<Product> createProduct(Map<String, dynamic> payload) => _pause(
        Product(
          id: _uuid.v4(),
          packId: _uuid.v4(),
          name: (payload['name'] ?? 'Product').toString(),
          sku: (payload['sku'] ?? '').toString(),
          unit: (payload['base_unit'] ?? 'pcs').toString(),
          stock: Decimal.parse('0'),
          lowStockAt: Decimal.parse('0'),
          retailPriceMinor: 0,
          wholesalePriceMinor: 0,
        ),
      );

  @override
  Future<Product> updateProduct(String id, Map<String, dynamic> payload) =>
      fetchProduct(id);

  @override
  Future<void> deleteProduct(String id) => _pause(null);

  @override
  Future<Party> fetchParty(String id) =>
      _pause(parties.firstWhere((party) => party.id == id, orElse: () => parties.first));

  @override
  Future<Party> createParty(Map<String, dynamic> payload) => _pause(
        Party(
          id: _uuid.v4(),
          name: (payload['name'] ?? 'Party').toString(),
          phone: (payload['phone_e164'] ?? '').toString(),
          kind: PartyKind.customer,
          toReceiveMinor: 0,
          toPayMinor: 0,
        ),
      );

  @override
  Future<Party> updateParty(String id, Map<String, dynamic> payload) => fetchParty(id);

  @override
  Future<void> deleteParty(String id) => _pause(null);

  @override
  Future<Map<String, dynamic>> fetchSale(String id) => _pause({'id': id});

  @override
  Future<Map<String, dynamic>> fetchPurchase(String id) => _pause({'id': id});

  @override
  Future<Map<String, dynamic>> fetchPayment(String id) => _pause({'id': id});

  @override
  Future<Map<String, dynamic>> fetchExpense(String id) => _pause({'id': id});

  @override
  Future<Map<String, dynamic>> fetchTransfer(String id) => _pause({'id': id});

  Future<PostedResult> _demoPost(String prefix) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final id = _uuid.v4();
    return PostedResult(id: id, reference: '$prefix-${1000 + _entries.length}', message: 'Saved');
  }

  @override
  Future<PostedResult> createPurchase(Map<String, dynamic> payload) =>
      _demoPost('DEMO-PUR');

  @override
  Future<PostedResult> createPayment(Map<String, dynamic> payload) =>
      _demoPost('DEMO-PAY');

  @override
  Future<PostedResult> createExpense(Map<String, dynamic> payload) =>
      _demoPost('DEMO-EXP');

  @override
  Future<PostedResult> createTransfer(Map<String, dynamic> payload) =>
      _demoPost('DEMO-TRF');

  @override
  Future<Map<String, dynamic>> reverseSale({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) =>
      _pause({'id': id, 'status': 'REVERSED'});

  @override
  Future<Map<String, dynamic>> reversePurchase({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) =>
      _pause({'id': id, 'status': 'REVERSED'});

  @override
  Future<Map<String, dynamic>> reversePayment({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) =>
      _pause({'id': id, 'status': 'REVERSED'});

  @override
  Future<Map<String, dynamic>> reverseExpense({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) =>
      _pause({'id': id, 'status': 'REVERSED'});

  @override
  Future<Map<String, dynamic>> reverseTransfer({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) =>
      _pause({'id': id, 'status': 'REVERSED'});

  @override
  Future<Map<String, dynamic>> adjustStock(Map<String, dynamic> payload) =>
      _pause({'id': _uuid.v4()});

  @override
  Future<Map<String, dynamic>> postOpeningBalance(Map<String, dynamic> payload) =>
      _pause({'id': _uuid.v4()});

  @override
  Future<List<StockRow>> fetchStockReport({
    required String businessId,
    String? locationId,
  }) =>
      _pause(
        products
            .map(
              (product) => StockRow(
                productId: product.id,
                name: product.name,
                unit: product.unit,
                quantity: product.stock,
                lowStockThreshold: product.lowStockAt,
                isLowStock: product.isLowStock,
              ),
            )
            .toList(growable: false),
      );

  @override
  Future<LedgerReport> fetchPartyLedger({
    required String businessId,
    required String partyId,
    String? account,
  }) =>
      _pause(LedgerReport(partyId: partyId, balanceMinor: 0, entries: const []));

  @override
  Future<DocumentReport> fetchDocumentReport({
    required String kind,
    required String locationId,
    String groupBy = 'day',
    DateTime? from,
    DateTime? to,
  }) {
    final type = kind == 'purchases' ? EntryType.purchase : EntryType.sale;
    final rows = _entries
        .where((entry) => entry.type == type)
        .map(
          (entry) => ReportRow(
            key: entry.id,
            label: groupBy == 'party'
                ? entry.partyName
                : entry.occurredAt.toIso8601String().substring(0, 10),
            count: 1,
            taxableMinor: entry.totalMinor,
            taxMinor: 0,
            grandTotalMinor: entry.totalMinor,
            paidMinor: entry.totalMinor - entry.pendingMinor,
            dueMinor: entry.pendingMinor,
          ),
        )
        .toList(growable: false);
    final totals = rows.fold<ReportRow>(
      const ReportRow(
        key: 'totals',
        label: 'Total',
        count: 0,
        taxableMinor: 0,
        taxMinor: 0,
        grandTotalMinor: 0,
        paidMinor: 0,
        dueMinor: 0,
      ),
      (accumulator, row) => ReportRow(
        key: 'totals',
        label: 'Total',
        count: accumulator.count + 1,
        taxableMinor: accumulator.taxableMinor + row.taxableMinor,
        taxMinor: accumulator.taxMinor + row.taxMinor,
        grandTotalMinor: accumulator.grandTotalMinor + row.grandTotalMinor,
        paidMinor: accumulator.paidMinor + row.paidMinor,
        dueMinor: accumulator.dueMinor + row.dueMinor,
      ),
    );
    return _pause(DocumentReport(groupBy: groupBy, totals: totals, rows: rows));
  }

  @override
  Future<List<StockMovement>> fetchStockMovements({
    required String locationId,
    String? productId,
  }) =>
      _pause(const []);

  @override
  Future<List<ProposalSummary>> listProposals() => _pause(const []);

  @override
  Future<Map<String, dynamic>> fetchProposal(String id) => _pause({'id': id});

  @override
  Future<List<ProposalRevision>> fetchRevisions(String id) => _pause(const []);

  @override
  Future<Map<String, dynamic>> cancelProposal({
    required String id,
    required int version,
  }) =>
      _pause({'id': id, 'version': version, 'status': 'CANCELLED'});
}

bool get isDemoRepositoryEnabled => AppConfig.demoMode;
