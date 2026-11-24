// The visual vocabulary shared with the React console.
//
// Every widget here maps to a class in apps/web/src/styles. Change a token and
// both clients move together; change a widget here and mirror it there.
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:flutter/material.dart';

/// Semantic colour roles. These are the names the CSS uses, so a reader can
/// move between the two codebases without translating.
enum DukaanTone { neutral, primary, positive, attention, danger }

/// Resolves a tone to its foreground and wash pair.
({Color ink, Color wash}) toneColors(DukaanTone tone) => switch (tone) {
      DukaanTone.neutral => (
          ink: DukaanTokens.colorInkMuted,
          wash: DukaanTokens.colorSurfaceSunken,
        ),
      DukaanTone.primary => (
          ink: DukaanTokens.colorPrimaryInk,
          wash: DukaanTokens.colorPrimaryWash,
        ),
      DukaanTone.positive => (
          ink: DukaanTokens.colorPositiveInk,
          wash: DukaanTokens.colorPositiveWash,
        ),
      DukaanTone.attention => (
          ink: DukaanTokens.colorAttentionInk,
          wash: DukaanTokens.colorAttentionWash,
        ),
      DukaanTone.danger => (
          ink: DukaanTokens.colorDangerInk,
          wash: DukaanTokens.colorDangerWash,
        ),
    };

/// A hairline-bordered surface. The single card shape in the app.
class DukaanCard extends StatelessWidget {
  const DukaanCard({
    required this.child,
    this.padding = const EdgeInsets.all(DukaanTokens.space4),
    this.onTap,
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(DukaanTokens.radiusCard);
    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: radius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: content,
              ),
            ),
    );
  }
}

/// A dark surface for the one thing on a screen that carries the most weight.
///
/// The folio proof block: kicker, display headline, ruled figures. Mirrors
/// `.ai-summary-card` and `.report-highlight` on web. One per screen.
class DukaanHeroCard extends StatelessWidget {
  const DukaanHeroCard({
    required this.child,
    this.padding = const EdgeInsets.all(DukaanTokens.space5),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DukaanTokens.colorHero,
        borderRadius: BorderRadius.circular(DukaanTokens.radiusPanel),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Muted text intended for use on a [DukaanHeroCard].
class DukaanHeroText extends StatelessWidget {
  const DukaanHeroText(this.text, {this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? DukaanTokens.textBody).copyWith(
        color: DukaanTokens.colorOnHero,
      ),
    );
  }
}

/// A section title with an optional trailing action.
///
/// The editorial folio: a numbered kicker, a headline, a ruled close. Mirrors
/// `.page-header` / `.register-section` headings on web.
class DukaanSectionHeader extends StatelessWidget {
  const DukaanSectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.kicker,
    this.ruled = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? kicker;
  final bool ruled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ruled)
          const Divider(height: 1, thickness: 2, color: DukaanTokens.colorInk),
        if (ruled) const SizedBox(height: DukaanTokens.space3),
        if (kicker != null) ...[
          DukaanKicker(kicker!),
          const SizedBox(height: DukaanTokens.space1),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: DukaanTokens.space1),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }
}

/// An editorial kicker: uppercase caption with a jade rule. Mirrors
/// `.folio-kicker` on web.
class DukaanKicker extends StatelessWidget {
  const DukaanKicker(this.text, {this.onHero = false, super.key});

  final String text;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final color =
        onHero ? DukaanTokens.colorHeroAccent : DukaanTokens.colorInkMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: DukaanTokens.space6,
          height: 2,
          color:
              onHero ? DukaanTokens.colorHeroAccent : DukaanTokens.colorPrimary,
        ),
        const SizedBox(width: DukaanTokens.space2),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: DukaanTokens.textCaption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// A metric figure: kicker label above, mono headline below, hairline beside.
///
/// Mirrors `.metric-card` on web, including the monospace figure so amounts
/// line up between the two clients. Jade stays rare: only the glyph carries
/// tone, never a tinted box.
class DukaanMetricTile extends StatelessWidget {
  const DukaanMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.hint,
    this.tone = DukaanTone.neutral,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? hint;
  final DukaanTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = toneColors(tone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.ink),
        const SizedBox(width: DukaanTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: DukaanTokens.textCaption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DukaanTokens.space2),
              Text(
                value,
                style: DukaanTokens.textAmountLarge
                    .copyWith(color: scheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hint != null) ...[
                const SizedBox(height: DukaanTokens.space1),
                Text(
                  hint!,
                  style: DukaanTokens.textCaption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A status pill. Mirrors `.status-badge`.
class DukaanBadge extends StatelessWidget {
  const DukaanBadge(
    this.label, {
    this.tone = DukaanTone.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final DukaanTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = toneColors(tone);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DukaanTokens.space2,
        vertical: DukaanTokens.space1,
      ),
      decoration: BoxDecoration(
        color: colors.wash,
        borderRadius: BorderRadius.circular(DukaanTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: colors.ink),
            const SizedBox(width: DukaanTokens.space1),
          ],
          Text(
            label.toUpperCase(),
            style: DukaanTokens.textCaption.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}

/// A single-line list row: leading slot, title, subtitle, trailing slot.
///
/// Replaces the five near-identical card/list widgets the pages each grew.
class DukaanListRow extends StatelessWidget {
  const DukaanListRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: DukaanTokens.space3),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: DukaanTokens.space3),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: DukaanTokens.textCaption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: DukaanTokens.space3),
            trailing!,
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider) Divider(height: 1, color: scheme.outlineVariant),
        if (onTap == null)
          row
        else
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap, child: row),
          ),
      ],
    );
  }
}

/// A square tone-tinted icon plate. Mirrors `.entry-kind-icon` and friends.
class DukaanIconPlate extends StatelessWidget {
  const DukaanIconPlate({
    required this.icon,
    this.tone = DukaanTone.primary,
    this.size = 34,
    this.iconSize = 17,
    super.key,
  });

  final IconData icon;
  final DukaanTone tone;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = toneColors(tone);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.wash,
        borderRadius: BorderRadius.circular(DukaanTokens.radiusControl),
      ),
      child: Icon(icon, size: iconSize, color: colors.ink),
    );
  }
}

/// A filter chip with two states: an underline ledger tab. Mirrors
/// `.tabs button` / `.tabs button.active`.
class DukaanFilterChip extends StatelessWidget {
  const DukaanFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        child: Container(
          constraints:
              const BoxConstraints(minHeight: DukaanTokens.sizeControlCompact),
          padding: const EdgeInsets.symmetric(
            horizontal: DukaanTokens.space1,
            vertical: DukaanTokens.space2,
          ),
          margin: const EdgeInsets.only(right: DukaanTokens.space3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? DukaanTokens.colorPrimaryStrong
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: DukaanTokens.textLabel.copyWith(
              color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// A money figure. Monospace with tabular figures so digits column up.
class DukaanMoney extends StatelessWidget {
  const DukaanMoney(
    this.text, {
    this.large = false,
    this.tone,
    this.semanticsLabel,
    super.key,
  });

  final String text;
  final bool large;
  final DukaanTone? tone;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final base = large ? DukaanTokens.textAmountLarge : DukaanTokens.textAmount;
    final color = tone == null
        ? Theme.of(context).colorScheme.onSurface
        : toneColors(tone!).ink;

    return Semantics(
      label: semanticsLabel,
      child: Text(text, style: base.copyWith(color: color)),
    );
  }
}

/// A labelled form control with an optional hint, matching `.form-grid label`.
class DukaanField extends StatelessWidget {
  const DukaanField({
    required this.label,
    required this.child,
    this.hint,
    super.key,
  });

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              DukaanTokens.textLabel.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: DukaanTokens.space1),
        child,
        if (hint != null) ...[
          const SizedBox(height: DukaanTokens.space1),
          Text(
            hint!,
            style: DukaanTokens.textCaption
                .copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// Text that belongs on the ink surface.
class DukaanHeroEyebrow extends StatelessWidget {
  const DukaanHeroEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: DukaanTokens.textCaption
          .copyWith(color: DukaanTokens.colorHeroAccent),
    );
  }
}

/// An empty state with an icon, title and explanation.
///
/// The folio empty: ruled kicker, display headline, measured guidance.
class DukaanEmptyState extends StatelessWidget {
  const DukaanEmptyState({
    required this.title,
    required this.detail,
    this.kicker = 'Nothing here yet',
    this.icon = Icons.inbox_rounded,
    super.key,
  });

  final String title;
  final String detail;
  final String kicker;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DukaanTokens.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: scheme.onSurfaceVariant),
            const SizedBox(height: DukaanTokens.space3),
            DukaanKicker(kicker),
            const SizedBox(height: DukaanTokens.space2),
            Text(
              title,
              style: DukaanTokens.textHeading.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DukaanTokens.space1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A status banner pinned under the app bar. Mirrors `.offline-banner`.
class DukaanBanner extends StatelessWidget {
  const DukaanBanner({
    required this.icon,
    required this.title,
    required this.detail,
    this.tone = DukaanTone.attention,
    super.key,
  });

  final IconData icon;
  final String title;
  final String detail;
  final DukaanTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = toneColors(tone);

    return Semantics(
      liveRegion: true,
      container: true,
      label: '$title. $detail',
      child: Container(
        width: double.infinity,
        color: colors.wash,
        padding: const EdgeInsets.symmetric(
          horizontal: DukaanTokens.space4,
          vertical: DukaanTokens.space2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.ink),
            const SizedBox(width: DukaanTokens.space3),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$title  ',
                  style: DukaanTokens.textLabel.copyWith(color: colors.ink),
                  children: [
                    TextSpan(
                      text: detail,
                      style: DukaanTokens.textLabel.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
