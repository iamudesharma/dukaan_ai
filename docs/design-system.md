# Design system

DukaanAI ships two clients: the Flutter Android app in `apps/mobile` and the React console in
`apps/web`. They are one product in two form factors, and they are kept identical structurally
rather than by review.

## One source of truth

`packages/design-tokens/tokens.json` is the only place a colour, type size, space step, radius,
elevation or duration is defined. A generator emits three files from it:

| Output | Consumed by |
| --- | --- |
| `apps/web/src/generated/tokens.css` | the web stylesheet, as `--color-*`, `--space-*`, `--type-*` custom properties |
| `apps/web/src/generated/tokens.ts` | web code needing a value CSS variables cannot reach |
| `apps/mobile/lib/core/generated/dukaan_tokens.dart` | `apps/mobile/lib/core/theme.dart`, as `DukaanTokens.*` |

To change a design value:

```sh
# 1. edit packages/design-tokens/tokens.json
make tokens-generate
# 3. commit tokens.json and all three generated files together
```

Nothing under a `generated/` directory is edited by hand.

## Contrast is a build gate

`make tokens-generate` measures the WCAG contrast ratio for every pair declared under `contrast` in
`tokens.json` and **fails** below the required threshold, so a colour change cannot quietly make text
unreadable. Ratios are also asserted in `apps/mobile/test/design_system_test.dart`.

## Drift is a build gate

`make tokens-check` regenerates in memory and compares against the committed files. CI runs it in the
web job, and `packages/**` is in both the web and mobile path filters, so a token change exercises
both clients.

## Colour roles

Roles are named for meaning, not appearance, which is what lets the two clients stay aligned.

| Role | Meaning |
| --- | --- |
| `primary` | jade. Actions, brand, money in, settled |
| `positive` | money in and paid. Shares jade today, separate name so it can diverge |
| `attention` | amber. Udhaar, pending, low stock, offline. Not an error |
| `danger` | clay. Overdue, failures, destructive actions only |
| `hero` | deep ink. The sidebar, the AI summary, the business pulse |
| neutral (`surface`, `surfaceSunken`, `line`) | structure |

Money direction is carried by an arrow and a sign, never by hue alone. Owing a supplier is
`attention`, not `danger`, because it is an outstanding balance rather than a failure.

## Typography

Manrope (Latin UI), Noto Sans Devanagari (Hindi), IBM Plex Mono (amounts and quantities, with
tabular figures so columns align across clients). All three are self-hosted on both platforms;
licences are in `packages/design-tokens/font-licenses`.

Because Manrope has no Devanagari glyphs, every Latin text style carries the Devanagari family as a
`fontFamilyFallback`. Without it, Hindi silently renders from a device-dependent system font and the
two clients stop matching.

Regenerate the font files only when a family, weight or subset changes:

```sh
node packages/design-tokens/scripts/fetch-fonts.mjs
```

## Component vocabulary

Both clients name the same shapes. On web they are CSS classes in `apps/web/src/styles`; on mobile
they are widgets in `apps/mobile/lib/ui/components/dukaan_widgets.dart`.

| Concept | Web | Mobile |
| --- | --- | --- |
| Card | `.panel`, `.party-card` | `DukaanCard` |
| Ink surface | `.ai-summary-card`, `.report-highlight` | `DukaanHeroCard` |
| Metric | `.metric-card` | `DukaanMetricTile` |
| Status pill | `.status-badge` | `DukaanBadge` |
| List row | `.compact-entry`, `.team-list > div` | `DukaanListRow` |
| Tone plate | `.entry-kind-icon` | `DukaanIconPlate` |
| Filter | `.tabs button` | `DukaanFilterChip` |
| Money | `.amount-cell` | `DukaanMoney` |
| Empty state | `.empty-state` | `DukaanEmptyState` |
| Banner | `.offline-banner` | `DukaanBanner` |

Material roles on mobile are assigned explicitly from tokens. `ColorScheme.fromSeed` is deliberately
not used: it derives its own tonal palette, which cannot match the hand-picked values the web client
uses. Anything the app does not reference directly is still pointed at a token, so an unmapped role
lands on brand colour rather than a Material default.
