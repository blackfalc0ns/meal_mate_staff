import '../entities/driver_assigned_box_entity.dart';
import '../entities/driver_box_delivery_status.dart';

class DriverAssignedBoxesFakeData {
  const DriverAssignedBoxesFakeData._();

  static const int totalMealsCount = 53;
  static const int totalBoxesCount = 15;

  static const List<DriverAssignedBoxEntity> defaultBoxes = [
    // Boxes pending completion of action (لم يتم التحميل / استكمال الاجراء)
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 3,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.notLoaded,
      isLoaded: false,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 3,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.notLoaded,
      isLoaded: false,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 3,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.notLoaded,
      isLoaded: false,
    ),
    // Matches Figma screenshot Card 1
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 3,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.ready,
      isLoaded: false,
    ),
    // 2. Matches Figma screenshot Card 2
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 3,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.ready,
      isLoaded: false,
    ),
    // 3. Matches Figma screenshot Card 3 (Delivered / Photographed)
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 3,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.delivered,
      isLoaded: true,
    ),
    // 4. Matches Figma screenshot Card 4 (Failed / Problem occurred)
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 4,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.failed,
      isLoaded: false,
    ),
    // 5. Matches Figma screenshot Card 5
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 6,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.ready,
      isLoaded: false,
    ),
    // 6. Delivered / Photographed
    DriverAssignedBoxEntity(
      boxId: '#BOX-1257',
      orderCode: '#MM-1257',
      mealCount: 2,
      area: 'حي الياسمين',
      status: DriverBoxDeliveryStatus.delivered,
      isLoaded: true,
    ),
    // 7. Ready
    DriverAssignedBoxEntity(
      boxId: '#BOX-1258',
      orderCode: '#MM-1258',
      mealCount: 5,
      area: 'حي حطين',
      status: DriverBoxDeliveryStatus.ready,
      isLoaded: false,
    ),
    // 8. Failed
    DriverAssignedBoxEntity(
      boxId: '#BOX-1259',
      orderCode: '#MM-1259',
      mealCount: 4,
      area: 'حي الملقا',
      status: DriverBoxDeliveryStatus.failed,
      isLoaded: false,
    ),
    // 9. Delivered / Photographed
    DriverAssignedBoxEntity(
      boxId: '#BOX-1260',
      orderCode: '#MM-1260',
      mealCount: 3,
      area: 'حي الصحافة',
      status: DriverBoxDeliveryStatus.delivered,
      isLoaded: true,
    ),
    // 10. Ready
    DriverAssignedBoxEntity(
      boxId: '#BOX-1261',
      orderCode: '#MM-1261',
      mealCount: 4,
      area: 'حي العارض',
      status: DriverBoxDeliveryStatus.ready,
      isLoaded: false,
    ),
    // 11. Ready
    DriverAssignedBoxEntity(
      boxId: '#BOX-1262',
      orderCode: '#MM-1262',
      mealCount: 2,
      area: 'حي النرجس',
      status: DriverBoxDeliveryStatus.ready,
      isLoaded: false,
    ),
    // 12. Delivered / Photographed
    DriverAssignedBoxEntity(
      boxId: '#BOX-1263',
      orderCode: '#MM-1263',
      mealCount: 5,
      area: 'حي العقيق',
      status: DriverBoxDeliveryStatus.delivered,
      isLoaded: true,
    ),
  ];
}
