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

