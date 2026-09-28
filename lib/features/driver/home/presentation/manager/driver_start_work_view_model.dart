import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_driver_start_work_usecase.dart';
import '../../domain/usecases/start_driver_shift_usecase.dart';
import 'driver_start_work_state.dart';

class DriverStartWorkViewModel extends Cubit<DriverStartWorkState> {
  DriverStartWorkViewModel({
    required GetDriverStartWorkUseCase getDriverStartWorkUseCase,
    required StartDriverShiftUseCase startDriverShiftUseCase,
  })  : _getDriverStartWorkUseCase = getDriverStartWorkUseCase,
        _startDriverShiftUseCase = startDriverShiftUseCase,
        super(const DriverStartWorkState());

  final GetDriverStartWorkUseCase _getDriverStartWorkUseCase;
  final StartDriverShiftUseCase _startDriverShiftUseCase;

  Future<void> loadOverview() async {
    emit(state.copyWith(status: DriverStartWorkStatus.loading));
    try {
      final data = await _getDriverStartWorkUseCase();
      emit(state.copyWith(
        status: DriverStartWorkStatus.loaded,
        data: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DriverStartWorkStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> startShift() async {
    await _startDriverShiftUseCase();
  }
}
