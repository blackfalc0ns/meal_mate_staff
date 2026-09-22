import 'dispatcher_issue_attachment_entity.dart';
import 'dispatcher_issue_driver_entity.dart';
import 'dispatcher_issue_resolution_entity.dart';
import 'dispatcher_issue_status.dart';
import 'dispatcher_issue_trip_entity.dart';

class DispatcherIssueDetailEntity {
  const DispatcherIssueDetailEntity({
    required this.issueId,
    required this.title,
    this.category = '',
    this.categoryLabel = '',
    this.categoryColorHex = '#EF4444',
    this.createdAtUtc,
    this.reportedTimeText = '',
    this.status = DispatcherIssueStatus.open,
    this.statusLabel = '',
    required this.boxCode,
    required this.area,
    this.affectedBoxesCount = 0,
    this.affectedBoxesText = '',
    this.priority = '',
    this.priorityText = '',
    this.priorityColorHex = '#EF4444',
    this.driver,
    this.description = '',
    this.evidencePhotos = const [],
    this.tripInfo = const DispatcherIssueTripEntity(
      clientName: '',
      mealsCount: 0,
      expectedDeliveryTime: '',
      pickupLocation: '',
      dropoffLocation: '',
    ),
    this.resolution,
  });

  final String issueId;
  final String title;
  final String category;
  final String categoryLabel;
  final String categoryColorHex;
  final DateTime? createdAtUtc;
  final String reportedTimeText;
  final DispatcherIssueStatus status;
  final String statusLabel;
  final String boxCode;
  final String area;
  final int affectedBoxesCount;
  final String affectedBoxesText;
  final String priority;
  final String priorityText;
  final String priorityColorHex;
  final DispatcherIssueDriverEntity? driver;
  final String description;
  final List<DispatcherIssueAttachmentEntity> evidencePhotos;
  final DispatcherIssueTripEntity tripInfo;
  final DispatcherIssueResolutionEntity? resolution;

  // Compatibility and convenience getters
  String get id => issueId;
  String get taskNumber => boxCode;
  bool get isResolved => status == DispatcherIssueStatus.resolved;
  bool get isUrgent =>
      priority.trim().toLowerCase() == 'urgent' ||
      priority.trim().toLowerCase() == 'high' ||
      priority.trim() == 'عالية';

  int get minutesAgo {
    if (createdAtUtc == null) return 0;
    return DateTime.now().toUtc().difference(createdAtUtc!).inMinutes.abs();
  }

  String get driverName => driver?.name ?? '';
  String get driverCode => driver?.code ?? '';
  String get driverAvatar => driver?.avatarUrl ?? '';
  bool get isDriverOnline => driver?.isOnline ?? false;
  String get driverSubStatus => driver?.subStatus ?? '';

  List<DispatcherIssueAttachmentEntity> get attachments => evidencePhotos;

  String get clientName => tripInfo.clientName;
  int get mealsCount => tripInfo.mealsCount;
  String get expectedDeliveryTime => tripInfo.expectedDeliveryTime;
  String get pickupLocation => tripInfo.pickupLocation;
  String get dropoffLocation => tripInfo.dropoffLocation;

  DispatcherIssueDetailEntity copyWith({
    String? issueId,
    String? title,
    String? category,
    String? categoryLabel,
    String? categoryColorHex,
    DateTime? createdAtUtc,
    String? reportedTimeText,
    DispatcherIssueStatus? status,
    String? statusLabel,
    String? boxCode,
    String? area,
    int? affectedBoxesCount,
    String? affectedBoxesText,
    String? priority,
    String? priorityText,
    String? priorityColorHex,
    DispatcherIssueDriverEntity? driver,
    String? description,
    List<DispatcherIssueAttachmentEntity>? evidencePhotos,
    DispatcherIssueTripEntity? tripInfo,
    DispatcherIssueResolutionEntity? resolution,
  }) {
    return DispatcherIssueDetailEntity(
      issueId: issueId ?? this.issueId,
      title: title ?? this.title,
      category: category ?? this.category,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      categoryColorHex: categoryColorHex ?? this.categoryColorHex,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      reportedTimeText: reportedTimeText ?? this.reportedTimeText,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      boxCode: boxCode ?? this.boxCode,
      area: area ?? this.area,
      affectedBoxesCount: affectedBoxesCount ?? this.affectedBoxesCount,
      affectedBoxesText: affectedBoxesText ?? this.affectedBoxesText,
      priority: priority ?? this.priority,
      priorityText: priorityText ?? this.priorityText,
      priorityColorHex: priorityColorHex ?? this.priorityColorHex,
      driver: driver ?? this.driver,
      description: description ?? this.description,
      evidencePhotos: evidencePhotos ?? this.evidencePhotos,
      tripInfo: tripInfo ?? this.tripInfo,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherIssueDetailEntity &&
          runtimeType == other.runtimeType &&
          issueId == other.issueId;

  @override
  int get hashCode => issueId.hashCode;
}
