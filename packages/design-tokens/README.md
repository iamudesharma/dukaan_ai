# Design tokens

`tokens.json` here is the only place a DukaanAI colour, type size, space step, radius, elevation or
duration is defined. Both clients are generated from it, so the Flutter app and the React console
cannot drift apart.

## Change a token

1. Edit `tokens.json`.
2. Run `make tokens-generate`.
3. Commit `tokens.json` and all three generated files together.

Generated outputs are committed so nobody needs to run the generator to build:

| Output | Consumed by |
| --- | --- |
| `apps/web/src/generated/tokens.css` | the web stylesheet, as `--color-*`, `--space-*`, `--type-*` custom properties |
| `apps/web/src/generated/tokens.ts` | web code that needs a value CSS variables cannot reach |
| `apps/mobile/lib/core/generated/dukaan_tokens.dart` | the Flutter theme, as `DukaanTokens.*` |

## Contrast is a build gate

`make tokens-generate` computes the WCAG contrast ratio for every pair listed under `contrast` in
`tokens.json` and **fails the build** below the required threshold. If you darken a wash or lighten
a border, the generator tells you before a user has to.

## Staleness

`make tokens-check` regenerates in memory and compares against the committed files. CI runs it, so a
token edit without a regeneration fails the build rather than shipping two different palettes.

Never edit a file under a `generated/` directory by hand.
