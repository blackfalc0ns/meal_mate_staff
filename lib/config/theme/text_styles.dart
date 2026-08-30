import 'package:flutter/material.dart';

import 'colors.dart';
import 'font_manager.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String _fontFamily = FontConstant.alexandria;

  static const TextStyle h1 = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size28,
    fontWeight: FontWeightManager.bold,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size24,
    fontWeight: FontWeightManager.bold,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size20,
    fontWeight: FontWeightManager.semiBold,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size18,
    fontWeight: FontWeightManager.semiBold,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size16,
    fontWeight: FontWeightManager.regular,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size14,
    fontWeight: FontWeightManager.regular,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size12,
    fontWeight: FontWeightManager.regular,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size16,
    fontWeight: FontWeightManager.semiBold,
  );

  static const TextStyle labelMedium = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size14,
    fontWeight: FontWeightManager.medium,
  );

  static const TextStyle labelSmall = TextStyle(
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size12,
    fontWeight: FontWeightManager.medium,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.textOnPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size16,
    fontWeight: FontWeightManager.semiBold,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textHint,
    fontFamily: _fontFamily,
    fontSize: FontSize.size11,
    fontWeight: FontWeightManager.regular,
    height: 1.4,
  );

  static const TextStyle input = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
    fontSize: FontSize.size14,
    fontWeight: FontWeightManager.regular,
  );

  static const TextStyle inputHint = TextStyle(
    color: AppColors.textHint,
    fontFamily: _fontFamily,
    fontSize: FontSize.size13,
    fontWeight: FontWeightManager.regular,
  );

  static const TextStyle inputError = TextStyle(
    color: AppColors.error,
    fontFamily: _fontFamily,
    fontSize: FontSize.size12,
    fontWeight: FontWeightManager.regular,
  );
}
