import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sale draft keeps paise amounts exact in API payload', () {
    final draft = SaleDraft(
      id: 'draft-1',
      businessId: 'business-1',
      locationId: 'location-1',
      customerId: 'party-1',
      customerName: 'Ramesh',
      lines: [
        SaleLineDraft(
          productId: 'product-1',
          packId: 'pack-1',
          productName: 'Shirt',
          quantity: Decimal.parse('3'),
          unitPriceMinor: 80000,
        ),
      ],
      paidAmountMinor: 150000,
      priceMode: PriceMode.retail,
      paymentMethod: PaymentMethod.cash,
    );

    expect(draft.totalMinor, 240000);
    expect(draft.pendingMinor, 90000);
    expect(
      draft.toApiJson('key-1'),
      containsPair('paid_amount_minor', 150000),
    );
    expect(draft.toApiJson('key-1')['lines'], [
      {'pack_id': 'pack-1', 'quantity': '3', 'unit_price_minor': 80000},
    ]);
  });

  test('local sale draft round-trips paise without binary floating point', () {
    final original = SaleDraft(
      id: 'draft-2',
      businessId: 'business-1',
      locationId: 'location-1',
      lines: [
        SaleLineDraft(
          productId: 'product-1',
          packId: 'pack-1',
          productName: 'Rice',
          quantity: Decimal.parse('1.25'),
          unitPriceMinor: 7240,
        ),
      ],
      paidAmountMinor: 5000,
      priceMode: PriceMode.wholesale,
      paymentMethod: PaymentMethod.upi,
    );

    final restored = SaleDraft.fromLocalJson(original.toLocalJson());

    expect(restored.totalMinor, 9050);
    expect(restored.pendingMinor, 4050);
    expect(restored.priceMode, PriceMode.wholesale);
    expect(restored.paymentMethod, PaymentMethod.upi);
  });

  test('minor helpers prefer explicit paise fields over rupee decimals', () {
    expect(minorFrom(150000), 150000);
    expect(minorFrom('240000'), 240000);
    expect(
        minorFromRecord({'unit_price_minor': 80000, 'unit_price': '800.00'},
            'unit_price_minor', 'unit_price'),
        80000);
    expect(
        minorFromRecord(
            {'unit_price': '800.00'}, 'unit_price_minor', 'unit_price'),
        80000);
  });

  group('DashboardSummary.fromJson', () {
    test('parses the nested backend contract and prefers explicit minor fields',
        () {
      final summary = DashboardSummary.fromJson({
        'today': {'sales_minor': 245050, 'expenses_minor': 12345},
        'books': {'receivable_minor': 90000, 'payable_minor': 45000},
        'low_stock_count': 3,
        'as_of': '2026-11-24',
        'summary': 'A steady day.',
        // Conflicting legacy values must not override the canonical fields.
        'sales_today': 1,
        'expenses_today': 2,
        'receivables': 3,
        'payables': 4,
        'ai_summary': 'Old summary.',
      });

      expect(summary.salesMinor, 245050);
      expect(summary.expensesMinor, 12345);
      expect(summary.toReceiveMinor, 90000);
      expect(summary.toPayMinor, 45000);
      expect(summary.lowStockCount, 3);
      expect(summary.asOf, DateTime(2026, 11, 24));
      expect(summary.summary, 'A steady day.');
    });

    test('keeps explicit zeroes instead of falling back to legacy values', () {
      final summary = DashboardSummary.fromJson({
        'today': {'sales_minor': 0, 'expenses_minor': 0},
        'books': {'receivable_minor': 0, 'payable_minor': 0},
        'sales_today': 999,
        'expenses_today': 999,
        'receivables': 999,
        'payables': 999,
      });

      expect(summary.salesMinor, 0);
      expect(summary.expensesMinor, 0);
      expect(summary.toReceiveMinor, 0);
      expect(summary.toPayMinor, 0);
    });

    test(
        'uses legacy flat and older nested fields only when canonical keys are absent',
        () {
      final flat = DashboardSummary.fromJson({
        'sales_today': 1000,
        'expenses_today': 2000,
        'receivables': 3000,
        'to_pay': 4000,
        'low_stock_count': '5',
        'ai_summary': 'Legacy summary.',
      });
      final nested = DashboardSummary.fromJson({
        'today': {'sales': 6000, 'expenses': 7000},
        'books': {'receivable': 8000, 'payable': 9000},
      });

      expect(flat.salesMinor, 1000);
      expect(flat.expensesMinor, 2000);
      expect(flat.toReceiveMinor, 3000);
      expect(flat.toPayMinor, 4000);
      expect(flat.lowStockCount, 5);
      expect(flat.summary, 'Legacy summary.');
      expect(nested.salesMinor, 6000);
      expect(nested.expensesMinor, 7000);
      expect(nested.toReceiveMinor, 8000);
      expect(nested.toPayMinor, 9000);
    });
  });

  group('catalog models', () {
    test('Product parses stock_quantity without losing decimal precision', () {
      final product = Product.fromJson({
        'id': 'product-1',
        'default_pack_id': 'pack-1',
        'name': 'Rice',
        'sku': 'RICE-5KG',
        'unit': 'kg',
        'stock_quantity': '12.500',
        'stock': '99',
        'low_stock_threshold': '2.5',
        'retail_price_minor': 32000,
        'wholesale_price_minor': 30000,
      });

      expect(product.stock, Decimal.parse('12.500'));
      expect(product.lowStockAt, Decimal.parse('2.5'));
      expect(product.isLowStock, isFalse);
      expect(product.retailPriceMinor, 32000);
      expect(product.wholesalePriceMinor, 30000);
    });

    test(
        'Party parses phone_e164 and canonical receivable/payable minor fields',
        () {
      final party = Party.fromJson({
        'id': 'party-1',
        'name': 'Sharma Wholesale',
        'kind': 'SUPPLIER',
        'phone_e164': '+919876543210',
        'phone': '+911111111111',
        'receivable_minor': 12345,
        'payable_minor': 67890,
        'to_receive_minor': 1,
        'to_pay_minor': 2,
      });

      expect(party.phone, '+919876543210');
      expect(party.kind, PartyKind.supplier);
      expect(party.toReceiveMinor, 12345);
      expect(party.toPayMinor, 67890);
    });

    test('Party retains legacy phone and balance fallbacks', () {
      final party = Party.fromJson({
        'id': 'party-2',
        'phone': '+919812345678',
        'to_receive_minor': 5000,
        'payable_balance': '250.50',
      });

      expect(party.phone, '+919812345678');
      expect(party.toReceiveMinor, 5000);
      expect(party.toPayMinor, 25050);
    });
  });

  group('identity, role, and draft scope', () {
    test('CurrentUser parses the /me membership contract', () {
      final user = CurrentUser.fromJson({
        'id': 'user-1',
        'phone': '+919876543210',
        'display_name': 'Ramesh',
        'memberships': [
          {
            'business_id': 'business-1',
            'business_name': 'Gupta Traders',
            'role': 'CASHIER',
          },
        ],
      });

      expect(user.id, 'user-1');
      expect(user.memberships.single.businessId, 'business-1');
      expect(user.memberships.single.role, BusinessRole.cashier);
    });

    test('bootstrap exposes OWNER, MANAGER, and CASHIER roles', () {
      BusinessBootstrap bootstrap(String role) => BusinessBootstrap.fromJson({
            'user': {'id': 'user-1', 'role': role},
            'business': {'id': 'business-1'},
          });

      expect(bootstrap('OWNER').role, BusinessRole.owner);
      expect(bootstrap('MANAGER').role, BusinessRole.manager);
      expect(bootstrap('CASHIER').role, BusinessRole.cashier);
      expect(bootstrap('unexpected').role, BusinessRole.cashier);
      expect(BusinessRole.cashier.canConfirmAssistantCommand('SALE'), isTrue);
      expect(
          BusinessRole.cashier.canConfirmAssistantCommand('PURCHASE'), isFalse);
      expect(
          BusinessRole.manager.canConfirmAssistantCommand('EXPENSE'), isTrue);
      expect(BusinessRole.cashier.canUsePriceMode(PriceMode.retail), isTrue);
      expect(
          BusinessRole.cashier.canUsePriceMode(PriceMode.wholesale), isFalse);
      expect(BusinessRole.owner.canUsePriceMode(PriceMode.wholesale), isTrue);
    });

    test('LocalDraft requires and checks both user and business scope', () {
      final draft = LocalDraft(
        id: 'draft-1',
        kind: DraftKind.sale,
        userId: 'user-1',
        businessId: 'business-1',
        locationId: 'location-1',
        label: 'Sale',
        payload: const {},
        createdAt: DateTime.utc(2026, 1, 1),
      );

      expect(
          draft.belongsTo(userId: 'user-1', businessId: 'business-1'), isTrue);
      expect(
          draft.belongsTo(userId: 'user-2', businessId: 'business-1'), isFalse);
      expect(
          draft.belongsTo(userId: 'user-1', businessId: 'business-2'), isFalse);
    });
  });

  group('AssistantProposal', () {
    Map<String, dynamic> salePayload() => {
          'business_id': 'business-1',
          'location_id': 'location-1',
          'new_customer_name': 'Ramesh',
          'invoice_date': '2026-11-24',
          'price_mode': 'RETAIL',
          'discount_total_minor': 0,
          'lines': [
            {
              'pack_id': 'pack-1',
              'quantity': '3',
              'unit_price_minor': 80000,
              'discount_minor': 0,
            },
          ],
          'paid_amount_minor': 150000,
          'payment_method': 'CASH',
        };

    test('carries status and command type through serialization', () {
      final original = AssistantProposal.fromJson({
        'id': 'proposal-1',
        'version': 3,
        'status': 'READY',
        'command_type': 'SALE',
        'title': 'Sale to Ramesh',
        'warnings': ['A new customer will be created.'],
        'blocking_questions': [],
        'payload': salePayload(),
      });
      final restored = AssistantProposal.fromJson(original.toJson());

      expect(original.status, 'READY');
      expect(original.commandType, 'SALE');
      expect(original.canConfirm, isTrue);
      expect(restored.status, 'READY');
      expect(restored.commandType, 'SALE');
      expect(restored.version, 3);
      expect(restored.rawPayload, salePayload());
    });

    test('canConfirm requires READY, a supported command, and no blockers', () {
      AssistantProposal proposal(
          {String status = 'READY',
          String command = 'SALE',
          List<String>? questions}) {
        return AssistantProposal.fromJson({
          'id': 'proposal-1',
          'status': status,
          'command_type': command,
          'blocking_questions': questions ?? [],
          'payload': const {},
        });
      }

      for (final command in ['SALE', 'PURCHASE', 'EXPENSE']) {
        expect(proposal(command: command).canConfirm, isTrue, reason: command);
      }
      for (final status in ['DRAFT', 'CONFIRMED', 'CANCELLED', 'EXPIRED', '']) {
        expect(proposal(status: status).canConfirm, isFalse,
            reason: 'status $status');
      }
      for (final command in ['PAYMENT', 'TRANSFER', 'UNSUPPORTED', '']) {
        expect(proposal(command: command).canConfirm, isFalse,
            reason: 'command $command');
      }
      expect(proposal(questions: ['Who is the customer?']).canConfirm, isFalse);
    });

    test('derives sale review facts from payload when preview is a string', () {
      final preview =
          'Sale to Ramesh: 3 Shirt for ₹2,400; ₹1,500 paid and ₹900 pending.';
      final proposal = AssistantProposal.fromJson({
        'id': 'proposal-1',
        'status': 'READY',
        'command_type': 'SALE',
        'preview': preview,
        'warnings': [],
        'blocking_questions': [],
        'payload': salePayload(),
      });
      final facts = {for (final fact in proposal.facts) fact.label: fact.value};

      expect(proposal.title, preview);
      expect(facts['Customer'], 'Ramesh');
      expect(facts['Items'], '3');
      expect(facts['Total'], '₹2,400');
      expect(facts['Paid'], '₹1,500');
      expect(facts['Pending'], '₹900');
      expect(facts['Payment method'], 'Cash');
      expect(facts['Date'], '2026-11-24');
    });

    test('derives purchase and expense facts from their payload shapes', () {
      final purchase = AssistantProposal.fromJson({
        'id': 'proposal-2',
        'status': 'READY',
        'command_type': 'PURCHASE',
        'preview': 'Purchase from Sharma Suppliers.',
        'payload': {
          'new_supplier_name': 'Sharma Suppliers',
          'purchase_date': '2026-11-23',
          'discount_total_minor': 1000,
          'lines': [
            {
              'quantity': '2.5',
              'unit_cost_minor': 40000,
              'discount_minor': 500
            },
          ],
          'paid_amount_minor': 50000,
          'payment_method': 'UPI',
        },
      });
      final expense = AssistantProposal.fromJson({
        'id': 'proposal-3',
        'status': 'READY',
        'command_type': 'EXPENSE',
        'preview': "Expense 'Electricity' of ₹1,200.",
        'payload': {
          'category': 'Electricity',
          'payee': 'Power Board',
          'amount_minor': 120000,
          'payment_method': 'CASH',
          'expense_date': '2026-11-24',
        },
      });
      final purchaseFacts = {
        for (final fact in purchase.facts) fact.label: fact.value
      };
      final expenseFacts = {
        for (final fact in expense.facts) fact.label: fact.value
      };

      expect(purchaseFacts['Supplier'], 'Sharma Suppliers');
      expect(purchaseFacts['Items'], '2.5');
      expect(purchaseFacts['Total'], '₹985');
      expect(purchaseFacts['Paid'], '₹500');
      expect(purchaseFacts['Pending'], '₹485');
      expect(purchaseFacts['Payment method'], 'UPI');
      expect(expenseFacts['Category'], 'Electricity');
      expect(expenseFacts['Payee'], 'Power Board');
      expect(expenseFacts['Amount'], '₹1,200');
    });

    test(
        'keeps explicit structured preview facts instead of deriving duplicates',
        () {
      final proposal = AssistantProposal.fromJson({
        'id': 'proposal-4',
        'status': 'DRAFT',
        'command_type': 'SALE',
        'preview': {
          'title': 'Sale to Ramesh',
          'facts': [
            {'label': 'Total', 'value': '₹2,400', 'warning': false},
          ],
        },
        'blocking_questions': ['Confirm the customer.'],
        'payload': salePayload(),
      });

      expect(proposal.title, 'Sale to Ramesh');
      expect(proposal.facts, hasLength(1));
      expect(proposal.facts.single.label, 'Total');
      expect(proposal.canConfirm, isFalse);
    });
  });
}
