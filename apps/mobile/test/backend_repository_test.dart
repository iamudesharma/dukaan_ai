import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/api_client.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('invitations use the owner endpoints and retain only the create token',
      () async {
    final adapter = _HandlerAdapter((options) {
      if (options.path == 'invitations/' && options.method == 'GET') {
        return _json({
          'results': [
            {
              'id': 'invitation-1',
              'business': 'business-1',
              'invitee_phone': '+919876543210',
              'role': 'CASHIER',
              'status': 'PENDING',
              'expires_at': '2026-12-01T10:00:00Z',
              'locations': ['location-1'],
            },
          ],
        });
      }
      if (options.path == 'invitations/' && options.method == 'POST') {
        return _json({
          'id': 'invitation-2',
          'business': 'business-1',
          'invitee_phone': '+919812345678',
          'role': 'MANAGER',
          'status': 'PENDING',
          'expires_at': '2026-12-01T10:00:00Z',
          'locations': ['location-1'],
          'token': 'raw-one-time-token-1234567890',
        }, statusCode: 201);
      }
      if (options.path == 'invitations/invitation-1/revoke/') {
        return _json({
          'id': 'invitation-1',
          'business': 'business-1',
          'invitee_phone': '+919876543210',
          'role': 'CASHIER',
          'status': 'REVOKED',
          'expires_at': '2026-12-01T10:00:00Z',
        });
      }
      if (options.path == 'invitations/accept/') {
        return _json({
          'id': 'invitation-2',
          'business': 'business-1',
          'invitee_phone': '+919812345678',
          'role': 'MANAGER',
          'status': 'ACCEPTED',
          'expires_at': '2026-12-01T10:00:00Z',
        });
      }
      throw StateError('Unexpected request ${options.method} ${options.path}');
    });
    final repository = ApiDukaanRepository(_dio(adapter));

    final listed = await repository.listInvitations(businessId: 'business-1');
    final created = await repository.createInvitation({
      'business': 'business-1',
      'invitee_phone': '+919812345678',
      'role': 'MANAGER',
      'locations': ['location-1'],
    });
    final revoked = await repository.revokeInvitation('invitation-1');
    final accepted = await repository.acceptInvitation(token: 'raw-token');

    expect(listed.single.locations, ['location-1']);
    expect(listed.single.token, isNull);
    expect(created.token, 'raw-one-time-token-1234567890');
    expect(revoked.status, 'REVOKED');
    expect(accepted.status, 'ACCEPTED');
    expect(adapter.requests[0].queryParameters['business_id'], 'business-1');
    expect(adapter.requests[1].data, {
      'business': 'business-1',
      'invitee_phone': '+919812345678',
      'role': 'MANAGER',
      'locations': ['location-1'],
    });
    expect(adapter.requests.last.data, {'token': 'raw-token'});
  });

  test('sale invoice uses authenticated bytes and a safe server filename',
      () async {
    final adapter = _HandlerAdapter((options) {
      expect(options.method, 'GET');
      expect(options.path, 'invoices/sales/sale-1/pdf/');
      expect(options.responseType, ResponseType.bytes);
      expect(options.headers['Authorization'], 'Bearer access-token');
      return ResponseBody.fromBytes(
        [0x25, 0x50, 0x44, 0x46, 0x2d, 0x31, 0x2e, 0x37],
        200,
        headers: {
          Headers.contentTypeHeader: ['application/pdf'],
          'content-disposition': [
            'attachment; filename="../../Invoice 001.pdf"',
          ],
        },
      );
    });
    final store = MemorySessionStore(
      access: 'access-token',
      refresh: 'refresh-token',
    );
    final dio = createDio(store)
      ..options.baseUrl = 'https://api.example.test/api/v1/'
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);

    final invoice =
        await ApiDukaanRepository(dio).fetchSaleInvoicePdf('sale-1');

    expect(invoice.bytes, [0x25, 0x50, 0x44, 0x46, 0x2d, 0x31, 0x2e, 0x37]);
    expect(invoice.filename, 'Invoice 001.pdf');
    expect(invoice.filename, isNot(contains('/')));
    expect(invoice.filename, isNot(contains('..')));
  });

  test(
      'CSV upload separates dry-run, job creation, and idempotent confirmation',
      () async {
    final adapter = _HandlerAdapter((options) {
      if (options.path == 'imports/products/') {
        final form = options.data! as FormData;
        final dryRun = form.fields
            .singleWhere((field) => field.key == 'dry_run')
            .value
            .toString();
        expect(
            form.fields
                .singleWhere((field) => field.key == 'business_id')
                .value,
            'business-1');
        expect(
            form.fields
                .singleWhere((field) => field.key == 'duplicate_strategy')
                .value,
            'UPDATE');
        expect(form.files.single.value.filename, 'products.csv');
        if (dryRun == 'true') {
          return _json({
            'dry_run': true,
            'kind': 'PRODUCT',
            'duplicate_strategy': 'UPDATE',
            'row_count': 2,
            'valid_row_count': 2,
            'error_count': 0,
            'created_count': 1,
            'updated_count': 1,
            'skipped_count': 0,
            'errors': [],
            'preview': [
              {'row': 2, 'action': 'CREATE'},
              {'row': 3, 'action': 'UPDATE'},
            ],
          });
        }
        return _json({
          'id': 'import-1',
          'business': 'business-1',
          'kind': 'PRODUCT',
          'status': 'READY',
          'duplicate_strategy': 'UPDATE',
          'row_count': 2,
          'valid_row_count': 2,
          'error_count': 0,
          'created_count': 0,
          'updated_count': 0,
          'skipped_count': 0,
          'errors': [],
          'original_filename': 'products.csv',
          'file_size_bytes': 12,
        }, statusCode: 201);
      }
      if (options.path == 'imports/import-1/confirm/') {
        expect(options.headers['Idempotency-Key'], 'import-key-1');
        expect(options.data, {'idempotency_key': 'import-key-1'});
        return _json({
          'replayed': false,
          'job': {
            'id': 'import-1',
            'business': 'business-1',
            'kind': 'PRODUCT',
            'status': 'COMPLETED',
            'duplicate_strategy': 'UPDATE',
            'row_count': 2,
            'valid_row_count': 2,
            'error_count': 0,
            'created_count': 1,
            'updated_count': 1,
            'skipped_count': 0,
            'errors': [],
            'original_filename': 'products.csv',
            'file_size_bytes': 12,
          },
        });
      }
      throw StateError('Unexpected request ${options.method} ${options.path}');
    });
    final repository = ApiDukaanRepository(_dio(adapter));

    final preview = await repository.previewImport(
      businessId: 'business-1',
      kind: CsvImportKind.product,
      bytes: utf8.encode('name\nShirt\nRice'),
      filename: 'products.csv',
      duplicateStrategy: 'UPDATE',
    );
    final job = await repository.uploadImport(
      businessId: 'business-1',
      kind: CsvImportKind.product,
      bytes: utf8.encode('name\nShirt\nRice'),
      filename: 'products.csv',
      duplicateStrategy: 'UPDATE',
    );
    final confirmed = await repository.confirmImport(
      id: job.id,
      idempotencyKey: 'import-key-1',
    );

    expect(preview.canPrepare, isTrue);
    expect(preview.preview.last.action, 'UPDATE');
    expect(job.status, 'READY');
    expect(confirmed.job.status, 'COMPLETED');
    expect(confirmed.job.createdCount, 1);
    expect(confirmed.replayed, isFalse);
  });

  test('valuation and allocation review preserve nullable integer paise',
      () async {
    final adapter = _HandlerAdapter((options) {
      if (options.path == 'reports/valuation/') {
        expect(options.queryParameters, {
          'business_id': 'business-1',
          'location_id': 'location-1',
          'date_from': '2026-11-01',
          'date_to': '2026-11-24',
        });
        return _json({
          'inventory': {
            'total_quantity': '2.5',
            'average_cost_minor': null,
            'total_value_minor': null,
            'known_value_minor': 12345,
            'costing_complete': false,
          },
          'sales': {
            'posted_sale_count': 1,
            'line_count': 1,
            'net_sales_minor': 50000,
            'cogs_minor': 30000,
            'gross_profit_minor': null,
            'missing_cost_line_count': 1,
            'costing_complete': false,
          },
          'results': [
            {
              'product_id': 'product-1',
              'name': 'Shirt',
              'unit': 'pcs',
              'quantity': '2.5',
              'average_cost_minor': null,
              'total_value_minor': null,
              'known_value_minor': 12345,
              'unknown_cost_quantity': '1.0',
              'costing_complete': false,
            },
          ],
        });
      }
      if (options.path == 'payments/allocation-review/') {
        return _json({
          'results': [
            {
              'id': 'payment-1',
              'business': 'business-1',
              'location': 'location-1',
              'party': 'party-1',
              'direction': 'RECEIPT',
              'method': 'CASH',
              'amount_minor': 10001,
              'status': 'POSTED',
              'allocated_total_minor': 5000,
              'unallocated_total_minor': 5001,
              'allocations': [
                {
                  'id': 'allocation-1',
                  'amount_minor': 5000,
                  'document_type': 'SALE',
                  'document_id': 'sale-1',
                  'document_number': 'INV-1',
                  'document_total_minor': 20000,
                  'document_paid_total_minor': 10000,
                  'document_due_total_minor': 10000,
                },
              ],
            },
          ],
          'totals': {
            'payment_count': 1,
            'payment_total_minor': 10001,
            'allocated_total_minor': 5000,
            'unallocated_total_minor': 5001,
            'outstanding_document_count': 1,
            'outstanding_total_minor': 10000,
          },
          'outstanding_documents': [
            {
              'document_type': 'SALE',
              'document_id': 'sale-1',
              'number': 'INV-1',
              'grand_total_minor': 20000,
              'paid_total_minor': 10000,
              'due_total_minor': 10000,
            },
          ],
        });
      }
      if (options.path == 'payments/payment-1/reallocate/') {
        expect(options.headers['Idempotency-Key'], 'reallocate-key');
        expect(options.data, {
          'allocations': [
            {
              'document_type': 'SALE',
              'document_id': 'sale-1',
              'amount_minor': 10001,
            },
          ],
          'reason': 'Correct invoice',
          'idempotency_key': 'reallocate-key',
        });
        return _json({
          'id': 'payment-1',
          'business': 'business-1',
          'location': 'location-1',
          'party': 'party-1',
          'direction': 'RECEIPT',
          'method': 'CASH',
          'amount_minor': 10001,
          'status': 'POSTED',
          'allocated_total_minor': 10001,
          'unallocated_total_minor': 0,
          'allocations': [
            {
              'id': 'allocation-2',
              'amount_minor': 10001,
              'document_type': 'SALE',
              'document_id': 'sale-1',
            },
          ],
        });
      }
      throw StateError('Unexpected request ${options.method} ${options.path}');
    });
    final repository = ApiDukaanRepository(_dio(adapter));

    final valuation = await repository.fetchValuationReport(
      businessId: 'business-1',
      locationId: 'location-1',
      dateFrom: '2026-11-01',
      dateTo: '2026-11-24',
    );
    final review = await repository.fetchPaymentAllocationReview(
      businessId: 'business-1',
      locationId: 'location-1',
      status: 'POSTED',
    );
    final payment = await repository.reallocatePayment(
      id: 'payment-1',
      allocations: [
        {
          'document_type': 'SALE',
          'document_id': 'sale-1',
          'amount_minor': 10001,
        },
      ],
      reason: 'Correct invoice',
      idempotencyKey: 'reallocate-key',
    );

    expect(valuation.inventory.totalValueMinor, isNull);
    expect(valuation.inventory.knownValueMinor, 12345);
    expect(valuation.sales.grossProfitMinor, isNull);
    expect(valuation.rows.single.unknownCostQuantity.toString(), '1');
    expect(review.payments.single.amountMinor, 10001);
    expect(review.payments.single.unallocatedTotalMinor, 5001);
    expect(review.outstandingDocuments.single.dueTotalMinor, 10000);
    expect(payment.allocatedTotalMinor, 10001);
  });

  test('reminders and notification devices use their exact integration paths',
      () async {
    final adapter = _HandlerAdapter((options) {
      if (options.path == 'integrations/notifications/reminders/' &&
          options.method == 'GET') {
        return _json([
          {
            'id': 'reminder-1',
            'business': 'business-1',
            'title': 'Call supplier',
            'body': 'Confirm stock',
            'scheduled_at': '2026-12-01T10:00:00Z',
            'status': 'SCHEDULED',
          },
        ]);
      }
      if (options.path == 'integrations/notifications/reminders/' &&
          options.method == 'POST') {
        return _json({
          'id': 'reminder-2',
          'business': 'business-1',
          'location': 'location-1',
          'title': 'Call supplier',
          'body': 'Confirm stock',
          'scheduled_at': '2026-12-01T10:00:00Z',
          'status': 'SCHEDULED',
        }, statusCode: 201);
      }
      if (options.path == 'integrations/notifications/reminders/reminder-2/' &&
          options.method == 'PATCH') {
        return _json({
          'id': 'reminder-2',
          'business': 'business-1',
          'title': 'Updated title',
          'body': 'Confirm stock',
          'scheduled_at': '2026-12-01T10:00:00Z',
          'status': 'SCHEDULED',
        });
      }
      if (options.path == 'integrations/notifications/reminders/reminder-2/' &&
          options.method == 'DELETE') {
        return ResponseBody.fromString('', 204);
      }
      if (options.path == 'integrations/notifications/devices/' &&
          options.method == 'GET') {
        return _json([
          {
            'id': 'device-1',
            'business': 'business-1',
            'platform': 'ANDROID',
            'status': 'ACTIVE',
            'token_suffix': '…1234',
          },
        ]);
      }
      if (options.path == 'integrations/notifications/devices/device-1/' &&
          options.method == 'DELETE') {
        return ResponseBody.fromString('', 204);
      }
      throw StateError('Unexpected request ${options.method} ${options.path}');
    });
    final repository = ApiDukaanRepository(_dio(adapter));

    final reminders = await repository.listReminders();
    final created = await repository.createReminder({
      'business_id': 'business-1',
      'location_id': 'location-1',
      'title': 'Call supplier',
      'body': 'Confirm stock',
      'scheduled_at': '2026-12-01T10:00:00Z',
    });
    final updated = await repository.updateReminder(
      created.id,
      {'title': 'Updated title'},
    );
    await repository.deleteReminder(created.id);
    final devices = await repository.listNotificationDevices();
    await repository.unregisterNotificationDevice('device-1');

    expect(reminders.single.title, 'Call supplier');
    expect(updated.title, 'Updated title');
    expect(devices.single.tokenSuffix, '…1234');
    expect(adapter.requests[2].method, 'PATCH');
    expect(adapter.requests[3].method, 'DELETE');
  });

  test('all-device revocation sends the backend current_password field',
      () async {
    final adapter = _HandlerAdapter((options) {
      expect(options.path, 'auth/sessions/revoke-all/');
      expect(options.method, 'POST');
      expect(options.data, {'current_password': 'secret-password'});
      return _json({'detail': 'All sessions have been revoked.'});
    });
    final repository = ApiDukaanRepository(_dio(adapter));

    await repository.revokeAllSessions(currentPassword: 'secret-password');

    expect(adapter.requests, hasLength(1));
  });
}

Dio _dio(HttpClientAdapter adapter) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.test/api/v1/',
      responseType: ResponseType.json,
    ),
  )..httpClientAdapter = adapter;
  addTearDown(dio.close);
  return dio;
}

ResponseBody _json(Object data, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class _HandlerAdapter implements HttpClientAdapter {
  _HandlerAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) {
      await requestStream.drain<void>();
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
