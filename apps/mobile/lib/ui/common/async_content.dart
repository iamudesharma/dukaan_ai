import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';

class LoadingContent extends StatelessWidget {
  const LoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: context.strings.t('loading'),
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}

class ErrorContent extends StatelessWidget {
  const ErrorContent({required this.onRetry, this.message, super.key});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DukaanTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DukaanIconPlate(
              icon: Icons.cloud_off_rounded,
              tone: DukaanTone.danger,
              size: 44,
              iconSize: 22,
            ),
            const SizedBox(height: DukaanTokens.space4),
            const DukaanKicker('Something broke'),
            const SizedBox(height: DukaanTokens.space2),
            Text(
              context.strings.t('loadFailed'),
              style: DukaanTokens.textHeading.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: DukaanTokens.space2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: DukaanTokens.space4),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.strings.t('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
