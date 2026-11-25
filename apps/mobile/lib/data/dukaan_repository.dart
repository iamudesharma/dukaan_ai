import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:uuid/uuid.dart';

abstract interface class DukaanRepository {
  Future<List<BusinessLocation>> fetchLocations();
  Future<DashboardSummary> fetchDashboard(String locationId);
  Future<List<BusinessEntry>> fetchEntries(
    String locationId, {
    BusinessRole? role,
  });
  Future<List<Product>> fetchProducts(String locationId);
  Future<List<Party>> fetchParties(String locationId);
  Future<AssistantProposal> interpret({
    required AssistantInput input,
    required String locationId,
    required String locale,
  });
  Future<String> uploadVoiceRecording({
    required String businessId,
    required List<int> bytes,
  });
  Future<AttachmentUploadTicket> presignVoiceUpload({
    required String businessId,
    required int sizeBytes,
  });
  Future<void> uploadPresignedVoiceRecording({
    required AttachmentUploadTicket ticket,
    required List<int> bytes,
  });
  Future<AssistantProposal> createProposalFromAudio({
    required String attachmentId,
    required String businessId,
    required String locationId,
    required String locale,
  });
  Future<String> uploadImageAttachment({
    required String businessId,
    required String mime,
    required List<int> bytes,
  });
  Future<AssistantProposal> createProposalFromImage({
    required String attachmentId,
    required String businessId,
    required String locationId,
    required String locale,
  });
  Future<AssistantProposal> pollProposal(
    String id, {
    Duration timeout = const Duration(seconds: 90),
    Duration pollInterval = const Duration(seconds: 1),
  });
  Future<AssistantProposal> refreshProposal(AssistantProposal proposal);
  Future<PostedResult> confirmProposal(AssistantProposal proposal);
  // [idempotencyKey] defaults to a fresh UUID. Pass a stable key derived
  // from the offline draft id when syncing, so a timeout retry replays
  // instead of posting a duplicate sale.
  Future<PostedResult> createSale(SaleDraft draft, {String? idempotencyKey});

  // Common: current user + bootstrap.
  Future<Map<String, dynamic>> fetchMe();
  Future<Map<String, dynamic>> fetchBootstrap({String? businessId});

  // Security. The backend revokes every token only after password verification.
  Future<void> revokeAllSessions({required String currentPassword});

  // Tenancy.
  Future<List<Business>> listBusinesses();
  Future<Business> createBusiness(Map<String, dynamic> payload);
  Future<Business> fetchBusiness(String id);
  Future<List<BusinessLocation>> listLocations({String? businessId});
  Future<BusinessLocation> createLocation(Map<String, dynamic> payload);
  Future<BusinessLocation> updateLocation(
      String id, Map<String, dynamic> payload);
  Future<void> deleteLocation(String id);
  Future<List<GstRegistration>> listGst({String? businessId});
  Future<GstRegistration> createGst(Map<String, dynamic> payload);
  Future<GstRegistration> updateGst(String id, Map<String, dynamic> payload);
  Future<List<Membership>> listMemberships({String? businessId});
  Future<Membership> createMembership(Map<String, dynamic> payload);
  Future<Membership> updateMembership(String id, Map<String, dynamic> payload);
  Future<void> deleteMembership(String id);

  // Owner-only invitations. A raw token exists only in the create response.
  Future<List<Invitation>> listInvitations({required String businessId});
  Future<Invitation> createInvitation(Map<String, dynamic> payload);
  Future<Invitation> revokeInvitation(String id);
  Future<Invitation> acceptInvitation({required String token});

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
  Future<SaleInvoicePdf> fetchSaleInvoicePdf(String saleId);

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
  Future<ValuationReport> fetchValuationReport({
    required String businessId,
    String? locationId,
    String? dateFrom,
    String? dateTo,
  });
  Future<PaymentAllocationReview> fetchPaymentAllocationReview({
    required String businessId,
    String? locationId,
    String? direction,
    String? partyId,
    String? status,
  });
  Future<PaymentRecord> reallocatePayment({
    required String id,
    required List<Map<String, dynamic>> allocations,
    required String reason,
    String? idempotencyKey,
  });

  // CSV imports are review-only until confirmImport is explicitly called.
  Future<ImportDryRun> previewImport({
    required String businessId,
    required CsvImportKind kind,
    required List<int> bytes,
    required String filename,
    required String duplicateStrategy,
  });
  Future<ImportJob> uploadImport({
    required String businessId,
    required CsvImportKind kind,
    required List<int> bytes,
    required String filename,
    required String duplicateStrategy,
  });
  Future<List<ImportJob>> listImports({required String businessId});
  Future<ImportJob> fetchImport(String id);
  Future<ImportConfirmation> confirmImport({
    required String id,
    String? idempotencyKey,
  });

  // Integrations. Device registration requires a real externally supplied FCM
  // token; the mobile UI intentionally does not fabricate one.
  Future<List<NotificationDevice>> listNotificationDevices();
  Future<NotificationDevice> registerNotificationDevice({
    required String businessId,
    required String fcmToken,
    String? locationId,
    required String platform,
    Map<String, dynamic> metadata = const {},
  });
  Future<void> unregisterNotificationDevice(String id);
  Future<List<Reminder>> listReminders();
  Future<Reminder> createReminder(Map<String, dynamic> payload);
  Future<Reminder> updateReminder(String id, Map<String, dynamic> payload);
  Future<void> deleteReminder(String id);

  // Assistant proposals.
  Future<List<ProposalSummary>> listProposals();
  Future<Map<String, dynamic>> fetchProposal(String id);
  Future<List<ProposalRevision>> fetchRevisions(String id);
  Future<Map<String, dynamic>> cancelProposal({
    required String id,
    required int version,
  });
}

class VoiceTranscriptionException implements Exception {
  const VoiceTranscriptionException.timeout();

  @override
  String toString() => 'Voice transcription timed out.';
}

class ApiDukaanRepository implements DukaanRepository {
  ApiDukaanRepository(this._dio, {Dio Function()? uploadClientFactory})
      : _uploadClientFactory = uploadClientFactory ?? _createUploadClient;

  final Dio _dio;
  final Dio Function() _uploadClientFactory;

  static Dio _createUploadClient() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 30),
          responseType: ResponseType.plain,
        ),
      );
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
    final response = await _dio.get<Object>('locations/',
        queryParameters: {'business_id': businessId});
    return _rows(response.data)
        .map(
          (row) =>
              BusinessLocation.fromJson({...row, 'business_id': businessId}),
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
  Future<List<BusinessEntry>> fetchEntries(
    String locationId, {
    BusinessRole? role,
  }) async {
    final businessId = await _resolveBusinessId();
    final effectiveRole =
        role ?? BusinessBootstrap.fromJson(await fetchBootstrap()).role;
    // Cashiers cannot read purchase/expense reports or endpoints. Receipts
    // remain available as payment rows, alongside sales.
    final requests = <(String, EntryType, Future<Response<Object>>)>[
      (
        'sales/',
        EntryType.sale,
        _dio.get<Object>('sales/', queryParameters: {
          'business_id': businessId,
          'location_id': locationId,
          'brief': '1',
        })
      ),
      if (effectiveRole.canManageOperations)
        (
          'purchases/',
          EntryType.purchase,
          _dio.get<Object>('purchases/', queryParameters: {
            'business_id': businessId,
            'location_id': locationId,
            'brief': '1',
          })
        ),
      if (effectiveRole.canManageOperations)
        (
          'expenses/',
          EntryType.expense,
          _dio.get<Object>('expenses/', queryParameters: {
            'business_id': businessId,
            'location_id': locationId,
            'brief': '1',
          })
        ),
      (
        'payments/',
        EntryType.payment,
        _dio.get<Object>('payments/', queryParameters: {
          'business_id': businessId,
          'location_id': locationId,
          'brief': '1',
        })
      ),
    ];
    final responses = await Future.wait(requests.map((request) => request.$3));
    final entries = <BusinessEntry>[];
    for (var index = 0; index < responses.length; index++) {
      entries.addAll(
        _rows(responses[index].data)
            .map((row) => _entryFromJson(row, requests[index].$2)),
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
      // Pickers must see the whole catalog: bounded page, not the 50 default.
      queryParameters: {
        'business_id': businessId,
        'location_id': locationId,
        'page_size': 200
      },
    );
    return _rows(response.data).map(Product.fromJson).toList(growable: false);
  }

  @override
  Future<List<Party>> fetchParties(String locationId) async {
    final businessId = await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'parties/',
      // Pickers must see the whole address book: bounded page, not the 50 default.
      queryParameters: {
        'business_id': businessId,
        'location_id': locationId,
        'page_size': 200
      },
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
      // Model extraction can take ~20s server-side plus slow-network
      // latency; the 20s default would time out real responses on 4G.
      // Never retried (each call mints a new proposal): see api_client.
      options: Options(
        extra: {'locale': locale},
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    return _proposalFromJson(_object(response.data));
  }

  @override
  Future<String> uploadVoiceRecording({
    required String businessId,
    required List<int> bytes,
  }) async {
    if (bytes.isEmpty || bytes.length > maxAttachmentBytes) {
      throw ArgumentError.value(
          bytes.length, 'bytes', 'Voice recording is empty or too large.');
    }
    final form = FormData.fromMap({
      'business_id': businessId,
      'kind': 'VOICE',
      'mime': voiceMimeType,
      'size_bytes': bytes.length,
      'file': MultipartFile.fromBytes(
        bytes,
        filename: 'voice-${DateTime.now().millisecondsSinceEpoch}.m4a',
        contentType: DioMediaType('audio', 'm4a'),
      ),
    });
    final response = await _dio.post<Object>(
      'assistant/attachments/upload/',
      data: form,
      options: Options(
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    final attachment = _object(response.data);
    final id = attachment['id']?.toString() ?? '';
    if (id.isEmpty || attachment['status'] != 'READY') {
      throw const FormatException('Voice attachment upload was not confirmed.');
    }
    return id;
  }

  @override
  Future<String> uploadImageAttachment({
    required String businessId,
    required String mime,
    required List<int> bytes,
  }) async {
    const allowedMimes = {
      'image/jpeg',
      'image/png',
      'application/pdf',
    };
    if (!allowedMimes.contains(mime)) {
      throw ArgumentError.value(mime, 'mime', 'Unsupported document type.');
    }
    if (bytes.isEmpty || bytes.length > maxAttachmentBytes) {
      throw ArgumentError.value(
          bytes.length, 'bytes', 'Document is empty or too large.');
    }
    final extension = switch (mime) {
      'application/pdf' => 'pdf',
      'image/png' => 'png',
      _ => 'jpg',
    };
    final parts = mime.split('/');
    final form = FormData.fromMap({
      'business_id': businessId,
      'kind': 'IMAGE',
      'mime': mime,
      'size_bytes': bytes.length,
      'file': MultipartFile.fromBytes(
        bytes,
        filename:
            'document-${DateTime.now().millisecondsSinceEpoch}.$extension',
        contentType: DioMediaType(parts.first, parts.last),
      ),
    });
    final response = await _dio.post<Object>(
      'assistant/attachments/upload/',
      data: form,
      options: Options(
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    final attachment = _object(response.data);
    final id = attachment['id']?.toString() ?? '';
    if (id.isEmpty || attachment['status'] != 'READY') {
      throw const FormatException(
          'Document attachment upload was not confirmed.');
    }
    return id;
  }

  @override
  Future<AttachmentUploadTicket> presignVoiceUpload({
    required String businessId,
    required int sizeBytes,
  }) async {
    if (sizeBytes <= 0 || sizeBytes > maxAttachmentBytes) {
      throw ArgumentError.value(
          sizeBytes, 'sizeBytes', 'Voice recording is empty or too large.');
    }
    final response = await _dio.post<Object>(
      'assistant/attachments/presign/',
      data: {
        'business_id': businessId,
        'kind': 'VOICE',
        'mime': voiceMimeType,
        'size_bytes': sizeBytes,
      },
    );
    return AttachmentUploadTicket.fromJson(_object(response.data));
  }

  @override
  Future<void> uploadPresignedVoiceRecording({
    required AttachmentUploadTicket ticket,
    required List<int> bytes,
  }) async {
    if (bytes.isEmpty || bytes.length > maxAttachmentBytes) {
      throw ArgumentError.value(
          bytes.length, 'bytes', 'Voice recording is empty or too large.');
    }
    final headers = Map<String, String>.from(ticket.uploadHeaders);
    if (!headers.keys.any((key) => key.toLowerCase() == 'content-type')) {
      headers['Content-Type'] = voiceMimeType;
    }
    // A bare client is intentional: the API interceptor must never attach the
    // user's bearer token to a third-party presigned storage URL.
    final client = _uploadClientFactory();
    try {
      await client.put<Object>(
        ticket.uploadUrl,
        data: bytes,
        options: Options(
          headers: headers,
          responseType: ResponseType.plain,
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<AssistantProposal> createProposalFromAudio({
    required String attachmentId,
    required String businessId,
    required String locationId,
    required String locale,
  }) async {
    final response = await _dio.post<Object>(
      'assistant/proposals/from-audio/',
      data: {
        'attachment_id': attachmentId,
        'business_id': businessId,
        'location_id': locationId,
        'locale': locale,
      },
      options: Options(
        extra: {'locale': locale},
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return _proposalFromJson(_object(response.data));
  }

  @override
  Future<AssistantProposal> createProposalFromImage({
    required String attachmentId,
    required String businessId,
    required String locationId,
    required String locale,
  }) async {
    final response = await _dio.post<Object>(
      'assistant/proposals/from-image/',
      data: {
        'attachment_id': attachmentId,
        'business_id': businessId,
        'location_id': locationId,
        'locale': locale,
      },
      options: Options(
        extra: {'locale': locale},
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return _proposalFromJson(_object(response.data));
  }

  @override
  Future<AssistantProposal> pollProposal(
    String id, {
    Duration timeout = const Duration(seconds: 90),
    Duration pollInterval = const Duration(seconds: 1),
  }) async {
    final completer = Completer<AssistantProposal>();
    var stopped = false;
    var inFlight = false;
    Timer? timeoutTimer;
    Timer? pollTimer;

    void stopTimers() {
      timeoutTimer?.cancel();
      pollTimer?.cancel();
    }

    void finish(AssistantProposal proposal) {
      if (completer.isCompleted) return;
      stopped = true;
      stopTimers();
      completer.complete(proposal);
    }

    void fail(Object error) {
      if (completer.isCompleted) return;
      stopped = true;
      stopTimers();
      completer.completeError(error);
    }

    Future<void> pollOnce() async {
      if (stopped || inFlight || completer.isCompleted) return;
      inFlight = true;
      try {
        final response = await _dio.get<Object>('assistant/proposals/$id/');
        if (stopped) return;
        final proposal = _proposalFromJson(_object(response.data));
        if (_isTranscriptionTerminal(proposal)) {
          finish(proposal);
          return;
        }
      } on Object catch (error) {
        if (!stopped) fail(error);
      } finally {
        inFlight = false;
      }
    }

    timeoutTimer = Timer(timeout, () {
      fail(const VoiceTranscriptionException.timeout());
    });
    pollTimer = Timer.periodic(pollInterval, (_) {
      unawaited(pollOnce());
    });
    unawaited(pollOnce());
    return completer.future;
  }

  bool _isTranscriptionTerminal(AssistantProposal proposal) {
    if (proposal.status != 'DRAFT') return true;
    if (proposal.transcript.trim().isNotEmpty) return true;
    return proposal.blockingQuestions.any(
      (question) => !question.toLowerCase().contains('being transcribed'),
    );
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
  Future<PostedResult> createSale(SaleDraft draft,
      {String? idempotencyKey}) async {
    final response = await _dio.post<Object>(
      'sales/',
      data: draft.toApiJson(idempotencyKey ?? const Uuid().v4()),
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
  Future<void> revokeAllSessions({required String currentPassword}) async {
    await _dio.post<Object>(
      'auth/sessions/revoke-all/',
      data: {'current_password': currentPassword},
    );
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
        .map((row) =>
            BusinessLocation.fromJson({...row, 'business_id': resolved}))
        .toList(growable: false);
  }

  @override
  Future<BusinessLocation> createLocation(Map<String, dynamic> payload) async {
    final businessId =
        payload['business']?.toString() ?? await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'locations/',
      data: {...payload, 'business': businessId},
    );
    return BusinessLocation.fromJson(
        {..._object(response.data), 'business_id': businessId});
  }

  @override
  Future<BusinessLocation> updateLocation(
      String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Object>('locations/$id/', data: payload);
    final row = _object(response.data);
    return BusinessLocation.fromJson({
      ...row,
      'business_id':
          row['business_id'] ?? row['business'] ?? await _resolveBusinessId(),
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
    return _rows(response.data)
        .map(GstRegistration.fromJson)
        .toList(growable: false);
  }

  @override
  Future<GstRegistration> createGst(Map<String, dynamic> payload) async {
    final businessId =
        payload['business']?.toString() ?? await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'gst-registrations/',
      data: {...payload, 'business': businessId},
    );
    return GstRegistration.fromJson(_object(response.data));
  }

  @override
  Future<GstRegistration> updateGst(
      String id, Map<String, dynamic> payload) async {
    final response =
        await _dio.patch<Object>('gst-registrations/$id/', data: payload);
    return GstRegistration.fromJson(_object(response.data));
  }

  @override
  Future<List<Membership>> listMemberships({String? businessId}) async {
    final resolved = businessId ?? await _resolveBusinessId();
    final response = await _dio.get<Object>(
      'memberships/',
      queryParameters: {'business_id': resolved},
    );
    return _rows(response.data)
        .map(Membership.fromJson)
        .toList(growable: false);
  }

  @override
  Future<Membership> createMembership(Map<String, dynamic> payload) async {
    final businessId =
        payload['business']?.toString() ?? await _resolveBusinessId();
    final response = await _dio.post<Object>(
      'memberships/',
      data: {...payload, 'business': businessId},
    );
    return Membership.fromJson(_object(response.data));
  }

  @override
  Future<Membership> updateMembership(
      String id, Map<String, dynamic> payload) async {
    final response =
        await _dio.patch<Object>('memberships/$id/', data: payload);
    return Membership.fromJson(_object(response.data));
  }

  @override
  Future<void> deleteMembership(String id) async {
    await _dio.delete<Object>('memberships/$id/');
  }

  @override
  Future<List<Invitation>> listInvitations({required String businessId}) async {
    final response = await _dio.get<Object>(
      'invitations/',
      queryParameters: {'business_id': businessId},
    );
    return _rows(response.data)
        .map(Invitation.fromJson)
        .toList(growable: false);
  }

  @override
  Future<Invitation> createInvitation(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>('invitations/', data: payload);
    return Invitation.fromJson(_object(response.data));
  }

  @override
  Future<Invitation> revokeInvitation(String id) async {
    final response = await _dio.post<Object>('invitations/$id/revoke/');
    return Invitation.fromJson(_object(response.data));
  }

  @override
  Future<Invitation> acceptInvitation({required String token}) async {
    final response = await _dio.post<Object>(
      'invitations/accept/',
      data: {'token': token.trim()},
    );
    return Invitation.fromJson(_object(response.data));
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
  Future<SaleInvoicePdf> fetchSaleInvoicePdf(String saleId) async {
    final response = await _dio.get<List<int>>(
      'invoices/sales/$saleId/pdf/',
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 45),
      ),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('The invoice PDF was empty.');
    }
    if (bytes.length < 5 ||
        bytes[0] != 0x25 ||
        bytes[1] != 0x50 ||
        bytes[2] != 0x44 ||
        bytes[3] != 0x46 ||
        bytes[4] != 0x2d) {
      throw const FormatException('The server did not return a PDF invoice.');
    }
    return SaleInvoicePdf(
      bytes: List<int>.from(bytes),
      filename: _safePdfFilename(
        response.headers.value('content-disposition'),
        saleId,
      ),
    );
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
  Future<Map<String, dynamic>> postOpeningBalance(
      Map<String, dynamic> payload) async {
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

  @override
  Future<ValuationReport> fetchValuationReport({
    required String businessId,
    String? locationId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _dio.get<Object>(
      'reports/valuation/',
      queryParameters: {
        'business_id': businessId,
        if (locationId != null && locationId.isNotEmpty)
          'location_id': locationId,
        if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
      },
    );
    return ValuationReport.fromJson(_object(response.data));
  }

  @override
  Future<PaymentAllocationReview> fetchPaymentAllocationReview({
    required String businessId,
    String? locationId,
    String? direction,
    String? partyId,
    String? status,
  }) async {
    final response = await _dio.get<Object>(
      'payments/allocation-review/',
      queryParameters: {
        'business_id': businessId,
        if (locationId != null && locationId.isNotEmpty)
          'location_id': locationId,
        if (direction != null && direction.isNotEmpty) 'direction': direction,
        if (partyId != null && partyId.isNotEmpty) 'party_id': partyId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return PaymentAllocationReview.fromJson(_object(response.data));
  }

  @override
  Future<PaymentRecord> reallocatePayment({
    required String id,
    required List<Map<String, dynamic>> allocations,
    required String reason,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? const Uuid().v4();
    final response = await _dio.post<Object>(
      'payments/$id/reallocate/',
      data: {
        'allocations': allocations,
        'reason': reason,
        'idempotency_key': key,
      },
      options: Options(headers: {'Idempotency-Key': key}),
    );
    return PaymentRecord.fromJson(_object(response.data));
  }

  @override
  Future<ImportDryRun> previewImport({
    required String businessId,
    required CsvImportKind kind,
    required List<int> bytes,
    required String filename,
    required String duplicateStrategy,
  }) async {
    final response = await _uploadImport(
      businessId: businessId,
      kind: kind,
      bytes: bytes,
      filename: filename,
      duplicateStrategy: duplicateStrategy,
      dryRun: true,
    );
    return ImportDryRun.fromJson(_object(response.data));
  }

  @override
  Future<ImportJob> uploadImport({
    required String businessId,
    required CsvImportKind kind,
    required List<int> bytes,
    required String filename,
    required String duplicateStrategy,
  }) async {
    final response = await _uploadImport(
      businessId: businessId,
      kind: kind,
      bytes: bytes,
      filename: filename,
      duplicateStrategy: duplicateStrategy,
      dryRun: false,
    );
    return ImportJob.fromJson(_object(response.data));
  }

  Future<Response<Object>> _uploadImport({
    required String businessId,
    required CsvImportKind kind,
    required List<int> bytes,
    required String filename,
    required String duplicateStrategy,
    required bool dryRun,
  }) async {
    if (bytes.isEmpty || bytes.length > 2 * 1024 * 1024) {
      throw ArgumentError.value(
          bytes.length, 'bytes', 'CSV must be non-empty and at most 2 MB.');
    }
    final safeName = filename.replaceAll('\\', '/').split('/').last;
    if (!safeName.toLowerCase().endsWith('.csv') || safeName.length <= 4) {
      throw ArgumentError.value(filename, 'filename', 'Choose a .csv file.');
    }
    final strategy = duplicateStrategy.toUpperCase();
    if (strategy != 'UPDATE' && strategy != 'SKIP') {
      throw ArgumentError.value(
          duplicateStrategy, 'duplicateStrategy', 'Must be UPDATE or SKIP.');
    }
    final form = FormData.fromMap({
      'business_id': businessId,
      'file': MultipartFile.fromBytes(
        bytes,
        filename: safeName,
        contentType: DioMediaType('text', 'csv'),
      ),
      'dry_run': dryRun,
      'duplicate_strategy': strategy,
    });
    return _dio.post<Object>(
      kind == CsvImportKind.product ? 'imports/products/' : 'imports/parties/',
      data: form,
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  @override
  Future<List<ImportJob>> listImports({required String businessId}) async {
    final response = await _dio.get<Object>(
      'imports/',
      queryParameters: {'business_id': businessId},
    );
    return _rows(response.data).map(ImportJob.fromJson).toList(growable: false);
  }

  @override
  Future<ImportJob> fetchImport(String id) async {
    final response = await _dio.get<Object>('imports/$id/');
    return ImportJob.fromJson(_object(response.data));
  }

  @override
  Future<ImportConfirmation> confirmImport({
    required String id,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? 'import:$id';
    final response = await _dio.post<Object>(
      'imports/$id/confirm/',
      data: {'idempotency_key': key},
      options: Options(headers: {'Idempotency-Key': key}),
    );
    return ImportConfirmation.fromJson(_object(response.data));
  }

  @override
  Future<List<NotificationDevice>> listNotificationDevices() async {
    final response =
        await _dio.get<Object>('integrations/notifications/devices/');
    return _rows(response.data)
        .map(NotificationDevice.fromJson)
        .toList(growable: false);
  }

  @override
  Future<NotificationDevice> registerNotificationDevice({
    required String businessId,
    required String fcmToken,
    String? locationId,
    required String platform,
    Map<String, dynamic> metadata = const {},
  }) async {
    final response = await _dio.post<Object>(
      'integrations/notifications/devices/',
      data: {
        'business_id': businessId,
        if (locationId != null && locationId.isNotEmpty)
          'location_id': locationId,
        'fcm_token': fcmToken,
        'platform': platform.toUpperCase(),
        'metadata': metadata,
      },
    );
    return NotificationDevice.fromJson(_object(response.data));
  }

  @override
  Future<void> unregisterNotificationDevice(String id) async {
    await _dio.delete<Object>('integrations/notifications/devices/$id/');
  }

  @override
  Future<List<Reminder>> listReminders() async {
    final response =
        await _dio.get<Object>('integrations/notifications/reminders/');
    return _rows(response.data).map(Reminder.fromJson).toList(growable: false);
  }

  @override
  Future<Reminder> createReminder(Map<String, dynamic> payload) async {
    final response = await _dio.post<Object>(
      'integrations/notifications/reminders/',
      data: payload,
    );
    return Reminder.fromJson(_object(response.data));
  }

  @override
  Future<Reminder> updateReminder(
      String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Object>(
      'integrations/notifications/reminders/$id/',
      data: payload,
    );
    return Reminder.fromJson(_object(response.data));
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _dio.delete<Object>('integrations/notifications/reminders/$id/');
  }

  @override
  Future<List<ProposalSummary>> listProposals() async {
    final response = await _dio.get<Object>('assistant/proposals/');
    return _rows(response.data)
        .map(ProposalSummary.fromJson)
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> fetchProposal(String id) async {
    final response = await _dio.get<Object>('assistant/proposals/$id/');
    return _object(response.data);
  }

  @override
  Future<List<ProposalRevision>> fetchRevisions(String id) async {
    final response =
        await _dio.get<Object>('assistant/proposals/$id/revisions/');
    return _rows(response.data)
        .map(ProposalRevision.fromJson)
        .toList(growable: false);
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

  static String _safePdfFilename(String? contentDisposition, String saleId) {
    var candidate = 'invoice-$saleId.pdf';
    if (contentDisposition != null) {
      final match = RegExp(
        r'''filename\*?=(?:UTF-8''\s*)?"?([^";]+)"?''',
        caseSensitive: false,
      ).firstMatch(contentDisposition);
      if (match != null) {
        try {
          candidate = Uri.decodeComponent(match.group(1)!.trim());
        } on FormatException {
          candidate = match.group(1)!.trim();
        }
      }
    }
    final basename = candidate.replaceAll('\\', '/').split('/').last;
    final safe = basename
        .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._ -]'), '_')
        .replaceAll(RegExp(r'\.{2,}'), '_')
        .trim()
        .replaceAll(RegExp(r'^[. ]+|[. ]+$'), '');
    if (safe.isEmpty) return 'invoice-$saleId.pdf';
    return safe.toLowerCase().endsWith('.pdf') ? safe : '$safe.pdf';
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

  static BusinessEntry _entryFromJson(
      Map<String, dynamic> json, EntryType type) {
    final party = json['customer'] ?? json['supplier'] ?? json['party'];
    final partyName = party is Map
        ? party['name']
        : json['customer_name'] ?? json['supplier_name'] ?? json['party_name'];
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
      totalMinor: minorFromRecord(
        json,
        type == EntryType.expense
            ? 'total_minor'
            : type == EntryType.payment
                ? 'amount_minor'
                : 'grand_total_minor',
        type == EntryType.expense
            ? 'total'
            : type == EntryType.payment
                ? 'amount'
                : 'grand_total',
      ),
      pendingMinor: minorFromRecord(json, 'due_total_minor', 'due_amount'),
      occurredAt: DateTime.tryParse(
            (json['occurred_at'] ??
                    json['invoice_date'] ??
                    json['created_at'] ??
                    '')
                .toString(),
          ) ??
          DateTime.now(),
      reversed: json['status'] == 'REVERSED' || json['is_reversed'] == true,
    );
  }

  static AssistantProposal _proposalFromJson(Map<String, dynamic> json) =>
      AssistantProposal.fromJson(json);

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
