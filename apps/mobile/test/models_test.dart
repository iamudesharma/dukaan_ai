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
    expect(minorFromRecord({'unit_price_minor': 80000, 'unit_price': '800.00'}, 'unit_price_minor', 'unit_price'), 80000);
    expect(minorFromRecord({'unit_price': '800.00'}, 'unit_price_minor', 'unit_price'), 80000);
  });
}
