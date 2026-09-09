import '../../../../../core/constants/assets.dart';
import '../entities/dispatcher_support_issue_entity.dart';
import '../entities/dispatcher_support_issue_type.dart';
import '../entities/dispatcher_support_kpi_entity.dart';
import '../entities/dispatcher_support_status.dart';

class DispatcherSupportFakeData {
  const DispatcherSupportFakeData._();

  static const List<String> areas = [
    'كل المناطق',
    'السالمية',
    'حولي',
    'الفروانية',
    'العاصمة',
  ];

  static const DispatcherSupportKpiEntity kpi = DispatcherSupportKpiEntity(
    currentArea: 'السالمية',
    missingCount: 8,
    inProgressCount: 3,
    resolvedCount: 15,
  );

  static const List<DispatcherSupportIssueEntity> issues = [
    DispatcherSupportIssueEntity(
      id: 'ISS-001',
      boxCode: 'BX-1256',
      driverName: 'أحمد السعيد',
      driverAvatar: AppAssets.registrationDriverRole,
      driverPhone: '+965 9876 5432',
      area: 'السالمية',
      vehicleModel: 'توباتا كامري',
      vehicleColor: 'أبيض',
      issueType: DispatcherSupportIssueType.severeDelay,
      status: DispatcherSupportStatus.open,
      minutesAgo: 18,
      isDriverActive: true,
    ),
    DispatcherSupportIssueEntity(
      id: 'ISS-002',
      boxCode: 'BX-1256',
      driverName: 'محمد العازمي',
      driverAvatar: AppAssets.registrationDriverRole,
      driverPhone: '+965 9876 5433',
      area: 'السالمية',
      vehicleModel: 'توباتا كامري',
      vehicleColor: 'اسود',
      issueType: DispatcherSupportIssueType.damagedBox,
      status: DispatcherSupportStatus.open,
      minutesAgo: 18,
      isDriverActive: true,
    ),
    DispatcherSupportIssueEntity(
      id: 'ISS-003',
      boxCode: 'BX-1256',
      driverName: 'عبدالله العنزي',
      driverAvatar: AppAssets.registrationDriverRole,
      driverPhone: '+965 9876 5434',
      area: 'حولي',
      vehicleModel: 'توباتا كامري',
      vehicleColor: 'اسود',
      issueType: DispatcherSupportIssueType.customerUnavailable,
      status: DispatcherSupportStatus.inProgress,
      minutesAgo: 18,
      isDriverActive: true,
    ),
    DispatcherSupportIssueEntity(
      id: 'ISS-004',
      boxCode: 'BX-1256',
      driverName: 'سالم المطيري',
      driverAvatar: AppAssets.registrationDriverRole,
      driverPhone: '+965 9876 5435',
      area: 'الفروانية',
      vehicleModel: 'توباتا كامري',
      vehicleColor: 'أبيض',
      issueType: DispatcherSupportIssueType.addressProblem,
      status: DispatcherSupportStatus.open,
      minutesAgo: 18,
      isDriverActive: true,
    ),
  ];
}
