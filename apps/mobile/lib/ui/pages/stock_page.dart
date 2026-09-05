import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.t('stock'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              FilterChip(
                avatar: const Icon(Icons.warning_amber_rounded, size: 18),
                label: Text(context.strings.t('lowStock')),
                selected: _lowOnly,
                onSelected: (value) => setState(() => _lowOnly = value),
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
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                  children: [
                    _StockSummary(products: items),
                    const SizedBox(height: 14),
                    ...filtered.map((product) => _ProductCard(product: product)),
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

class _StockSummary extends StatelessWidget {
  const _StockSummary({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final low = products.where((product) => product.isLowStock).length;
    return Card(
      color: low > 0
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(low > 0 ? Icons.inventory_2_outlined : Icons.check_circle_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$low ${context.strings.t('lowStock').toLowerCase()} · '
                '${products.length} ${context.strings.t('products').toLowerCase()}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final stockText = '${product.stock} ${product.unit} ${context.strings.t('inStock')}';
    return Semantics(
      label: '${product.name}, $stockText${product.isLowStock ? ', ${context.strings.t('belowMinimum')}' : ''}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: product.isLowStock
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(
                    product.isLowStock
                        ? Icons.warning_amber_rounded
                        : Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text('${product.sku} · $stockText'),
                      if (product.isLowStock)
                        Text(
                          context.strings.t('belowMinimum'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(product.retailPriceMinor, locale),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${context.strings.t('wholesale')}: '
                      '${formatMoney(product.wholesalePriceMinor, locale)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

