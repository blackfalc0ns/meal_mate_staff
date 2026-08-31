import 'package:flutter/material.dart';

import 'colors.dart';
import 'font_manager.dart';
import 'spacing.dart';
import 'styles_manager.dart';

class AppTheme {
  const AppTheme._();

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primarySurface,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.warning,
    onSecondary: AppColors.textPrimary,
    secondaryContainer: AppColors.warningSurface,
    onSecondaryContainer: AppColors.warning,
    tertiary: AppColors.success,
    onTertiary: AppColors.textOnPrimary,
    tertiaryContainer: AppColors.successSurface,
    onTertiaryContainer: AppColors.success,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    errorContainer: AppColors.errorSurface,
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceSoft,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.primaryBorder,
    shadow: AppColors.shadow,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: AppColors.textPrimaryDark,
    inversePrimary: AppColors.primarySurface,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primarySurface,
    onPrimary: AppColors.darkCallBackground,
    primaryContainer: AppColors.primary,
    onPrimaryContainer: AppColors.textOnPrimary,
    secondary: AppColors.warning,
    onSecondary: AppColors.textPrimary,
    secondaryContainer: AppColors.warningSurface,
    onSecondaryContainer: AppColors.warning,
    tertiary: AppColors.success,
    onTertiary: AppColors.textOnPrimary,
    tertiaryContainer: AppColors.success,
    onTertiaryContainer: AppColors.successSurface,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    errorContainer: AppColors.error,
    onErrorContainer: AppColors.errorSurface,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.cardDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.primaryBorder,
    outlineVariant: AppColors.primaryBorder,
    shadow: AppColors.shadow,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.surface,
    onInverseSurface: AppColors.textPrimary,
    inversePrimary: AppColors.primary,
  );

  static ThemeData get lightTheme => _buildTheme(_lightColorScheme);

  static ThemeData get darkTheme => _buildTheme(_darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      fontFamily: FontConstant.alexandria,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: getSemiBoldStyle(
          color: colorScheme.onSurface,
          fontSize: FontSize.size18,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.textHint,
          elevation: 0,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, Spacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.buttonRadius),
          ),
          textStyle: getSemiBoldStyle(
            color: AppColors.textOnPrimary,
            fontSize: FontSize.size16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, Spacing.buttonHeight),
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.buttonRadius),
          ),
          textStyle: getSemiBoldStyle(
            color: colorScheme.primary,
            fontSize: FontSize.size16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: getSemiBoldStyle(
            color: colorScheme.primary,
            fontSize: FontSize.size16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: _inputBorder(colorScheme.outline),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.md,
        ),
        enabledBorder: _inputBorder(colorScheme.outline),
        errorBorder: _inputBorder(colorScheme.error),
        errorStyle: getRegularStyle(
          color: AppColors.error,
          fontSize: FontSize.size12,
        ),
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.surface,
        focusedBorder: _inputBorder(colorScheme.primary, width: 1.5),
        focusedErrorBorder: _inputBorder(colorScheme.error, width: 1.5),
        hintStyle: getRegularStyle(
          color: AppColors.textHint,
          fontSize: FontSize.size13,
        ),
        labelStyle: getMediumStyle(
          color: AppColors.textPrimary,
          fontSize: FontSize.size14,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.cardDark : AppColors.card,
        elevation: Spacing.cardElevation,
        margin: EdgeInsets.zero,
        shadowColor: AppColors.shadowSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Spacing.inputRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
