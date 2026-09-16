import '../../../../../core/constants/assets.dart';
import '../entities/operation_item_entity.dart';
import '../entities/operation_status.dart';
import '../entities/operations_filter_entity.dart';

class OperationsFakeData {
  const OperationsFakeData._();

  static const OperationsFilterEntity initialFilter = OperationsFilterEntity();

  static const List<OperationItemEntity> sampleOperations = [
    OperationItemEntity(
      id: 'OP-10256',
      orderId: '#BX-10256',
      status: OperationStatus.completed,
      customerName: 'أحمد العتيبي',
      area: 'حي الياسمين، الرياض',
      timestamp: 'اليوم • 10:45 ص',
      driverName: 'أحمد السعيد',
      driverAvatarUrl: AppAssets.registrationDriverRole,
      isDriverOnline: true,
    ),
    OperationItemEntity(
      id: 'OP-10255',
      orderId: '#BX-10255',
      status: OperationStatus.reassigned,
      customerName: 'أحمد العتيبي',
      area: 'حي الياسمين، الرياض',
      timestamp: 'اليوم • 10:28 ص',
      driverName: 'فهد المطيري',
      driverAvatarUrl: AppAssets.registrationDriverRole,
      reassignedToDriverName: 'يوسف خالد',
      reassignedToDriverAvatarUrl: AppAssets.registrationDriverRole,
    ),
    OperationItemEntity(
      id: 'OP-10248',
      orderId: '#BX-10248',
      status: OperationStatus.failed,
      customerName: 'أحمد العتيبي',
      area: 'حي الياسمين، الرياض',
      timestamp: 'اليوم • 09:50 ص',
      driverName: 'محمد العنزي',
      driverAvatarUrl: AppAssets.registrationDriverRole,
      isDriverOnline: true,
    ),
    OperationItemEntity(
      id: 'OP-10242',
      orderId: '#BX-10242',
      status: OperationStatus.completed,
      customerName: 'أحمد العتيبي',
      area: 'حي الياسمين، الرياض',
      timestamp: 'أمس • 08:15 م',
      driverName: 'عبدالله الشهري',
      driverAvatarUrl: AppAssets.registrationDriverRole,
      isDriverOnline: true,
    ),
    OperationItemEntity(
      id: 'OP-10241',
      orderId: '#BX-10241',
      status: OperationStatus.cancelled,
      customerName: 'أحمد العتيبي',
      area: 'حي الياسمين، الرياض',
      timestamp: 'أمس • 06:40 م',
      cancellationReason: 'تم الإلغاء من قبل المطعم',
    ),
    OperationItemEntity(
      id: 'OP-10237',
      orderId: '#BX-10237',
      status: OperationStatus.reassigned,
      customerName: 'أحمد العتيبي',
      area: 'حي الياسمين، الرياض',
      timestamp: 'أمس • 05:20 م',
      driverName: 'فهد المطيري',
      driverAvatarUrl: AppAssets.registrationDriverRole,
      reassignedToDriverName: 'يوسف خالد',
      reassignedToDriverAvatarUrl: AppAssets.registrationDriverRole,
    ),
    OperationItemEntity(
      id: 'OP-10230',
      orderId: '#BX-10230',
      status: OperationStatus.completed,
      customerName: 'أحمد العتيبي',
      area: 'حي الياسمين، الرياض',
      timestamp: 'أمس • 03:05 م',
      driverName: 'يوسف خالد',
      driverAvatarUrl: AppAssets.registrationDriverRole,
      isDriverOnline: true,
    ),
    OperationItemEntity(
      id: 'OP-10228',
      orderId: '#BX-10228',
      status: OperationStatus.failed,
      customerName: 'أحمد العتيبي',
      area: 'حي الياسمين، الرياض',
      timestamp: '6/08 • 11:30 ص',
      driverName: 'أحمد السعيد',
      driverAvatarUrl: AppAssets.registrationDriverRole,
      isDriverOnline: true,
    ),
  ];
}
