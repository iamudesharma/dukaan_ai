// Verifies the design-system wiring end to end:
//   - the generated token class agrees with the source tokens
//   - the theme is built from those tokens, not a generated seed palette
//   - every bundled font is actually resolvable from the asset bundle
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // rootBundle needs a binding before it can read packaged assets.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme is built from tokens, not a seed-derived palette', () {
    final theme = DukaanTheme.light();
    final scheme = theme.colorScheme;

    expect(scheme.primary, DukaanTokens.colorPrimary);
    expect(scheme.surface, DukaanTokens.colorSurface);
    expect(scheme.onSurface, DukaanTokens.colorInk);
    expect(scheme.error, DukaanTokens.colorDanger);
    // Attention maps onto tertiary so the offline and warning states share one
    // meaning across both clients.
    expect(scheme.tertiary, DukaanTokens.colorAttention);
    expect(scheme.tertiaryContainer, DukaanTokens.colorAttentionWash);
    expect(scheme.outlineVariant, DukaanTokens.colorLine);
    expect(theme.scaffoldBackgroundColor, DukaanTokens.colorCanvas);
  });

  test('the type scale is set from tokens', () {
    final theme = DukaanTheme.light();
    expect(theme.textTheme.headlineMedium?.fontSize, 26);
    expect(theme.textTheme.bodyLarge?.fontSize, 15);
    expect(theme.textTheme.labelSmall?.fontSize, 11);
    // Amounts are monospace so digits align with the web client.
    expect(DukaanTokens.textAmount.fontFamily, DukaanTokens.fontMonoFamily);
  });

  test('Latin styles fall back to the bundled Devanagari face', () {
    // Manrope has no Devanagari glyphs. Without this fallback on the style
    // itself, Hindi renders from a system font that differs per device and no
    // longer matches the web client.
    for (final style in [
      DukaanTokens.textDisplay,
      DukaanTokens.textTitle,
      DukaanTokens.textHeading,
      DukaanTokens.textSubhead,
      DukaanTokens.textBody,
      DukaanTokens.textLabel,
      DukaanTokens.textCaption,
    ]) {
      expect(
        style.fontFamilyFallback,
        contains(DukaanTokens.fontDevanagariFamily),
        reason: 'a Latin style is missing the Devanagari fallback',
      );
    }

    // Figures stay monospace, so they intentionally do not carry it.
    expect(DukaanTokens.textAmount.fontFamily, DukaanTokens.fontMonoFamily);
    expect(DukaanTokens.textAmount.fontFamilyFallback, isNull);
  });

  test('component themes use the token radii', () {
    final theme = DukaanTheme.light();
    final cardShape = theme.cardTheme.shape! as RoundedRectangleBorder;
    expect(
        cardShape.borderRadius, BorderRadius.circular(DukaanTokens.radiusCard));

    final navIndicator =
        theme.navigationBarTheme.indicatorShape! as RoundedRectangleBorder;
    expect(navIndicator.borderRadius,
        BorderRadius.circular(DukaanTokens.radiusControl));
  });

  test('every declared font resolves from the asset bundle', () async {
    // Devanagari carries the Hindi UI; Manrope the Latin UI; Plex Mono the
    // amounts. If a file is missing, a client silently falls back and the two
    // platforms stop matching.
    const assets = <String>[
      'assets/fonts/manrope-400.ttf',
      'assets/fonts/manrope-500.ttf',
      'assets/fonts/manrope-600.ttf',
      'assets/fonts/manrope-700.ttf',
      'assets/fonts/manrope-800.ttf',
      'assets/fonts/noto-devanagari-400.ttf',
      'assets/fonts/noto-devanagari-500.ttf',
      'assets/fonts/noto-devanagari-600.ttf',
      'assets/fonts/noto-devanagari-700.ttf',
      'assets/fonts/plex-mono-400.ttf',
      'assets/fonts/plex-mono-500.ttf',
    ];

    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(1000),
          reason: '$asset looks empty');
      final bytes = data.buffer.asUint8List();
      // sfnt version, confirming it is a real TrueType file and not a stub.
      final tag = String.fromCharCodes(bytes.sublist(0, 4));
      expect(
        tag == '\u0000\u0001\u0000\u0000' || tag == 'true' || tag == 'OTTO',
        isTrue,
        reason: '$asset is not a valid TrueType/OpenType file',
      );
    }
  });
}
