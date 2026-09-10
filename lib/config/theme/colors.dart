import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF603BC1);
  static const Color primarySurface = Color(0xFFF4EFFB);
  static const Color primaryBorder = Color(0xFFD5CEE2);

  static const Color background = Color(0xFFF6F4FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF9F8FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFDCDCDE);
  static const Color divider = Color(0xFFD9D1EA);

  static const Color textPrimary = Color(0xFF17151C);
  static const Color textSecondary = Color(0xFF878685);
  static const Color textHint = Color(0xFF9A95A3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFFD8020);
  static const Color warningSurface = Color(0xFFFEEEE2);
  static const Color error = Color(0xFFE53935);
  static const Color errorSurface = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF1BC74E);
  static const Color successSurface = Color(0xFFE7F9ED);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFEFF6FF);

  static const Color dispatcherBadgeNew = Color(0xFF1BC74E);
  static const Color dispatcherBadgeNewSurface = Color(0xFFE7F9ED);
  static const Color dispatcherBadgeUrgent = Color(0xFFE53935);
  static const Color dispatcherBadgeUrgentSurface = Color(0xFFFFEBEE);
  static const Color dispatcherBadgeHigh = Color(0xFFFD8020);
  static const Color dispatcherBadgeHighSurface = Color(0xFFFFF6E7);
  static const Color dispatcherBadgeNormal = Color(0xFF878685);
  static const Color dispatcherBadgeNormalSurface = Color(0xFFF3F4F6);
  static const Color dispatcherSuggestionSurface = Color(0xFFF6F4FB);
  static const Color dispatcherMetricBoxSurface = Color(0xFFF7F6FC);

  static const Color darkCallBackground = Color(0xFF1B1540);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  static const Color shadow = Color(0x1A000000);
  static const Color shadowSoft = Color(0x0D000000);
  static const Color scrim = Color(0x99000000);
  static const Color disabled = Color(0xFFE4E4E5);

  static const Color accountStatusMutedText = Color(0xFF877FA5);
  static const Color accountStatusBodyText = Color(0xFF626262);
  static const Color accountStatusReviewSurface = Color(0xFFF9F5FB);
  static const Color accountStatusReviewBorder = Color(0xFFE8E2F2);
  static const Color accountStatusReviewAccent = Color(0xFFF2EBFA);
  static const Color accountStatusHelpBorder = Color(0xFFE9E8EF);
  static const Color accountStatusTrustSurface = Color(0xFFF6F0FB);
  static const Color accountStatusTrustBorder = Color(0xFFF0E9F9);
  static const Color accountStatusWarningSurface = Color(0xFFFFF6E7);
  static const Color accountStatusWarning = Color(0xFFFCA30B);
  static const Color accountStatusErrorSurface = Color(0xFFFFF1F1);
  static const Color accountStatusError = Color(0xFFDE0D14);

  static const Color backgroundDark = Color(0xFF17151C);
  static const Color surfaceDark = Color(0xFF1B1540);
  static const Color cardDark = Color(0xFF231D4A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFD9D1EA);
  static const Color notificationCardUnreadSurface = Color(0xFFFAF9FE);
  static const Color notificationCardBorder = Color(0xFFF2F1F7);
  static const Color notificationPillsBackground = Color(0xFFFBFBFB);
  static const Color notificationPillsBorder = Color(0xFFF1F1F3);
  static const Color notificationUnreadDot = Color(0xFF6744C2);
  static const Color notificationIconPurpleSurface = Color(0xFFEFEDFA);
  static const Color notificationIconRedSurface = Color(0xFFFBEBEC);
  static const Color notificationIconGreenSurface = Color(0xFFE6F6EB);
  static const Color notificationIconOrangeSurface = Color(0xFFFEF2E4);
  static const Color notificationIconRed = Color(0xFFDD0C14);
  static const Color notificationIconGreen = Color(0xFF29BE63);
  static const Color notificationIconOrange = Color(0xFFF99D1C);
  static const Color notificationHeaderBorder = Color(0xFFE4E4E4);
}

extension AccountStatusColorScheme on ColorScheme {
  Color get accountStatusMutedText => AppColors.accountStatusMutedText;
  Color get accountStatusBodyText => AppColors.accountStatusBodyText;
  Color get accountStatusReviewSurface => AppColors.accountStatusReviewSurface;
  Color get accountStatusReviewBorder => AppColors.accountStatusReviewBorder;
  Color get accountStatusReviewAccent => AppColors.accountStatusReviewAccent;
  Color get accountStatusHelpBorder => AppColors.accountStatusHelpBorder;
  Color get accountStatusTrustSurface => AppColors.accountStatusTrustSurface;
  Color get accountStatusTrustBorder => AppColors.accountStatusTrustBorder;
  Color get accountStatusWarningSurface =>
      AppColors.accountStatusWarningSurface;
  Color get accountStatusWarning => AppColors.accountStatusWarning;
  Color get accountStatusErrorSurface => AppColors.accountStatusErrorSurface;
  Color get accountStatusError => AppColors.accountStatusError;
}

extension DispatcherColorScheme on ColorScheme {
  Color get success => AppColors.success;
  Color get successSurface => AppColors.successSurface;
  Color get warning => AppColors.warning;
  Color get warningSurface => AppColors.warningSurface;
  Color get info => AppColors.info;
  Color get infoSurface => AppColors.infoSurface;
  Color get dispatcherBadgeNew => AppColors.dispatcherBadgeNew;
  Color get dispatcherBadgeNewSurface => AppColors.dispatcherBadgeNewSurface;
  Color get dispatcherBadgeUrgent => AppColors.dispatcherBadgeUrgent;
  Color get dispatcherBadgeUrgentSurface =>
      AppColors.dispatcherBadgeUrgentSurface;
  Color get dispatcherBadgeHigh => AppColors.dispatcherBadgeHigh;
  Color get dispatcherBadgeHighSurface => AppColors.dispatcherBadgeHighSurface;
  Color get dispatcherBadgeNormal => AppColors.dispatcherBadgeNormal;
  Color get dispatcherBadgeNormalSurface =>
      AppColors.dispatcherBadgeNormalSurface;
  Color get dispatcherSuggestionSurface =>
      AppColors.dispatcherSuggestionSurface;
  Color get dispatcherMetricBoxSurface => AppColors.dispatcherMetricBoxSurface;
  Color get primaryBorder => AppColors.primaryBorder;
  Color get transparent => AppColors.transparent;
}

extension DispatcherNotificationsColorScheme on ColorScheme {
  Color get notificationCardUnreadSurface =>
      AppColors.notificationCardUnreadSurface;
  Color get notificationCardBorder => AppColors.notificationCardBorder;
  Color get notificationPillsBackground =>
      AppColors.notificationPillsBackground;
  Color get notificationPillsBorder => AppColors.notificationPillsBorder;
  Color get notificationUnreadDot => AppColors.notificationUnreadDot;
  Color get notificationIconPurpleSurface =>
      AppColors.notificationIconPurpleSurface;
  Color get notificationIconRedSurface =>
      AppColors.notificationIconRedSurface;
  Color get notificationIconGreenSurface =>
      AppColors.notificationIconGreenSurface;
  Color get notificationIconOrangeSurface =>
      AppColors.notificationIconOrangeSurface;
  Color get notificationIconRed => AppColors.notificationIconRed;
  Color get notificationIconGreen => AppColors.notificationIconGreen;
  Color get notificationIconOrange => AppColors.notificationIconOrange;
  Color get notificationHeaderBorder => AppColors.notificationHeaderBorder;
}
