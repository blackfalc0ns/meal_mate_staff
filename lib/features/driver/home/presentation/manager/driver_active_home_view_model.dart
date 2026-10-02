import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_driver_active_home_usecase.dart';
import 'package:meal_mate_delivery/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart';
import 'driver_active_home_state.dart';

class DriverActiveHomeViewModel extends Cubit<DriverActiveHomeState> {
  DriverActiveHomeViewModel({
    required this.getDriverActiveHomeUseCase,
    this.locationCoordinator,
  }) : super(const DriverActiveHomeState());

  final GetDriverActiveHomeUseCase getDriverActiveHomeUseCase;
  final DriverLiveLocationCoordinator? locationCoordinator;

  Future<void> loadOverview() async {
    emit(state.copyWith(status: DriverActiveHomeStatus.loading));
    try {
      final data = await getDriverActiveHomeUseCase();
      emit(state.copyWith(
        status: DriverActiveHomeStatus.loaded,
        data: data,
      ));
      if (data.isInDelivery) {
        locationCoordinator?.setActiveBoxesCount(1);
      }
    } catch (e) {
      emit(state.copyWith(
        status: DriverActiveHomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
