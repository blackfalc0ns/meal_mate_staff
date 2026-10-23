import '../../../../../core/constants/assets.dart';
import '../../domain/entities/dispatcher_notification_entity.dart';
import '../models/response/delivery_manager_notification_response_dto.dart';

class DispatcherNotificationMapper {
  const DispatcherNotificationMapper._();

  static DispatcherNotificationEntity toEntity(
    DeliveryManagerNotificationResponseDto dto,
  ) {
    final rawType = (dto.type ?? '').trim();
    final type = _resolveType(rawType);
    final iconAsset = _resolveIconAsset(type);

    final title = (dto.title?.trim().isNotEmpty == true)
        ? dto.title!.trim()
        : 'إشعار جديد';

    final description = (dto.body?.trim().isNotEmpty == true)
        ? dto.body!.trim()
        : '';

    final timeAgo = (dto.sentTimeAgo?.trim().isNotEmpty == true)
        ? dto.sentTimeAgo!.trim()
        : _formatDateTimeAgo(dto.sentAtUtc);

    return DispatcherNotificationEntity(
      id: dto.notificationId?.trim() ?? '',
      type: type,
      title: title,
      description: description,
      timeAgo: timeAgo,
      iconAsset: iconAsset,
      isUnread: !(dto.isRead ?? false),
      isArchived: false,
      section: dto.section?.trim(),
      subjectId: dto.subjectId?.trim(),
      deepLink: dto.deepLink?.trim(),
      sentAtUtc: dto.sentAtUtc,
      rawType: rawType.isNotEmpty ? rawType : null,
    );
  }

  static DispatcherNotificationType _resolveType(String rawType) {
    return switch (rawType.toLowerCase()) {
      'driver-support-issue' => DispatcherNotificationType.driverSupportIssue,
      'driver-support-issue-resolved' =>
        DispatcherNotificationType.driverSupportIssueResolved,
      'driver-support-handover' =>
        DispatcherNotificationType.driverSupportHandover,
      'new-box' || 'newbox' => DispatcherNotificationType.newBox,
      'box-problem' || 'boxproblem' => DispatcherNotificationType.boxProblem,
      'driver-completed' || 'drivercompleted' =>
        DispatcherNotificationType.driverCompleted,
      'replacement-box' || 'replacementbox' =>
        DispatcherNotificationType.replacementBox,
      'performance-alert' || 'performancealert' =>
        DispatcherNotificationType.performanceAlert,
      'trip-update' || 'tripupdate' => DispatcherNotificationType.tripUpdate,
      'delayed-box' || 'delayedbox' => DispatcherNotificationType.delayedBox,
      _ => DispatcherNotificationType.other,
    };
  }

  static String _resolveIconAsset(DispatcherNotificationType type) {
    return switch (type) {
      DispatcherNotificationType.driverSupportIssue ||
      DispatcherNotificationType.boxProblem =>
        AppAssets.notificationIconBoxDismiss,
      DispatcherNotificationType.driverSupportIssueResolved ||
      DispatcherNotificationType.replacementBox =>
        AppAssets.notificationIconBoxCheck,
      DispatcherNotificationType.driverSupportHandover ||
      DispatcherNotificationType.newBox =>
        AppAssets.notificationIconBox,
      DispatcherNotificationType.driverCompleted =>
        AppAssets.notificationIconUser,
      DispatcherNotificationType.performanceAlert =>
        AppAssets.notificationIconHierarchy,
      DispatcherNotificationType.tripUpdate =>
        AppAssets.notificationIconMapMarker,
      DispatcherNotificationType.delayedBox => AppAssets.notificationIconClock,
      DispatcherNotificationType.other => AppAssets.notificationIconBox,
    };
  }

  static String _formatDateTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    final difference = DateTime.now().toUtc().difference(dateTime.toUtc());
    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    return 'منذ ${difference.inDays} يوم';
  }
}

extension DeliveryManagerNotificationResponseDtoExtension
    on DeliveryManagerNotificationResponseDto {
  DispatcherNotificationEntity toEntity() =>
      DispatcherNotificationMapper.toEntity(this);
}
