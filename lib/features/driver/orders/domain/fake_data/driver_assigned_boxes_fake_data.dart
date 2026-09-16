import '../entities/driver_assigned_box_entity.dart';

class DriverAssignedBoxesFakeData {
  const DriverAssignedBoxesFakeData._();

  static const int totalMealsCount = 32;
  static const int totalBoxesCount = 8;

  static const List<DriverAssignedBoxEntity> defaultBoxes = [
    DriverAssignedBoxEntity(
      boxId: '#BOX-1256',
      orderCode: '#MM-1256',
      mealCount: 3,
      area: 'حي النرجس',
      isLoaded: false,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1257',
      orderCode: '#MM-1257',
      mealCount: 3,
      area: 'حي النرجس',
      isLoaded: false,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1258',
      orderCode: '#MM-1258',
      mealCount: 3,
      area: 'حي النرجس',
      isLoaded: false,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1259',
      orderCode: '#MM-1259',
      mealCount: 3,
      area: 'حي النرجس',
      isLoaded: false,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1260',
      orderCode: '#MM-1260',
      mealCount: 4,
      area: 'حي النرجس',
      isLoaded: true,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1261',
      orderCode: '#MM-1261',
      mealCount: 4,
      area: 'حي النرجس',
      isLoaded: true,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1262',
      orderCode: '#MM-1262',
      mealCount: 6,
      area: 'حي الياسمين',
      isLoaded: true,
    ),
    DriverAssignedBoxEntity(
      boxId: '#BOX-1263',
      orderCode: '#MM-1263',
      mealCount: 6,
      area: 'حي حطين',
      isLoaded: true,
    ),
  ];
}
