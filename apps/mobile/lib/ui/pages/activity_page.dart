import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kinds = ['all', 'transactions', 'team', 'assistant'];

String _kindLabel(BuildContext context, String kind) => switch (kind) {
      'transactions' => context.strings.t('filterTransactions'),
      'team' => context.strings.t('filterTeam'),
      'assistant' => context.strings.t('filterAssistant'),
      _ => context.strings.t('filterAll'),
    };

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  String _kind = 'all';
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final location = await ref.read(activeLocationProvider.future);
    return ref.read(repositoryProvider).fetchActivity(
          businessId: location.businessId,
          kind: _kind,
        );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(
            strings.t('activity'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(strings.t('activityDetail')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final kind in _kinds)
                ChoiceChip(
                  label: Text(_kindLabel(context, kind)),
                  selected: _kind == kind,
                  onSelected: (_) {
                    setState(() => _kind = kind);
                    _reload();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingContent();
              }
              if (snapshot.hasError) {
                return ErrorContent(
                  message: snapshot.error.toString(),
                  onRetry: _reload,
                );
              }
              final rows = snapshot.data?['results'];
              final items = rows is List ? rows.whereType<Map>().toList() : const [];
              if (items.isEmpty) return Text(strings.t('noActivity'));
              return Card(
                child: Column(
                  children: [
                    for (final item in items)
                      ListTile(
                        leading: const Icon(Icons.history_rounded),
                        title: Text(
                          (item['event_type'] ?? '').toString().replaceAll('.', ' · '),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${(item['actor_name'] ?? 'System').toString()} · ${(item['source'] ?? '').toString()}',
                        ),
                        trailing: Text(
                          (item['created_at'] ?? '').toString().substring(0, 10),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
