import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPageLayout extends StatelessWidget {
  const SettingsPageLayout({
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DukaanTokens.space4,
            DukaanTokens.space3,
            DukaanTokens.space4,
            DukaanTokens.space2,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: DukaanTokens.space1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: scheme.onSurface,
                              ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: DukaanTokens.space1),
                      Text(
                        subtitle!,
                        style: DukaanTokens.textCaption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
        const Divider(height: 1, thickness: 2, color: DukaanTokens.colorInk),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DukaanTokens.space4,
              DukaanTokens.space4,
              DukaanTokens.space4,
              DukaanTokens.space6,
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class ManagerOnlyGate extends StatelessWidget {
  const ManagerOnlyGate(
      {required this.allowed, required this.child, super.key});

  final bool allowed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (allowed) return child;
    return DukaanEmptyState(
      icon: Icons.lock_outline_rounded,
      title: context.strings.t('notAvailable'),
      detail: context.strings.t('managerOnly'),
    );
  }
}

class OwnerOnlyGate extends StatelessWidget {
  const OwnerOnlyGate({required this.allowed, required this.child, super.key});

  final bool allowed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (allowed) return child;
    return DukaanEmptyState(
      icon: Icons.lock_outline_rounded,
      title: context.strings.t('notAvailable'),
      detail: context.strings.t('ownerOnly'),
    );
  }
}
