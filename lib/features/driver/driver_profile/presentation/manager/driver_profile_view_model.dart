import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/usecase/get_driver_profile_usecase.dart';
import 'driver_profile_event.dart';
import 'driver_profile_state.dart';

@injectable
class DriverProfileViewModel extends Cubit<DriverProfileState> {
  DriverProfileViewModel({
    required GetDriverProfileUseCase getDriverProfileUseCase,
  })  : _getProfileUseCase = getDriverProfileUseCase,
        super(const DriverProfileState());

  final GetDriverProfileUseCase _getProfileUseCase;

  Future<void>? _inFlight;
  String? _inFlightLocale;
  int _generation = 0;

  Future<void> doIntent(DriverProfileEvent event) async {
    switch (event) {
      case DriverProfileStarted(:final locale):
        await _load(locale: locale, force: false);
      case DriverProfileRefreshed(:final locale):
        await _load(locale: locale, force: true);
      case DriverProfileLocaleChanged(:final locale):
        if (state.localeCode != locale) {
          await _load(locale: locale, force: true);
        }
      case DriverProfileActivated(:final locale):
        final isStale = state.lastSuccessfulLoadAt == null ||
            DateTime.now()
                    .toUtc()
                    .difference(state.lastSuccessfulLoadAt!) >=
                const Duration(minutes: 15);
        if (isStale || state.localeCode != locale) {
          await _load(locale: locale, force: state.hasContent);
        }
      case DriverProfileAvatarFailed(:final locale):
        await _load(locale: locale, force: true);
    }
  }

  Future<void> _load({required String locale, required bool force}) {
    if (!force &&
        _inFlight != null &&
        (_inFlightLocale == locale || state.localeCode == locale)) {
      return _inFlight!;
    }
    final generation = ++_generation;
    _inFlightLocale = locale;
    final future = _performLoad(locale: locale, generation: generation);
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
        _inFlightLocale = null;
      }
    });
  }

  Future<void> _performLoad({
    required String locale,
    required int generation,
  }) async {
    if (state.hasContent) {
      emit(
        state.copyWith(
          isRefreshing: true,
          clearInlineFailure: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isInitialLoading: true,
          clearFailure: true,
        ),
      );
    }

    final result = await _getProfileUseCase();

    // Guard against stale responses from older generation
    if (_generation != generation) {
      return;
    }

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          DriverProfileState(
            profile: data,
            isInitialLoading: false,
            isRefreshing: false,
            localeCode: locale,
            lastSuccessfulLoadAt: DateTime.now().toUtc(),
          ),
        );
      case ApiErrorResult(:final failure):
        if (state.hasContent) {
          emit(
            state.copyWith(
              inlineFailure: failure,
              isRefreshing: false,
            ),
          );
        } else {
          emit(
            DriverProfileState(
              failure: failure,
              isInitialLoading: false,
              isRefreshing: false,
              localeCode: locale,
            ),
          );
        }
    }
  }
}
