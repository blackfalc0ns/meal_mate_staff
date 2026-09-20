class StaffApplicationStatusEntity {
  const StaffApplicationStatusEntity({
    this.registrationId,
    this.stage,
    this.badge,
    this.title,
    this.subtitle,
    this.notice,
    this.canResubmit = false,
    this.isApproved = false,
    this.restaurantApprovalStatus,
    this.adminApprovalStatus,
    this.changeRequestNotes,
    this.rejectionReason,
  });

  final String? registrationId;
  final int? stage;
  final String? badge;
  final String? title;
  final String? subtitle;
  final String? notice;
  final bool canResubmit;
  final bool isApproved;
  final String? restaurantApprovalStatus;
  final String? adminApprovalStatus;
  final String? changeRequestNotes;
  final String? rejectionReason;
}
