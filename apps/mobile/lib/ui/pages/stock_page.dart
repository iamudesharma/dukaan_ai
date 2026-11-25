import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  bool _lowOnly = false;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final showWholesale =
        ref.watch(currentBusinessRoleProvider).canUseWholesalePrices;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DukaanTokens.space4,
            DukaanTokens.space4,
            DukaanTokens.space4,
            DukaanTokens.space3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DukaanKicker('01 · ${context.strings.t('stock')}'),
              const SizedBox(height: DukaanTokens.space1),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.strings.t('stock'),
                      style: DukaanTokens.textDisplay.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  DukaanFilterChip(
                    label: context.strings.t('lowStock'),
                    selected: _lowOnly,
                    onSelected: () => setState(() => _lowOnly = !_lowOnly),
                  ),
                ],
              ),
              const SizedBox(height: DukaanTokens.space2),
              const Divider(
                height: 1,
                thickness: 2,
                color: DukaanTokens.colorInk,
              ),
            ],
          ),
        ),
        Expanded(
          child: products.when(
            loading: () => const LoadingContent(),
            error: (error, _) => ErrorContent(
              message: error.toString(),
              onRetry: () => ref.invalidate(productsProvider),
            ),
            data: (items) {
              final filtered = _lowOnly
                  ? items.where((product) => product.isLowStock).toList()
                  : items;
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(productsProvider);
                  await ref.read(productsProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    DukaanTokens.space4,
                    DukaanTokens.space1,
                    DukaanTokens.space4,
                    DukaanTokens.space6,
                  ),
                  children: [
                    _StockSummary(products: items),
                    const SizedBox(height: DukaanTokens.space4),
                    if (filtered.isEmpty)
                      DukaanEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: context.strings.t('noProducts'),
                        detail: context.strings.t('noProductsDetail'),
                      )
                    else
                      Column(
                        children: [
                          for (var i = 0; i < filtered.length; i++)
                            _ProductRow(
                              product: filtered[i],
                              showDivider: i > 0,
                              showWholesale: showWholesale,
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Low stock is attention, not failure, so the strip uses the attention tone
/// rather than the error red.
class _StockSummary extends StatelessWidget {
  const _StockSummary({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final low = products.where((product) => product.isLowStock).length;
    final tone = low > 0 ? DukaanTone.attention : DukaanTone.positive;
    final colors = toneColors(tone);

    return Container(
      padding: const EdgeInsets.all(DukaanTokens.space4),
      decoration: BoxDecoration(
        color: colors.wash,
        borderRadius: BorderRadius.circular(DukaanTokens.radiusCard),
      ),
      child: Row(
        children: [
          Icon(
            low > 0 ? Icons.inventory_2_outlined : Icons.check_circle_outline,
            size: 20,
            color: colors.ink,
          ),
          const SizedBox(width: DukaanTokens.space3),
          Expanded(
            child: Text(
              '$low ${context.strings.t('lowStock').toLowerCase()} · '
              '${products.length} ${context.strings.t('products').toLowerCase()}',
              style: DukaanTokens.textLabel.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    this.showDivider = true,
    this.showWholesale = true,
  });

  final Product product;
  final bool showDivider;
  final bool showWholesale;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final stockText =
        '${product.stock} ${product.unit} ${context.strings.t('inStock')}';

    return Semantics(
      label: '${product.name}, $stockText'
          '${product.isLowStock ? ', ${context.strings.t('belowMinimum')}' : ''}',
      child: DukaanListRow(
        showDivider: showDivider,
        leading: DukaanIconPlate(
          icon: product.isLowStock
              ? Icons.warning_amber_rounded
              : Icons.inventory_2_outlined,
          tone: product.isLowStock ? DukaanTone.attention : DukaanTone.primary,
        ),
        title: product.name,
        subtitle: '${product.sku} · $stockText',
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DukaanMoney(formatMoney(product.retailPriceMinor, locale)),
            if (showWholesale) ...[
              const SizedBox(height: DukaanTokens.space1),
              Text(
                '${context.strings.t('wholesale')} '
                '${formatMoney(product.wholesalePriceMinor, locale)}',
                style: DukaanTokens.textCaption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
