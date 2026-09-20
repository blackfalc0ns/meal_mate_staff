import '../account_status_kind.dart';

class DriverRegistrationStatusEntity {
  const DriverRegistrationStatusEntity({
    required this.registrationId,
    required this.kind,
    this.phone,
    this.fullName,
    this.restaurantName,
    this.restaurantId,
    this.statusString = 'Submitted',
    this.stage = 1,
    this.badge,
    this.title,
    this.subtitle,
    this.notice,
    this.restaurantApprovalStatus,
    this.adminApprovalStatus,
    this.canResubmit = false,
    this.isApproved = false,
    this.changeRequestNotes,
    this.rejectionReason,
  });

  final String registrationId;
  final AccountStatusKind kind;
  final String? phone;
  final String? fullName;
  final String? restaurantName;
  final String? restaurantId;
  final String statusString;
  final int stage;
  final String? badge;
  final String? title;
  final String? subtitle;
  final String? notice;
  final String? restaurantApprovalStatus;
  final String? adminApprovalStatus;
  final bool canResubmit;
  final bool isApproved;
  final String? changeRequestNotes;
  final String? rejectionReason;
}
