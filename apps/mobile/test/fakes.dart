import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/data/audio_recorder.dart';
import 'package:dukaan_ai_mobile/data/auth_api.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overrides that make the app behave as a signed-in owner with one shop.
///
/// Without the session store override the app would reach for
/// flutter_secure_storage, which has no implementation under `flutter test`,
/// leaving the auth gate stuck on its loading screen.
List<Override> signedInOverrides({
  FakeDukaanRepository? repository,
  VoiceRecorder? recorder,
  BusinessRole role = BusinessRole.owner,
}) =>
    [
      repositoryProvider
          .overrideWithValue(repository ?? FakeDukaanRepository(role: role)),
      voiceRecorderProvider.overrideWithValue(recorder ?? FakeVoiceRecorder()),
      draftStoreProvider.overrideWithValue(MemoryDraftStore()),
      networkStatusProvider.overrideWith((ref) => Stream.value(true)),
      sessionStoreProvider.overrideWithValue(
        MemorySessionStore(access: 'test-access', refresh: 'test-refresh'),
      ),
    ];

/// Overrides for a first launch: no stored credentials.
List<Override> signedOutOverrides() => [
      repositoryProvider.overrideWithValue(FakeDukaanRepository()),
      draftStoreProvider.overrideWithValue(MemoryDraftStore()),
      networkStatusProvider.overrideWith((ref) => Stream.value(true)),
      sessionStoreProvider.overrideWithValue(MemorySessionStore()),
      authCapabilitiesProvider.overrideWith(
        (ref) async =>
            const AuthCapabilities(password: true, otp: false, devOtp: false),
      ),
    ];

class FakeVoiceRecorder implements VoiceRecorder {
  FakeVoiceRecorder({
    RecordedVoice? recording,
    this.startError,
    this.stopError,
  }) : nextRecording =
            recording ?? RecordedVoice(bytes: Uint8List.fromList([1, 2, 3]));

  final RecordedVoice nextRecording;
  final Object? startError;
  final Object? stopError;
  int startCalls = 0;
  int stopCalls = 0;
  int cancelCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> start() async {
    startCalls++;
    if (startError case final error?) throw error;
  }

  @override
  Future<RecordedVoice?> stop() async {
    stopCalls++;
    if (stopError case final error?) throw error;
    return nextRecording;
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}

class FakeDukaanRepository implements DukaanRepository {
  FakeDukaanRepository({
    this.role = BusinessRole.owner,
    this.userId = 'user-test',
    this.businessId = 'business-test',
  }) : location = BusinessLocation(
          id: 'location-test',
          businessId: businessId,
          name: 'Test Shop',
          isPrimary: true,
        );

  int interpretCalls = 0;
  int confirmCalls = 0;
  int saleCalls = 0;
  int purchaseCalls = 0;
  int expenseCalls = 0;
  int paymentCalls = 0;
  int transferCalls = 0;
  Map<String, dynamic>? lastPurchasePayload;
  Map<String, dynamic>? lastExpensePayload;
  Map<String, dynamic>? lastPaymentPayload;
  Map<String, dynamic>? lastTransferPayload;
  Object? purchaseError;
  Object? expenseError;
  Object? paymentError;
  Object? transferError;
  int voiceUploadCalls = 0;
  int imageUploadCalls = 0;
  int fromAudioCalls = 0;
  int fromImageCalls = 0;
  int pollCalls = 0;
  int presignCalls = 0;
  int presignedUploadCalls = 0;
  int meCalls = 0;
  int bootstrapCalls = 0;
  final List<String> entryCollectionCalls = [];
  List<int>? uploadedVoiceBytes;
  List<int>? uploadedImageBytes;
  String? uploadedImageMime;
  String? uploadedBusinessId;
  Map<String, dynamic>? lastFromAudioPayload;
  Map<String, dynamic>? lastFromImagePayload;
  AssistantProposal? voiceProposal;
  AssistantProposal? imageProposal;
  final List<AssistantProposal> voicePollResults = [];
  Object? voiceUploadError;
  Object? imageUploadError;
  Object? voicePollError;
  Object? revokeSessionsError;
  Object? importError;
  Object? allocationError;
  int revokeSessionsCalls = 0;
  String? lastCurrentPassword;
  int invitationCreateCalls = 0;
  int invitationRevokeCalls = 0;
  int invitationAcceptCalls = 0;
  int invoicePdfCalls = 0;
  int importPreviewCalls = 0;
  int importUploadCalls = 0;
  int importConfirmCalls = 0;
  int valuationCalls = 0;
  int allocationReviewCalls = 0;
  int reallocateCalls = 0;
  int reminderCreateCalls = 0;
  int reminderUpdateCalls = 0;
  int reminderDeleteCalls = 0;
  String? lastImportConfirmationKey;
  String? lastReallocationKey;
  String? lastReallocationReason;
  List<Map<String, dynamic>>? lastReallocatedAllocations;
  Map<String, dynamic>? lastBusinessPayload;
  List<Invitation> invitations = const [];
  List<ImportJob> importJobs = const [];
  List<Reminder> reminders = const [];
  List<NotificationDevice> notificationDevices = const [];
  ValuationReport? valuationReport;
  PaymentAllocationReview? allocationReview;
  final BusinessRole role;
  final String userId;
  final String businessId;
  final BusinessLocation location;

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
  Future<String> uploadVoiceRecording({
    required String businessId,
    required List<int> bytes,
  }) async {
    voiceUploadCalls++;
    uploadedBusinessId = businessId;
    uploadedVoiceBytes = List<int>.of(bytes);
    if (voiceUploadError case final error?) throw error;
    return 'attachment-voice';
  }

  @override
  Future<String> uploadImageAttachment({
    required String businessId,
    required String mime,
    required List<int> bytes,
  }) async {
    imageUploadCalls++;
    uploadedBusinessId = businessId;
    uploadedImageBytes = List<int>.of(bytes);
    uploadedImageMime = mime;
    if (imageUploadError case final error?) throw error;
    return 'attachment-image';
  }

  @override
  Future<AttachmentUploadTicket> presignVoiceUpload({
    required String businessId,
    required int sizeBytes,
  }) async {
    presignCalls++;
    return AttachmentUploadTicket(
      attachmentId: 'attachment-presigned',
      uploadUrl: 'https://storage.example.test/voice.m4a',
      uploadHeaders: const {'Content-Type': 'audio/m4a'},
    );
  }

  @override
  Future<void> uploadPresignedVoiceRecording({
    required AttachmentUploadTicket ticket,
    required List<int> bytes,
  }) async {
    presignedUploadCalls++;
    uploadedVoiceBytes = List<int>.of(bytes);
  }

  @override
  Future<AssistantProposal> createProposalFromAudio({
    required String attachmentId,
    required String businessId,
    required String locationId,
    required String locale,
  }) async {
    fromAudioCalls++;
    lastFromAudioPayload = {
      'attachment_id': attachmentId,
      'business_id': businessId,
      'location_id': locationId,
      'locale': locale,
    };
    return AssistantProposal.fromJson({
      'id': 'proposal-voice',
      'version': 1,
      'status': 'DRAFT',
      'command_type': 'UNSUPPORTED',
      'content': '',
      'blocking_questions': ['Your voice note is being transcribed.'],
      'payload': const {},
    });
  }

  @override
  Future<AssistantProposal> createProposalFromImage({
    required String attachmentId,
    required String businessId,
    required String locationId,
    required String locale,
  }) async {
    fromImageCalls++;
    lastFromImagePayload = {
      'attachment_id': attachmentId,
      'business_id': businessId,
      'location_id': locationId,
      'locale': locale,
    };
    return imageProposal ??
        AssistantProposal.fromJson({
          'id': 'proposal-image',
          'version': 1,
          'status': 'DRAFT',
          'command_type': 'SALE',
          'content': '',
          'blocking_questions': ['Your document is being read.'],
          'payload': const {},
        });
  }

  @override
  Future<AssistantProposal> pollProposal(
    String id, {
    Duration timeout = const Duration(seconds: 90),
    Duration pollInterval = const Duration(seconds: 1),
  }) async {
    pollCalls++;
    if (voicePollError case final error?) throw error;
    if (imageProposal case final proposal?) return proposal;
    if (voicePollResults.isNotEmpty) return voicePollResults.removeAt(0);
    return voiceProposal ??
        AssistantProposal.fromJson({
          'id': id,
          'version': 2,
          'status': 'READY',
          'command_type': 'SALE',
          'content': 'Ramesh bought three shirts',
          'preview': 'Sale to Ramesh',
          'warnings': const [],
          'blocking_questions': const [],
          'payload': const {},
        });
  }

  @override
  Future<AssistantProposal> refreshProposal(AssistantProposal proposal) async =>
      proposal;

  @override
  Future<PostedResult> confirmProposal(AssistantProposal proposal) async {
    confirmCalls++;
    return const PostedResult(
        id: 'sale-test', reference: 'INV-TEST', message: 'Saved');
  }

  @override
  Future<PostedResult> createSale(SaleDraft draft,
      {String? idempotencyKey}) async {
    saleCalls++;
    return const PostedResult(
        id: 'sale-test', reference: 'INV-TEST', message: 'Saved');
  }

  @override
  Future<Map<String, dynamic>> fetchMe() async {
    meCalls++;
    return {
      'id': userId,
      'phone': '+919876543210',
      'display_name': 'Test User',
      'memberships': [
        {
          'business_id': businessId,
          'business_name': 'Test Business',
          'role': role.name.toUpperCase(),
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> fetchBootstrap({String? businessId}) async {
    bootstrapCalls++;
    return {
      'user': {
        'id': userId,
        'name': 'Test User',
        'role': role.name.toUpperCase(),
      },
      'business': {'id': this.businessId, 'name': 'Test Business'},
      'locations': [
        {'id': location.id, 'name': location.name},
      ],
      'permissions':
          role == BusinessRole.owner ? const ['*'] : const ['sales', 'stock'],
    };
  }

  @override
  Future<void> revokeAllSessions({required String currentPassword}) async {
    revokeSessionsCalls++;
    lastCurrentPassword = currentPassword;
    if (revokeSessionsError case final error?) throw error;
  }

  @override
  Future<List<Invitation>> listInvitations(
          {required String businessId}) async =>
      invitations.where((item) => item.businessId == businessId).toList();

  @override
  Future<Invitation> createInvitation(Map<String, dynamic> payload) async {
    invitationCreateCalls++;
    return Invitation(
      id: 'invitation-created',
      businessId: (payload['business'] ?? businessId).toString(),
      inviteePhone: (payload['invitee_phone'] ?? '').toString(),
      role: (payload['role'] ?? 'CASHIER').toString(),
      status: 'PENDING',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      locations: (payload['locations'] as List? ?? const [])
          .map((value) => value.toString())
          .toList(),
      token: 'one-time-invitation-token-1234567890',
    );
  }

  @override
  Future<Invitation> revokeInvitation(String id) async {
    invitationRevokeCalls++;
    final invitation = invitations.firstWhere(
      (item) => item.id == id,
      orElse: () => Invitation(
        id: id,
        businessId: businessId,
        inviteePhone: '+919876543210',
        role: 'CASHIER',
        status: 'REVOKED',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
    );
    final revoked = Invitation(
      id: invitation.id,
      businessId: invitation.businessId,
      inviteePhone: invitation.inviteePhone,
      role: invitation.role,
      status: 'REVOKED',
      expiresAt: invitation.expiresAt,
      locations: invitation.locations,
      revokedAt: DateTime.now(),
    );
    invitations = [
      for (final item in invitations)
        if (item.id == id) revoked else item,
    ];
    return revoked;
  }

  @override
  Future<Invitation> acceptInvitation({required String token}) async {
    invitationAcceptCalls++;
    return Invitation(
      id: 'invitation-accepted',
      businessId: businessId,
      inviteePhone: '+919876543210',
      role: 'CASHIER',
      status: 'ACCEPTED',
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      acceptedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Business>> listBusinesses() async => [
        Business(
            id: businessId,
            name: 'Test Business',
            role: role.name.toUpperCase()),
      ];

  @override
  Future<Business> createBusiness(Map<String, dynamic> payload) async {
    lastBusinessPayload = payload;
    return Business(
        id: businessId,
        name: payload['name']?.toString() ?? 'Test Business',
        role: 'OWNER');
  }

  @override
  Future<Business> fetchBusiness(String id) async =>
      Business(id: id, name: 'Test Business', role: role.name.toUpperCase());

  @override
  Future<List<BusinessLocation>> listLocations({String? businessId}) async =>
      [location];

  @override
  Future<BusinessLocation> createLocation(Map<String, dynamic> payload) async =>
      location;

  @override
  Future<BusinessLocation> updateLocation(
          String id, Map<String, dynamic> payload) async =>
      location;

  @override
  Future<void> deleteLocation(String id) async {}

  @override
  Future<List<GstRegistration>> listGst({String? businessId}) async => const [];

  @override
  Future<GstRegistration> createGst(Map<String, dynamic> payload) async =>
      const GstRegistration(id: 'gst-test', businessId: 'business-test');

  @override
  Future<GstRegistration> updateGst(
          String id, Map<String, dynamic> payload) async =>
      GstRegistration(id: id, businessId: 'business-test');

  @override
  Future<List<Membership>> listMemberships({String? businessId}) async =>
      const [];

  @override
  Future<Membership> createMembership(Map<String, dynamic> payload) async =>
      const Membership(
          id: 'membership-test', businessId: 'business-test', role: 'OWNER');

  @override
  Future<Membership> updateMembership(
          String id, Map<String, dynamic> payload) async =>
      Membership(id: id, businessId: 'business-test', role: 'OWNER');

  @override
  Future<void> deleteMembership(String id) async {}

  @override
  Future<Product> fetchProduct(String id) async => product;

  @override
  Future<Product> createProduct(Map<String, dynamic> payload) async => product;

  @override
  Future<Product> updateProduct(
          String id, Map<String, dynamic> payload) async =>
      product;

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
  Future<Party> updateParty(String id, Map<String, dynamic> payload) async =>
      Party(
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
  Future<SaleInvoicePdf> fetchSaleInvoicePdf(String saleId) async {
    invoicePdfCalls++;
    return SaleInvoicePdf(
      bytes: [0x25, 0x50, 0x44, 0x46, 0x2d, ...utf8.encode('test invoice')],
      filename: 'invoice-$saleId.pdf',
    );
  }

  @override
  Future<PostedResult> createPurchase(Map<String, dynamic> payload) async {
    purchaseCalls++;
    lastPurchasePayload = Map<String, dynamic>.from(payload);
    if (purchaseError case final error?) throw error;
    return const PostedResult(
        id: 'purchase-test', reference: 'PUR-TEST', message: 'Saved');
  }

  @override
  Future<PostedResult> createPayment(Map<String, dynamic> payload) async {
    paymentCalls++;
    lastPaymentPayload = Map<String, dynamic>.from(payload);
    if (paymentError case final error?) throw error;
    return const PostedResult(
        id: 'payment-test', reference: 'PAY-TEST', message: 'Saved');
  }

  @override
  Future<PostedResult> createExpense(Map<String, dynamic> payload) async {
    expenseCalls++;
    lastExpensePayload = Map<String, dynamic>.from(payload);
    if (expenseError case final error?) throw error;
    return const PostedResult(
        id: 'expense-test', reference: 'EXP-TEST', message: 'Saved');
  }

  @override
  Future<PostedResult> createTransfer(Map<String, dynamic> payload) async {
    transferCalls++;
    lastTransferPayload = Map<String, dynamic>.from(payload);
    if (transferError case final error?) throw error;
    return const PostedResult(
        id: 'transfer-test', reference: 'TRF-TEST', message: 'Saved');
  }

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
  Future<Map<String, dynamic>> adjustStock(
          Map<String, dynamic> payload) async =>
      const {'id': 'adjustment-test'};

  @override
  Future<Map<String, dynamic>> postOpeningBalance(
          Map<String, dynamic> payload) async =>
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
  Future<ValuationReport> fetchValuationReport({
    required String businessId,
    String? locationId,
    String? dateFrom,
    String? dateTo,
  }) async {
    valuationCalls++;
    return valuationReport ??
        ValuationReport(
          inventory: ValuationInventory(
            totalQuantity: Decimal.zero,
            averageCostMinor: null,
            totalValueMinor: null,
            knownValueMinor: 0,
            costingComplete: true,
          ),
          sales: ValuationSales(
            postedSaleCount: 0,
            lineCount: 0,
            netSalesMinor: 0,
            cogsMinor: 0,
            grossProfitMinor: 0,
            missingCostLineCount: 0,
            costingComplete: true,
          ),
          rows: const [],
        );
  }

  @override
  Future<PaymentAllocationReview> fetchPaymentAllocationReview({
    required String businessId,
    String? locationId,
    String? direction,
    String? partyId,
    String? status,
  }) async {
    allocationReviewCalls++;
    return allocationReview ??
        PaymentAllocationReview(
          payments: const [],
          totals: AllocationReviewTotals(
            paymentCount: 0,
            paymentTotalMinor: 0,
            allocatedTotalMinor: 0,
            unallocatedTotalMinor: 0,
            outstandingDocumentCount: 0,
            outstandingTotalMinor: 0,
          ),
          outstandingDocuments: const [],
        );
  }

  @override
  Future<PaymentRecord> reallocatePayment({
    required String id,
    required List<Map<String, dynamic>> allocations,
    required String reason,
    String? idempotencyKey,
  }) async {
    reallocateCalls++;
    lastReallocationKey = idempotencyKey;
    lastReallocationReason = reason;
    lastReallocatedAllocations =
        allocations.map((item) => Map<String, dynamic>.from(item)).toList();
    if (allocationError case final error?) throw error;
    return PaymentRecord(
      id: id,
      businessId: businessId,
      locationId: location.id,
      partyId: 'party-test',
      direction: 'RECEIPT',
      method: 'CASH',
      amountMinor: allocations.fold(
          0, (sum, item) => sum + minorFrom(item['amount_minor'])),
      status: 'POSTED',
      allocatedTotalMinor: allocations.fold(
          0, (sum, item) => sum + minorFrom(item['amount_minor'])),
      unallocatedTotalMinor: 0,
      allocations: [
        for (var index = 0; index < allocations.length; index++)
          PaymentAllocation(
            id: 'allocation-$index',
            amountMinor: minorFrom(allocations[index]['amount_minor']),
            documentType:
                (allocations[index]['document_type'] ?? 'SALE').toString(),
            documentId: allocations[index]['document_id']?.toString(),
          ),
      ],
    );
  }

  @override
  Future<ImportDryRun> previewImport({
    required String businessId,
    required CsvImportKind kind,
    required List<int> bytes,
    required String filename,
    required String duplicateStrategy,
  }) async {
    importPreviewCalls++;
    if (importError case final error?) throw error;
    return ImportDryRun(
      kind: kind.apiValue,
      duplicateStrategy: duplicateStrategy,
      rowCount: 1,
      validRowCount: 1,
      errorCount: 0,
      createdCount: 1,
      updatedCount: 0,
      skippedCount: 0,
      errors: const [],
      preview: [ImportPreviewRow(row: 2, action: 'CREATE')],
    );
  }

  @override
  Future<ImportJob> uploadImport({
    required String businessId,
    required CsvImportKind kind,
    required List<int> bytes,
    required String filename,
    required String duplicateStrategy,
  }) async {
    importUploadCalls++;
    if (importError case final error?) throw error;
    final job = ImportJob(
      id: 'import-created',
      businessId: businessId,
      kind: kind.apiValue,
      status: 'READY',
      duplicateStrategy: duplicateStrategy,
      rowCount: 1,
      validRowCount: 1,
      errorCount: 0,
      createdCount: 0,
      updatedCount: 0,
      skippedCount: 0,
      errors: const [],
      originalFilename: filename,
      fileSizeBytes: bytes.length,
      createdAt: DateTime.now(),
    );
    importJobs = [job, ...importJobs];
    return job;
  }

  @override
  Future<List<ImportJob>> listImports({required String businessId}) async =>
      importJobs.where((job) => job.businessId == businessId).toList();

  @override
  Future<ImportJob> fetchImport(String id) async => importJobs.firstWhere(
        (job) => job.id == id,
        orElse: () => ImportJob(
          id: id,
          businessId: businessId,
          kind: 'PRODUCT',
          status: 'READY',
          duplicateStrategy: 'UPDATE',
          rowCount: 0,
          validRowCount: 0,
          errorCount: 0,
          createdCount: 0,
          updatedCount: 0,
          skippedCount: 0,
          errors: const [],
          originalFilename: 'import.csv',
          fileSizeBytes: 0,
        ),
      );

  @override
  Future<ImportConfirmation> confirmImport({
    required String id,
    String? idempotencyKey,
  }) async {
    importConfirmCalls++;
    lastImportConfirmationKey = idempotencyKey;
    if (importError case final error?) throw error;
    final job = await fetchImport(id);
    final completed = ImportJob(
      id: job.id,
      businessId: job.businessId,
      kind: job.kind,
      status: 'COMPLETED',
      duplicateStrategy: job.duplicateStrategy,
      rowCount: job.rowCount,
      validRowCount: job.validRowCount,
      errorCount: job.errorCount,
      createdCount: job.validRowCount,
      updatedCount: 0,
      skippedCount: 0,
      errors: job.errors,
      originalFilename: job.originalFilename,
      fileSizeBytes: job.fileSizeBytes,
      confirmedAt: DateTime.now(),
    );
    importJobs = [
      for (final item in importJobs)
        if (item.id == id) completed else item,
    ];
    return ImportConfirmation(job: completed, replayed: false);
  }

  @override
  Future<List<NotificationDevice>> listNotificationDevices() async =>
      notificationDevices;

  @override
  Future<NotificationDevice> registerNotificationDevice({
    required String businessId,
    required String fcmToken,
    String? locationId,
    required String platform,
    Map<String, dynamic> metadata = const {},
  }) async =>
      NotificationDevice(
        id: 'device-created',
        businessId: businessId,
        locationId: locationId,
        platform: platform,
        status: 'ACTIVE',
        tokenSuffix: '…${fcmToken.substring(fcmToken.length - 4)}',
      );

  @override
  Future<void> unregisterNotificationDevice(String id) async {
    notificationDevices = [
      for (final device in notificationDevices)
        if (device.id == id)
          NotificationDevice(
            id: device.id,
            businessId: device.businessId,
            locationId: device.locationId,
            platform: device.platform,
            status: 'DISABLED',
            tokenSuffix: device.tokenSuffix,
            unregisteredAt: DateTime.now(),
          )
        else
          device,
    ];
  }

  @override
  Future<List<Reminder>> listReminders() async => reminders;

  @override
  Future<Reminder> createReminder(Map<String, dynamic> payload) async {
    reminderCreateCalls++;
    final reminder = Reminder(
      id: 'reminder-created',
      businessId: (payload['business_id'] ?? businessId).toString(),
      locationId: payload['location_id']?.toString(),
      title: (payload['title'] ?? '').toString(),
      body: (payload['body'] ?? '').toString(),
      scheduledAt: DateTime.parse(payload['scheduled_at'].toString()),
      status: 'SCHEDULED',
    );
    reminders = [reminder, ...reminders];
    return reminder;
  }

  @override
  Future<Reminder> updateReminder(
      String id, Map<String, dynamic> payload) async {
    reminderUpdateCalls++;
    final reminder = reminders.firstWhere((item) => item.id == id);
    final updated = Reminder(
      id: reminder.id,
      businessId: reminder.businessId,
      locationId: reminder.locationId,
      kind: reminder.kind,
      title: (payload['title'] ?? reminder.title).toString(),
      body: (payload['body'] ?? reminder.body).toString(),
      scheduledAt: payload['scheduled_at'] == null
          ? reminder.scheduledAt
          : DateTime.parse(payload['scheduled_at'].toString()),
      status: reminder.status,
      dedupeKey: reminder.dedupeKey,
      data: reminder.data,
      metadata: reminder.metadata,
    );
    reminders = [
      for (final item in reminders)
        if (item.id == id) updated else item,
    ];
    return updated;
  }

  @override
  Future<void> deleteReminder(String id) async {
    reminderDeleteCalls++;
    reminders = reminders.where((item) => item.id != id).toList();
  }

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
  Future<List<BusinessEntry>> fetchEntries(
    String locationId, {
    BusinessRole? role,
  }) async {
    final effectiveRole = role ?? this.role;
    entryCollectionCalls.add('sales');
    if (effectiveRole.canManageOperations) {
      entryCollectionCalls.addAll(['purchases', 'expenses']);
    }
    entryCollectionCalls.add('payments');
    return const [];
  }

  @override
  Future<List<BusinessLocation>> fetchLocations() async => [location];

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
      status: 'READY',
      commandType: 'SALE',
      title: 'Sale to Ramesh',
      facts: [ReviewFact('Total', '₹2,400')],
      warnings: [],
      blockingQuestions: [],
      rawPayload: {},
    );
  }
}
