import '../../../../../core/constants/assets.dart';
import '../entities/reassign_driver_candidate_entity.dart';

class DispatcherReassignDriverFakeData {
  const DispatcherReassignDriverFakeData._();

  static const List<ReassignDriverCandidateEntity> defaultCandidates = [
    ReassignDriverCandidateEntity(
      id: 'driver_1',
      name: 'محمد العازمي',
      code: 'DR-2011',
      isAvailable: true,
      rating: 4.8,
      ordersCount: 18,
      distanceKm: 1.2,
      avatarAsset: AppAssets.registrationDriverRole,
    ),
    ReassignDriverCandidateEntity(
      id: 'driver_2',
      name: 'يوسف المطيري',
      code: 'DR-2054',
      isAvailable: true,
      rating: 4.7,
      ordersCount: 12,
      distanceKm: 1.6,
      avatarAsset: AppAssets.registrationDriverRole,
    ),
    ReassignDriverCandidateEntity(
      id: 'driver_3',
      name: 'عبدالله الشمري',
      code: 'DR-1988',
      isAvailable: true,
      rating: 4.6,
      ordersCount: 9,
      distanceKm: 2.1,
      avatarAsset: AppAssets.registrationDriverRole,
    ),
    ReassignDriverCandidateEntity(
      id: 'driver_4',
      name: 'سالم الحربي',
      code: 'DR-2100',
      isAvailable: true,
      rating: 4.5,
      ordersCount: 15,
      distanceKm: 2.4,
      avatarAsset: AppAssets.registrationDriverRole,
    ),
    ReassignDriverCandidateEntity(
      id: 'driver_5',
      name: 'فهد العنزي',
      code: 'DR-2077',
      isAvailable: true,
      rating: 4.4,
      ordersCount: 8,
      distanceKm: 2.8,
      avatarAsset: AppAssets.registrationDriverRole,
    ),
  ];
}
