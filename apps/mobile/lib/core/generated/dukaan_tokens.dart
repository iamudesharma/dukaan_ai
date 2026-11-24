// GENERATED FILE — DO NOT EDIT. Source: packages/design-tokens/tokens.json. Regenerate: make tokens-generate

import 'package:flutter/material.dart';

/// Design tokens shared with the React console.
///
/// Values come from packages/design-tokens/tokens.json.
abstract final class DukaanTokens {
  // Fonts
  static const fontSansStack =
      '"Manrope", "NotoSansDevanagari", system-ui, -apple-system, "Segoe UI", sans-serif';
  static const fontSansFamily = 'Manrope';
  static const fontMonoStack =
      '"IBMPlexMono", ui-monospace, SFMono-Regular, Menlo, monospace';
  static const fontMonoFamily = 'IBMPlexMono';
  static const fontDevanagariStack = '"NotoSansDevanagari", sans-serif';
  static const fontDevanagariFamily = 'NotoSansDevanagari';

  // Colors
  static const colorCanvas = Color(0xFFF7F5F0);
  static const colorSurface = Color(0xFFFFFFFF);
  static const colorSurfaceSunken = Color(0xFFF2EFE9);
  static const colorLine = Color(0xFFE5E1D8);
  static const colorLineStrong = Color(0xFFD3CEC2);
  static const colorBorderControl = Color(0xFF828B82);
  static const colorInk = Color(0xFF16211B);
  static const colorInkMuted = Color(0xFF4E5952);
  static const colorInkFaint = Color(0xFF67716A);
  static const colorPrimary = Color(0xFF1B6B4C);
  static const colorPrimaryStrong = Color(0xFF14523A);
  static const colorPrimaryWash = Color(0xFFE6F0E9);
  static const colorPrimaryInk = Color(0xFF12442F);
  static const colorOnPrimary = Color(0xFFFFFFFF);
  static const colorPositive = Color(0xFF1B6B4C);
  static const colorPositiveWash = Color(0xFFE6F0E9);
  static const colorPositiveInk = Color(0xFF12442F);
  static const colorAttention = Color(0xFF8F5608);
  static const colorAttentionWash = Color(0xFFFAF0D9);
  static const colorAttentionInk = Color(0xFF6E4106);
  static const colorDanger = Color(0xFFA6392B);
  static const colorDangerWash = Color(0xFFFAE9E5);
  static const colorDangerInk = Color(0xFF7F2A1F);
  static const colorOnDanger = Color(0xFFFFFFFF);
  static const colorHero = Color(0xFF15211A);
  static const colorHeroRaised = Color(0xFF1E2C24);
  static const colorOnHero = Color(0xFFEEF3EE);
  static const colorOnHeroMuted = Color(0xFFA9B7AC);
  static const colorHeroAccent = Color(0xFF7CCFA6);
  static const colorFocusRing = Color(0xB81B6B4C);
  static const colorFocusRingOnHero = Color(0xFF7CCFA6);
  static const colorScrim = Color(0x850D1611);

  // Space
  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 20.0;
  static const space6 = 24.0;
  static const space8 = 32.0;
  static const space10 = 40.0;
  static const space12 = 48.0;
  static const space16 = 64.0;

  // Radius
  static const radiusXs = 6.0;
  static const radiusControl = 10.0;
  static const radiusCard = 14.0;
  static const radiusPanel = 18.0;
  static const radiusSheet = 22.0;
  static const radiusPill = 999.0;

  // Size
  static const sizeHit = 48.0;
  static const sizeControl = 44.0;
  static const sizeControlCompact = 36.0;
  static const sizeTile = 40.0;
  static const sizeAvatar = 36.0;
  static const sizeRailWidth = 264.0;
  static const sizeTopbar = 74.0;
  static const sizeBottomNav = 68.0;
  static const sizeContentMax = 1540.0;

  // Shadow
  static const List<BoxShadow> shadowRaised = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F16211B),
      offset: Offset(0.0, 1.0),
      blurRadius: 3.0,
      spreadRadius: 0.0,
    ),
  ];

  static const List<BoxShadow> shadowOverlay = <BoxShadow>[
    BoxShadow(
      color: Color(0x3316211B),
      offset: Offset(0.0, 18.0),
      blurRadius: 48.0,
      spreadRadius: -8.0,
    ),
  ];

  // Motion
  static const motionFast = Duration(milliseconds: 120);
  static const motionBase = Duration(milliseconds: 180);
  static const motionSlow = Duration(milliseconds: 260);
  static const motionEase = Cubic(0.2, 0.7, 0.3, 1);
  static const motionExitRatio = 0.7;

  // Type
  static const TextStyle textDisplay = TextStyle(
    fontFamily: fontSansFamily,
    fontFamilyFallback: <String>[fontDevanagariFamily],
    fontSize: 36.0,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.72,
  );

  static const TextStyle textTitle = TextStyle(
    fontFamily: fontSansFamily,
    fontFamilyFallback: <String>[fontDevanagariFamily],
    fontSize: 26.0,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.52,
  );

  static const TextStyle textHeading = TextStyle(
    fontFamily: fontSansFamily,
    fontFamilyFallback: <String>[fontDevanagariFamily],
    fontSize: 19.0,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.19,
  );

  static const TextStyle textSubhead = TextStyle(
    fontFamily: fontSansFamily,
    fontFamilyFallback: <String>[fontDevanagariFamily],
    fontSize: 17.0,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.00,
  );

  static const TextStyle textBody = TextStyle(
    fontFamily: fontSansFamily,
    fontFamilyFallback: <String>[fontDevanagariFamily],
    fontSize: 15.0,
    height: 1.55,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.00,
  );

  static const TextStyle textLabel = TextStyle(
    fontFamily: fontSansFamily,
    fontFamilyFallback: <String>[fontDevanagariFamily],
    fontSize: 13.0,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.13,
  );

  static const TextStyle textCaption = TextStyle(
    fontFamily: fontSansFamily,
    fontFamilyFallback: <String>[fontDevanagariFamily],
    fontSize: 11.0,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.88,
  );

  static const TextStyle textAmount = TextStyle(
    fontFamily: fontMonoFamily,
    fontSize: 15.0,
    height: 1.4,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.00,
  );

  static const TextStyle textAmountLarge = TextStyle(
    fontFamily: fontMonoFamily,
    fontSize: 22.0,
    height: 1.25,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.22,
  );
}
