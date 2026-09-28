import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_driver_active_home_usecase.dart';
import 'driver_active_home_state.dart';

class DriverActiveHomeViewModel extends Cubit<DriverActiveHomeState> {
  DriverActiveHomeViewModel({
    required GetDriverActiveHomeUseCase getDriverActiveHomeUseCase,
  })  : _getDriverActiveHomeUseCase = getDriverActiveHomeUseCase,
        super(const DriverActiveHomeState());

  final GetDriverActiveHomeUseCase _getDriverActiveHomeUseCase;

  Future<void> loadOverview() async {
    emit(state.copyWith(status: DriverActiveHomeStatus.loading));
    try {
      final data = await _getDriverActiveHomeUseCase();
      emit(state.copyWith(
        status: DriverActiveHomeStatus.loaded,
        data: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DriverActiveHomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
