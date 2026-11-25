import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:flutter/material.dart';

/// The DukaanAI theme, built directly from the shared design tokens.
///
/// The colour scheme is assigned role by role rather than generated from a
/// seed. [ColorScheme.fromSeed] derives its own tonal palette, which would
/// never match the hand-picked values the React console uses. Every role below
/// maps to an explicit token so the two clients stay identical.
abstract final class DukaanTheme {
  /// Kept for callers that still reference the old name.
  static const seed = DukaanTokens.colorPrimary;
  static const warmSurface = DukaanTokens.colorCanvas;

  /// Explicit mapping of tokens onto Material roles.
  ///
  /// Anything the app does not reference directly is pointed at a token anyway,
  /// so a widget that reaches for an unmapped role still lands on brand colour
  /// rather than a Material default.
  static const ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,

    // Brand
    primary: DukaanTokens.colorPrimary,
    onPrimary: DukaanTokens.colorOnPrimary,
    primaryContainer: DukaanTokens.colorPrimaryWash,
    onPrimaryContainer: DukaanTokens.colorPrimaryInk,
    primaryFixed: DukaanTokens.colorPrimaryWash,
    primaryFixedDim: DukaanTokens.colorPrimaryWash,
    onPrimaryFixed: DukaanTokens.colorPrimaryInk,
    onPrimaryFixedVariant: DukaanTokens.colorPrimaryInk,

    // Secondary reads as quiet structure, not a second brand colour.
    secondary: DukaanTokens.colorInkMuted,
    onSecondary: DukaanTokens.colorOnPrimary,
    secondaryContainer: DukaanTokens.colorSurfaceSunken,
    onSecondaryContainer: DukaanTokens.colorInk,
    secondaryFixed: DukaanTokens.colorSurfaceSunken,
    secondaryFixedDim: DukaanTokens.colorSurfaceSunken,
    onSecondaryFixed: DukaanTokens.colorInk,
    onSecondaryFixedVariant: DukaanTokens.colorInkMuted,

    // Tertiary carries attention: udhaar, pending, low stock, offline.
    tertiary: DukaanTokens.colorAttention,
    onTertiary: DukaanTokens.colorOnPrimary,
    tertiaryContainer: DukaanTokens.colorAttentionWash,
    onTertiaryContainer: DukaanTokens.colorAttentionInk,
    tertiaryFixed: DukaanTokens.colorAttentionWash,
    tertiaryFixedDim: DukaanTokens.colorAttentionWash,
    onTertiaryFixed: DukaanTokens.colorAttentionInk,
    onTertiaryFixedVariant: DukaanTokens.colorAttentionInk,

    // Error is reserved for genuine failure.
    error: DukaanTokens.colorDanger,
    onError: DukaanTokens.colorOnDanger,
    errorContainer: DukaanTokens.colorDangerWash,
    onErrorContainer: DukaanTokens.colorDangerInk,

    // Surfaces
    surface: DukaanTokens.colorSurface,
    onSurface: DukaanTokens.colorInk,
    onSurfaceVariant: DukaanTokens.colorInkMuted,
    surfaceContainerLowest: DukaanTokens.colorSurface,
    surfaceContainerLow: DukaanTokens.colorSurface,
    surfaceContainer: DukaanTokens.colorSurfaceSunken,
    surfaceContainerHigh: DukaanTokens.colorSurfaceSunken,
    surfaceContainerHighest: DukaanTokens.colorSurfaceSunken,
    surfaceDim: DukaanTokens.colorCanvas,
    surfaceBright: DukaanTokens.colorSurface,
    surfaceTint: Colors.transparent,
    inverseSurface: DukaanTokens.colorHero,
    onInverseSurface: DukaanTokens.colorOnHero,
    inversePrimary: DukaanTokens.colorHeroAccent,

    // Lines
    outline: DukaanTokens.colorBorderControl,
    outlineVariant: DukaanTokens.colorLine,

    // Scrims and shadows
    scrim: DukaanTokens.colorScrim,
    shadow: DukaanTokens.colorInk,
  );

  /// The type scale. Sizes come from the tokens, so web and mobile agree.
  ///
  /// Light-on-dark roles get slightly more weight and tracking to compensate
  /// for optical thinning, which is why the hero styles are not plain copies.
  static const TextTheme textTheme = TextTheme(
    displaySmall: DukaanTokens.textDisplay,
    headlineMedium: DukaanTokens.textTitle,
    headlineSmall: DukaanTokens.textHeading,
    titleLarge: DukaanTokens.textSubhead,
    titleMedium: DukaanTokens.textSubhead,
    titleSmall: DukaanTokens.textLabel,
    bodyLarge: DukaanTokens.textBody,
    bodyMedium: DukaanTokens.textBody,
    bodySmall: DukaanTokens.textLabel,
    labelLarge: DukaanTokens.textLabel,
    labelMedium: DukaanTokens.textLabel,
    labelSmall: DukaanTokens.textCaption,
  );

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: DukaanTokens.colorCanvas,
      canvasColor: DukaanTokens.colorCanvas,
      dividerColor: DukaanTokens.colorLine,
      dividerTheme: const DividerThemeData(
        color: DukaanTokens.colorLine,
        thickness: 1,
        space: 1,
      ),
      fontFamily: DukaanTokens.fontSansFamily,
      // Hindi resolves through Manrope's fallback to the bundled Devanagari
      // face, so a mixed Hinglish string renders in one pass.
      fontFamilyFallback: const <String>[DukaanTokens.fontDevanagariFamily],
      visualDensity: VisualDensity.standard,

      appBarTheme: const AppBarTheme(
        backgroundColor: DukaanTokens.colorCanvas,
        foregroundColor: DukaanTokens.colorInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: DukaanTokens.textSubhead,
        iconTheme: IconThemeData(color: DukaanTokens.colorInk, size: 22),
        shape: Border(
          bottom: BorderSide(color: DukaanTokens.colorInk, width: 2),
        ),
      ),

      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: DukaanTokens.colorSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusCard)),
          side: BorderSide(color: DukaanTokens.colorLine),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DukaanTokens.colorSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DukaanTokens.space3,
          vertical: DukaanTokens.space3,
        ),
        hintStyle: DukaanTokens.textBody.copyWith(
          color: DukaanTokens.colorInkFaint,
        ),
        labelStyle: DukaanTokens.textLabel.copyWith(
          color: DukaanTokens.colorInkMuted,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          borderSide: BorderSide(color: DukaanTokens.colorBorderControl),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          borderSide: BorderSide(color: DukaanTokens.colorBorderControl),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          borderSide: BorderSide(color: DukaanTokens.colorPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          borderSide: BorderSide(color: DukaanTokens.colorDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          borderSide: BorderSide(color: DukaanTokens.colorDanger, width: 2),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DukaanTokens.colorPrimary,
          foregroundColor: DukaanTokens.colorOnPrimary,
          disabledBackgroundColor: DukaanTokens.colorLine,
          disabledForegroundColor: DukaanTokens.colorInkFaint,
          minimumSize: const Size(DukaanTokens.sizeHit, DukaanTokens.sizeHit),
          padding: const EdgeInsets.symmetric(
            horizontal: DukaanTokens.space5,
            vertical: DukaanTokens.space3,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          ),
          textStyle: DukaanTokens.textLabel,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DukaanTokens.colorInk,
          side: const BorderSide(color: DukaanTokens.colorLineStrong),
          minimumSize: const Size(DukaanTokens.sizeHit, DukaanTokens.sizeHit),
          padding: const EdgeInsets.symmetric(
            horizontal: DukaanTokens.space4,
            vertical: DukaanTokens.space3,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          ),
          textStyle: DukaanTokens.textLabel,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DukaanTokens.colorPrimary,
          minimumSize: const Size(
              DukaanTokens.sizeControlCompact, DukaanTokens.sizeControlCompact),
          padding: const EdgeInsets.symmetric(horizontal: DukaanTokens.space2),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          ),
          textStyle: DukaanTokens.textLabel,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: DukaanTokens.colorInkMuted,
          minimumSize:
              const Size(DukaanTokens.sizeControl, DukaanTokens.sizeControl),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: DukaanTokens.colorSurface,
        selectedColor: DukaanTokens.colorPrimaryWash,
        side: const BorderSide(color: DukaanTokens.colorLineStrong),
        labelStyle:
            DukaanTokens.textLabel.copyWith(color: DukaanTokens.colorInkMuted),
        secondaryLabelStyle: DukaanTokens.textLabel
            .copyWith(color: DukaanTokens.colorPrimaryInk),
        padding: const EdgeInsets.symmetric(
          horizontal: DukaanTokens.space3,
          vertical: DukaanTokens.space2,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusPill)),
        ),
        showCheckmark: false,
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: DukaanTokens.colorSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.transparent,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
          side: BorderSide(color: DukaanTokens.colorPrimaryStrong, width: 2),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? DukaanTokens.colorPrimaryInk
                : DukaanTokens.colorInkFaint,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => DukaanTokens.textCaption.copyWith(
            color: states.contains(WidgetState.selected)
                ? DukaanTokens.colorPrimaryInk
                : DukaanTokens.colorInkFaint,
          ),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: DukaanTokens.colorSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusSheet)),
        ),
        titleTextStyle: DukaanTokens.textHeading,
        contentTextStyle: DukaanTokens.textBody,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DukaanTokens.colorSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DukaanTokens.radiusSheet),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: DukaanTokens.colorHero,
        contentTextStyle:
            DukaanTokens.textLabel.copyWith(color: DukaanTokens.colorOnHero),
        actionTextColor: DukaanTokens.colorHeroAccent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusControl)),
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? DukaanTokens.colorSurface
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? DukaanTokens.colorPrimaryInk
                : DukaanTokens.colorInkMuted,
          ),
          side: const WidgetStatePropertyAll(
              BorderSide(color: Colors.transparent)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(DukaanTokens.radiusXs)),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(DukaanTokens.textLabel),
          minimumSize: const WidgetStatePropertyAll(
            Size(0, DukaanTokens.sizeControlCompact),
          ),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: DukaanTokens.colorInkMuted,
        textColor: DukaanTokens.colorInk,
        contentPadding: EdgeInsets.symmetric(horizontal: DukaanTokens.space4),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DukaanTokens.colorPrimary,
        linearTrackColor: DukaanTokens.colorSurfaceSunken,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: DukaanTokens.colorHero,
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusXs)),
        ),
        textStyle:
            DukaanTokens.textCaption.copyWith(color: DukaanTokens.colorOnHero),
      ),

      popupMenuTheme: const PopupMenuThemeData(
        color: DukaanTokens.colorSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DukaanTokens.radiusCard)),
          side: BorderSide(color: DukaanTokens.colorLine),
        ),
        textStyle: DukaanTokens.textLabel,
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: DukaanTokens.textSubhead,
        menuStyle: MenuStyle(
          backgroundColor:
              const WidgetStatePropertyAll(DukaanTokens.colorSurface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(DukaanTokens.radiusCard)),
              side: BorderSide(color: DukaanTokens.colorLine),
            ),
          ),
        ),
      ),
    );
  }
}
