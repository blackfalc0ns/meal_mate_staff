import '../entities/assign_box_candidate_driver_entity.dart';
import '../entities/assign_box_driver_status_type.dart';
import '../entities/assign_box_order_entity.dart';

class AssignBoxFakeData {
  const AssignBoxFakeData._();

  static const AssignBoxOrderEntity sampleOrder = AssignBoxOrderEntity(
    boxCode: '#BX-1256',
    statusText: 'جديد',
    areaText: 'منطقة السالمية',
    distanceText: '6.2 كم',
    deliveryTimeWindow: '09:30-10:30 ص',
    priorityText: 'عالية',
    mealsCountText: '8 وجبات',
    recommendedDriver: AssignBoxCandidateDriverEntity(
      id: 'rec_salem',
      name: 'سالم الحربي',
      statusText: 'متاح',
      statusType: AssignBoxDriverStatusType.available,
      tagText: 'الأقرب',
      distanceText: '4.8 كم',
      currentLoadText: '4 بوكسات',
      expectedCompletionText: '10:15 ص',
      isRecommended: true,
    ),
    candidates: [
      AssignBoxCandidateDriverEntity(
        id: 'cand_1',
        name: 'أحمد إبراهيم',
        badgeNumber: '#1',
        statusText: 'متاح',
        statusType: AssignBoxDriverStatusType.available,
        tagText: 'الأقل ضغطاً',
        distanceText: '6.2 كم',
        currentLoadText: '0 بوكسات',
        expectedCompletionText: '10:20 ص',
      ),
      AssignBoxCandidateDriverEntity(
        id: 'cand_2',
        name: 'محمد السعيد',
        badgeNumber: '#2',
        statusText: 'مشغول',
        statusType: AssignBoxDriverStatusType.busy,
        tagText: 'مشغول بتسليم',
        distanceText: '6.2 كم',
        currentLoadText: '0 بوكسات',
        expectedCompletionText: '10:20 ص',
      ),
      AssignBoxCandidateDriverEntity(
        id: 'cand_3',
        name: 'يوسف العتيبي',
        badgeNumber: '#3',
        statusText: 'خرج للتوصيل',
        statusType: AssignBoxDriverStatusType.inDelivery,
        tagText: 'قريب من العميل',
        distanceText: '6.2 كم',
        currentLoadText: '0 بوكسات',
        expectedCompletionText: '10:20 ص',
      ),
      AssignBoxCandidateDriverEntity(
        id: 'cand_4',
        name: 'سالم الدوسري',
        badgeNumber: '#4',
        statusText: 'راجع للمطعم',
        statusType: AssignBoxDriverStatusType.returning,
        tagText: 'قريب من المطعم',
        distanceText: '6.2 كم',
      ),
    ],
  );
}
