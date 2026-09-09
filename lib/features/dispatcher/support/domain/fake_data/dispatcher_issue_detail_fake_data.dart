import '../../../../../core/constants/assets.dart';
import '../entities/dispatcher_issue_attachment_entity.dart';
import '../entities/dispatcher_issue_detail_entity.dart';

class DispatcherIssueDetailFakeData {
  const DispatcherIssueDetailFakeData._();

  static const DispatcherIssueDetailEntity sampleIssueDetail =
      DispatcherIssueDetailEntity(
    id: 'ISSUE-1258',
    title: 'تعطل الدراجة أثناء التوصيل',
    minutesAgo: 12,
    isUrgent: true,
    taskNumber: '#BX-1258',
    area: 'السالمية',
    affectedBoxesCount: 3,
    priority: 'عالية',
    driverName: 'أحمد السيد',
    driverCode: 'DR-2011',
    driverAvatar: AppAssets.registrationDriverRole,
    isDriverOnline: true,
    driverSubStatus: 'على المهمة',
    description:
        'أبلغ السائق عن عطل مفاجئ في الدراجة اثناء طريقة في تسليم الطلب، ولم يمكنه استكمال المهمة الحالية حتي وصول دعم أو سائق آخر',
    attachments: [
      DispatcherIssueAttachmentEntity(
        id: 'att-1',
        imageAsset: AppAssets.dispatcherIssueAttachment1,
        orderNumber: 1,
      ),
      DispatcherIssueAttachmentEntity(
        id: 'att-2',
        imageAsset: AppAssets.dispatcherIssueAttachment2,
        orderNumber: 2,
      ),
    ],
    clientName: 'محمد الشمري',
    mealsCount: 3,
    expectedDeliveryTime: '12:15 م',
    pickupLocation: 'مطعم MealMate - السالمية',
    dropoffLocation: 'شارع الخليج العربي ، قطعة 5 ، منزل 12',
  );
}
