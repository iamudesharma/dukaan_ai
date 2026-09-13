import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';

class FakeDukaanRepository implements DukaanRepository {
  int interpretCalls = 0;
  int confirmCalls = 0;
  int saleCalls = 0;

  static const location = BusinessLocation(
    id: 'location-test',
    businessId: 'business-test',
    name: 'Test Shop',
    isPrimary: true,
  );

  static final product = Product(
    id: 'product-test',
    packId: 'pack-test',
    name: 'Test shirt',
    sku: 'TEST-1',
    unit: 'pcs',
    stock: Decimal.parse('10'),
    lowStockAt: Decimal.parse('2'),
    retailPriceMinor: 80000,
    wholesalePriceMinor: 70000,
  );

  @override
  Future<AssistantProposal> refreshProposal(AssistantProposal proposal) async => proposal;

  @override
  Future<PostedResult> confirmProposal(AssistantProposal proposal) async {
    confirmCalls++;
    return const PostedResult(id: 'sale-test', reference: 'INV-TEST', message: 'Saved');
  }

  @override
  Future<PostedResult> createSale(SaleDraft draft) async {
    saleCalls++;
    return const PostedResult(id: 'sale-test', reference: 'INV-TEST', message: 'Saved');
  }

  @override
  Future<Map<String, dynamic>> fetchMe() async => const {'id': 'user-test'};

  @override
  Future<Map<String, dynamic>> fetchBootstrap({String? businessId}) async =>
      const {'business': {'id': 'business-test'}};

  @override
  Future<List<Business>> listBusinesses() async => const [
        Business(id: 'business-test', name: 'Test Business'),
      ];

  @override
  Future<Business> createBusiness(Map<String, dynamic> payload) async =>
      const Business(id: 'business-test', name: 'Test Business');

  @override
  Future<Business> fetchBusiness(String id) async =>
      Business(id: id, name: 'Test Business');

  @override
  Future<List<BusinessLocation>> listLocations({String? businessId}) async =>
      const [location];

  @override
  Future<BusinessLocation> createLocation(Map<String, dynamic> payload) async => location;

  @override
  Future<BusinessLocation> updateLocation(String id, Map<String, dynamic> payload) async =>
      location;

  @override
  Future<void> deleteLocation(String id) async {}

  @override
  Future<List<GstRegistration>> listGst({String? businessId}) async => const [];

  @override
  Future<GstRegistration> createGst(Map<String, dynamic> payload) async =>
      const GstRegistration(id: 'gst-test', businessId: 'business-test');

  @override
  Future<GstRegistration> updateGst(String id, Map<String, dynamic> payload) async =>
      GstRegistration(id: id, businessId: 'business-test');

  @override
  Future<List<Membership>> listMemberships({String? businessId}) async => const [];

  @override
  Future<Membership> createMembership(Map<String, dynamic> payload) async =>
      const Membership(id: 'membership-test', businessId: 'business-test', role: 'OWNER');

  @override
  Future<Membership> updateMembership(String id, Map<String, dynamic> payload) async =>
      Membership(id: id, businessId: 'business-test', role: 'OWNER');

  @override
  Future<void> deleteMembership(String id) async {}

  @override
  Future<Membership> revokeMembership(String id) async =>
      const Membership(id: 'membership-test', businessId: 'business-test', role: 'OWNER');

  @override
  Future<List<Invitation>> listInvitations({String? businessId}) async => const [];

  @override
  Future<Map<String, dynamic>> createInvitation(Map<String, dynamic> payload) async =>
      {'id': 'invitation-test', 'token': 'token-test'};

  @override
  Future<void> revokeInvitation(String id) async {}

  @override
  Future<Membership> acceptInvitation({required String id, required String token}) async =>
      const Membership(id: 'membership-test', businessId: 'business-test', role: 'OWNER');

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async =>
      {'id': 'user-test'};

  @override
  Future<Map<String, dynamic>> fetchNotificationPrefs({String? businessId}) async =>
      {
        'push_enabled': true,
        'sms_enabled': true,
        'whatsapp_enabled': false,
        'daily_summary': true,
        'low_stock_alerts': true,
        'due_reminders': true,
      };

  @override
  Future<Map<String, dynamic>> updateNotificationPrefs(Map<String, dynamic> payload) async =>
      {'business': 'business-test'};

  @override
  Future<Map<String, dynamic>> fetchActivity({
    String? businessId,
    String kind = 'all',
    int limit = 50,
    int offset = 0,
  }) async =>
      {'results': [], 'count': 0};

  @override
  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> payload) async =>
      {'id': 'reminder-test', 'status': 'SENT', 'message': 'test'};

  @override
  Future<List<Map<String, dynamic>>> fetchReminderSuggestions({String? businessId}) async =>
      const [];

  @override
  Future<Map<String, dynamic>> createExport(Map<String, dynamic> payload) async =>
      {'id': 'export-test', 'status': 'READY'};

  @override
  Future<Map<String, dynamic>> fetchExport(String id) async =>
      {'id': id, 'status': 'READY'};

  @override
  Future<Map<String, dynamic>> createSaleInvoice(String saleId) async =>
      {'id': 'attachment-test', 'status': 'READY'};

  @override
  Future<Map<String, dynamic>> fetchAttachment(String id) async =>
      {'id': id, 'status': 'READY'};

  @override
  Future<List<int>> downloadBytes(String path) async => const [];

  @override
  Future<Product> fetchProduct(String id) async => product;

  @override
  Future<Product> createProduct(Map<String, dynamic> payload) async => product;

  @override
  Future<Product> updateProduct(String id, Map<String, dynamic> payload) async => product;

  @override
  Future<void> deleteProduct(String id) async {}

  @override
  Future<Party> fetchParty(String id) async => const Party(
        id: 'party-test',
        name: 'Test Party',
        phone: '',
        kind: PartyKind.customer,
        toReceiveMinor: 0,
        toPayMinor: 0,
      );

  @override
  Future<Party> createParty(Map<String, dynamic> payload) async => const Party(
        id: 'party-test',
        name: 'Test Party',
        phone: '',
        kind: PartyKind.customer,
        toReceiveMinor: 0,
        toPayMinor: 0,
      );

  @override
  Future<Party> updateParty(String id, Map<String, dynamic> payload) async => Party(
        id: id,
        name: 'Test Party',
        phone: '',
        kind: PartyKind.customer,
        toReceiveMinor: 0,
        toPayMinor: 0,
      );

  @override
  Future<void> deleteParty(String id) async {}

  @override
  Future<Map<String, dynamic>> fetchSale(String id) async => {'id': id};

  @override
  Future<Map<String, dynamic>> fetchPurchase(String id) async => {'id': id};

  @override
  Future<Map<String, dynamic>> fetchPayment(String id) async => {'id': id};

  @override
  Future<Map<String, dynamic>> fetchExpense(String id) async => {'id': id};

  @override
  Future<Map<String, dynamic>> fetchTransfer(String id) async => {'id': id};

  @override
  Future<PostedResult> createPurchase(Map<String, dynamic> payload) async =>
      const PostedResult(id: 'purchase-test', reference: 'PUR-TEST', message: 'Saved');

  @override
  Future<PostedResult> createPayment(Map<String, dynamic> payload) async =>
      const PostedResult(id: 'payment-test', reference: 'PAY-TEST', message: 'Saved');

  @override
  Future<PostedResult> createExpense(Map<String, dynamic> payload) async =>
      const PostedResult(id: 'expense-test', reference: 'EXP-TEST', message: 'Saved');

  @override
  Future<PostedResult> createTransfer(Map<String, dynamic> payload) async =>
      const PostedResult(id: 'transfer-test', reference: 'TRF-TEST', message: 'Saved');

  @override
  Future<Map<String, dynamic>> reverseSale({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async =>
      {'id': id};

  @override
  Future<Map<String, dynamic>> reversePurchase({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async =>
      {'id': id};

  @override
  Future<Map<String, dynamic>> reversePayment({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async =>
      {'id': id};

  @override
  Future<Map<String, dynamic>> reverseExpense({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async =>
      {'id': id};

  @override
  Future<Map<String, dynamic>> reverseTransfer({
    required String id,
    required String reason,
    String? idempotencyKey,
  }) async =>
      {'id': id};

  @override
  Future<Map<String, dynamic>> adjustStock(Map<String, dynamic> payload) async =>
      const {'id': 'adjustment-test'};

  @override
  Future<Map<String, dynamic>> postOpeningBalance(Map<String, dynamic> payload) async =>
      const {'id': 'opening-test'};

  @override
  Future<List<StockRow>> fetchStockReport({
    required String businessId,
    String? locationId,
  }) async =>
      const [];

  @override
  Future<LedgerReport> fetchPartyLedger({
    required String businessId,
    required String partyId,
    String? account,
  }) async =>
      LedgerReport(partyId: partyId, balanceMinor: 0, entries: const []);

  @override
  Future<DocumentReport> fetchDocumentReport({
    required String kind,
    required String locationId,
    String groupBy = 'day',
    DateTime? from,
    DateTime? to,
  }) async =>
      DocumentReport(
        groupBy: groupBy,
        totals: const ReportRow(
          key: 'totals',
          label: 'Total',
          count: 0,
          taxableMinor: 0,
          taxMinor: 0,
          grandTotalMinor: 0,
          paidMinor: 0,
          dueMinor: 0,
        ),
        rows: const [],
      );

  @override
  Future<List<StockMovement>> fetchStockMovements({
    required String locationId,
    String? productId,
  }) async =>
      const [];

  @override
  Future<List<ProposalSummary>> listProposals() async => const [];

  @override
  Future<Map<String, dynamic>> fetchProposal(String id) async => {'id': id};

  @override
  Future<List<ProposalRevision>> fetchRevisions(String id) async => const [];

  @override
  Future<Map<String, dynamic>> cancelProposal({
    required String id,
    required int version,
  }) async =>
      {'id': id};

  @override
  Future<DashboardSummary> fetchDashboard(String locationId) async {
    return DashboardSummary(
      salesMinor: 240000,
      expensesMinor: 0,
      toReceiveMinor: 90000,
      toPayMinor: 0,
      lowStockCount: 0,
      asOf: DateTime(2026, 9, 4, 12),
      summary: 'Test summary',
    );
  }

  @override
  Future<List<BusinessEntry>> fetchEntries(String locationId) async => const [];

  @override
  Future<List<BusinessLocation>> fetchLocations() async => const [location];

  @override
  Future<List<Party>> fetchParties(String locationId) async => const [];

  @override
  Future<List<Product>> fetchProducts(String locationId) async => [product];

  @override
  Future<AssistantProposal> interpret({
    required AssistantInput input,
    required String locationId,
    required String locale,
  }) async {
    interpretCalls++;
    return const AssistantProposal(
      id: 'proposal-test',
      version: 1,
      commandType: 'SALE',
      title: 'Sale to Ramesh',
      facts: [ReviewFact('Total', '₹2,400')],
      warnings: [],
      blockingQuestions: [],
      rawPayload: {},
    );
  }
}

