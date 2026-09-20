import '../../../core/l10n/translations/app_localizations.dart';
import 'account_status_kind.dart';
import 'account_status_reason_tone.dart';
import 'entities/driver_registration_status_entity.dart';

class AccountStatusData {
  const AccountStatusData({
    required this.kind,
    required this.illustrationAsset,
    required this.title,
    required this.body,
    this.primaryAction,
    this.secondaryAction,
    this.reasonTitle,
    this.reasons = const [],
    this.reasonTone,
  });

  final AccountStatusKind kind;
  final String illustrationAsset;
  final String title;
  final String body;
  final String? primaryAction;
  final String? secondaryAction;
  final String? reasonTitle;
  final List<String> reasons;
  final AccountStatusReasonTone? reasonTone;

  bool get hasReasons => reasons.isNotEmpty;

  factory AccountStatusData.fromEntity(
    DriverRegistrationStatusEntity entity,
    AppLocalizations locale, {
    required String acceptedAsset,
    required String rejectedAsset,
    required String moreInfoAsset,
    required String underReviewAsset,
  }) {
    final base = AccountStatusData.fromKind(
      entity.kind,
      locale,
      acceptedAsset: acceptedAsset,
      rejectedAsset: rejectedAsset,
      moreInfoAsset: moreInfoAsset,
      underReviewAsset: underReviewAsset,
    );

    List<String> reasons = base.reasons;
    if (entity.kind == AccountStatusKind.moreInformationRequired &&
        entity.changeRequestNotes != null &&
        entity.changeRequestNotes!.isNotEmpty) {
      reasons = entity.changeRequestNotes!
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (entity.kind == AccountStatusKind.rejected &&
        entity.rejectionReason != null &&
        entity.rejectionReason!.isNotEmpty) {
      reasons = entity.rejectionReason!
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return AccountStatusData(
      kind: entity.kind,
      illustrationAsset: base.illustrationAsset,
      title: (entity.title != null && entity.title!.isNotEmpty)
          ? entity.title!
          : base.title,
      body: (entity.subtitle != null && entity.subtitle!.isNotEmpty)
          ? entity.subtitle!
          : base.body,
      primaryAction: base.primaryAction,
      secondaryAction: base.secondaryAction,
      reasonTitle: (entity.badge != null && entity.badge!.isNotEmpty)
          ? entity.badge
          : base.reasonTitle,
      reasons: reasons,
      reasonTone: base.reasonTone,
    );
  }

  factory AccountStatusData.fromKind(
    AccountStatusKind kind,
    AppLocalizations locale, {
    required String acceptedAsset,
    required String rejectedAsset,
    required String moreInfoAsset,
    required String underReviewAsset,
  }) {
    return switch (kind) {
      AccountStatusKind.accepted => AccountStatusData(
        kind: kind,
        illustrationAsset: acceptedAsset,
        title: locale.accountStatusAcceptedTitle,
        body: locale.accountStatusAcceptedBody,
        primaryAction: locale.accountStatusStartWork,
        secondaryAction: locale.accountStatusBackToLogin,
      ),
      AccountStatusKind.rejected => AccountStatusData(
        kind: kind,
        illustrationAsset: rejectedAsset,
        title: locale.accountStatusRejectedTitle,
        body: locale.accountStatusRejectedBody,
        primaryAction: locale.accountStatusResubmit,
        secondaryAction: locale.accountStatusBackToLogin,
        reasonTitle: locale.accountStatusRejectionReason,
        reasons: [
          locale.accountStatusReasonCivilIdMismatch,
          locale.accountStatusReasonDrivingLicenseExpired,
          locale.accountStatusReasonVehicleRegistrationUnclear,
        ],
        reasonTone: AccountStatusReasonTone.error,
      ),
      AccountStatusKind.moreInformationRequired => AccountStatusData(
        kind: kind,
        illustrationAsset: moreInfoAsset,
        title: locale.accountStatusMoreInfoTitle,
        body: locale.accountStatusMoreInfoBody,
        primaryAction: locale.accountStatusEditAndResend,
        secondaryAction: locale.accountStatusBackToLogin,
        reasonTitle: locale.accountStatusChangeReason,
        reasons: [
          locale.accountStatusReasonDrivingLicenseUnclear,
          locale.accountStatusReasonVehicleRegistrationExpired,
        ],
        reasonTone: AccountStatusReasonTone.warning,
      ),
      AccountStatusKind.underReview => AccountStatusData(
        kind: kind,
        illustrationAsset: underReviewAsset,
        title: locale.accountStatusUnderReviewTitle,
        body: locale.accountStatusUnderReviewBody,
      ),
    };
  }
}
