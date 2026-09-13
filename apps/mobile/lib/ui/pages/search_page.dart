import 'dart:async';

import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  Future<Map<String, dynamic>>? _future;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _future = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _future = ref.read(repositoryProvider).searchAll(value.trim()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(
          strings.t('searchTitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: strings.t('searchHint'),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: strings.t('close'),
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      _onChanged('');
                    },
                  ),
          ),
          onChanged: (_) {
            setState(() {});
            _onChanged(_controller.text);
          },
        ),
        const SizedBox(height: 12),
        if (_future == null)
          Text(strings.t('searchHelp'))
        else
          FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingContent();
              }
              if (snapshot.hasError) {
                return ErrorContent(
                  message: snapshot.error.toString(),
                  onRetry: () => _onChanged(_controller.text),
                );
              }
              final results = snapshot.data?['results'];
              final map = results is Map ? results : const {};
              final parties = (map['parties'] is List ? map['parties'] as List : const [])
                  .whereType<Map>()
                  .toList();
              final products = (map['products'] is List ? map['products'] as List : const [])
                  .whereType<Map>()
                  .toList();
              final documents =
                  (map['documents'] is List ? map['documents'] as List : const [])
                      .whereType<Map>()
                      .toList();
              if (parties.isEmpty && products.isEmpty && documents.isEmpty) {
                return Text(strings.t('noSearchResults'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (parties.isNotEmpty) ...[
                    _Heading(text: strings.t('parties')),
                    Card(
                      child: Column(
                        children: [
                          for (final party in parties)
                            ListTile(
                              leading: const Icon(Icons.person_outline_rounded),
                              title: Text((party['name'] ?? '').toString()),
                              subtitle: Text((party['kind'] ?? '').toString().toLowerCase()),
                              onTap: () => context.go('/parties'),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (products.isNotEmpty) ...[
                    _Heading(text: strings.t('stock')),
                    Card(
                      child: Column(
                        children: [
                          for (final product in products)
                            ListTile(
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text((product['name'] ?? '').toString()),
                              subtitle: Text((product['sku'] ?? '').toString()),
                              onTap: () => context.go('/stock'),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (documents.isNotEmpty) ...[
                    _Heading(text: strings.t('entries')),
                    Card(
                      child: Column(
                        children: [
                          for (final document in documents)
                            ListTile(
                              leading: const Icon(Icons.receipt_long_outlined),
                              title: Text((document['number'] ?? '').toString()),
                              subtitle: Text((document['party'] ?? '').toString()),
                              onTap: () => context.go('/entries'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      );
}
