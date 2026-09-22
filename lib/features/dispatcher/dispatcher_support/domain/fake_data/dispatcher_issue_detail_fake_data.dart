import '../../../../../core/constants/assets.dart';
import '../entities/dispatcher_issue_attachment_entity.dart';
import '../entities/dispatcher_issue_detail_entity.dart';
import '../entities/dispatcher_issue_driver_entity.dart';
import '../entities/dispatcher_issue_trip_entity.dart';

class DispatcherIssueDetailFakeData {
  const DispatcherIssueDetailFakeData._();

  static const DispatcherIssueDetailEntity sampleIssueDetail =
      DispatcherIssueDetailEntity(
    issueId: 'ISSUE-1258',
    title: 'تعطل الدراجة أثناء التوصيل',
    category: 'VEHICLE_BREAKDOWN',
    categoryLabel: 'عطل في الدراجة',
    reportedTimeText: 'منذ 12 دقيقة',
    boxCode: '#BX-1258',
    area: 'السالمية',
    affectedBoxesCount: 3,
    affectedBoxesText: '3 صناديق',
    priority: 'عالية',
    priorityText: 'عالية',
    driver: DispatcherIssueDriverEntity(
      id: 'DR-2011',
      name: 'أحمد السيد',
      code: 'DR-2011',
      avatarUrl: AppAssets.registrationDriverRole,
      isOnline: true,
      subStatus: 'على المهمة',
    ),
    description:
        'أبلغ السائق عن عطل مفاجئ في الدراجة اثناء طريقة في تسليم الطلب، ولم يمكنه استكمال المهمة الحالية حتي وصول دعم أو سائق آخر',
    evidencePhotos: [
      DispatcherIssueAttachmentEntity(
        id: 'att-1',
        url: AppAssets.dispatcherIssueAttachment1,
        imageAsset: AppAssets.dispatcherIssueAttachment1,
        orderNumber: 1,
      ),
      DispatcherIssueAttachmentEntity(
        id: 'att-2',
        url: AppAssets.dispatcherIssueAttachment2,
        imageAsset: AppAssets.dispatcherIssueAttachment2,
        orderNumber: 2,
      ),
    ],
    tripInfo: DispatcherIssueTripEntity(
      clientName: 'محمد الشمري',
      mealsCount: 3,
      expectedDeliveryTime: '12:15 م',
      pickupLocation: 'مطعم MealMate - السالمية',
      dropoffLocation: 'شارع الخليج العربي ، قطعة 5 ، منزل 12',
    ),
  );
}
