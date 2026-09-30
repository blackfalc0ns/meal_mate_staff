import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/repo/driver_profile_repository.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/usecase/get_driver_profile_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/manager/driver_profile_event.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/manager/driver_profile_view_model.dart';

class _MockProfileRepository implements DriverProfileRepository {
  final List<Future<ApiResult<DriverProfileEntity>> Function()> _handlers = [];
  int callCount = 0;

  void addHandler(Future<ApiResult<DriverProfileEntity>> Function() handler) {
    _handlers.add(handler);
  }

  @override
  Future<ApiResult<DriverProfileEntity>> getProfile() async {
    callCount++;
    if (_handlers.isNotEmpty) {
      final handler = _handlers.removeAt(0);
      return handler();
    }
    return const ApiSuccessResult(
      data: DriverProfileEntity(
        driverProfileId: '1',
        fullName: 'Default',
        driverDescription: 'Desc',
        driverCode: 'CODE',
        isOnline: true,
        status: 'Active',
        statusText: 'Active',
        reviewsCount: 0,
        totalOrders: 0,
      ),
    );
  }
}

void main() {
  group('DriverProfileViewModel', () {
    late _MockProfileRepository repository;
    late GetDriverProfileUseCase useCase;
    late DriverProfileViewModel viewModel;

    const profile = DriverProfileEntity(
      driverProfileId: 'drv-1',
      fullName: 'أحمد إبراهيم',
      driverDescription: 'سائق معتمد',
      driverCode: 'DRV01',
      isOnline: true,
      status: 'Online',
      statusText: 'متصل',
      reviewsCount: 10,
      totalOrders: 50,
    );

    const englishProfile = DriverProfileEntity(
      driverProfileId: 'drv-1',
      fullName: 'Ahmed Ibrahim',
      driverDescription: 'Certified Driver',
      driverCode: 'DRV01',
      isOnline: true,
      status: 'Online',
      statusText: 'Online',
      reviewsCount: 10,
      totalOrders: 50,
    );

    setUp(() {
      repository = _MockProfileRepository();
      useCase = GetDriverProfileUseCase(repository);
      viewModel = DriverProfileViewModel(getDriverProfileUseCase: useCase);
    });

    test('coalesces two non-forced loads while one request is active',
        () async {
      final pending = Completer<ApiResult<DriverProfileEntity>>();
      repository.addHandler(() => pending.future);

      final first =
          viewModel.doIntent(const DriverProfileStarted(locale: 'ar'));
      final second =
          viewModel.doIntent(const DriverProfileStarted(locale: 'ar'));

      expect(repository.callCount, 1);
      pending.complete(const ApiSuccessResult(data: profile));
      await Future.wait<void>([first, second]);
      expect(viewModel.state.profile, profile);
      expect(viewModel.state.isInitialLoading, isFalse);
    });

    test('keeps content visible during pull refresh', () async {
      // First load successfully
      repository.addHandler(
        () async => const ApiSuccessResult(data: profile),
      );
      await viewModel.doIntent(const DriverProfileStarted(locale: 'ar'));
      expect(viewModel.state.profile, profile);

      // Now trigger refresh with pending completer
      final pending = Completer<ApiResult<DriverProfileEntity>>();
      repository.addHandler(() => pending.future);

      final refreshFuture =
          viewModel.doIntent(const DriverProfileRefreshed(locale: 'ar'));

      expect(viewModel.state.profile, profile);
      expect(viewModel.state.isRefreshing, isTrue);

      pending.complete(const ApiSuccessResult(data: profile));
      await refreshFuture;
      expect(viewModel.state.isRefreshing, isFalse);
    });

    test('ignores an older response after locale changes', () async {
      final ar = Completer<ApiResult<DriverProfileEntity>>();
      final en = Completer<ApiResult<DriverProfileEntity>>();

      repository.addHandler(() => ar.future);
      repository.addHandler(() => en.future);

      unawaited(viewModel.doIntent(const DriverProfileStarted(locale: 'ar')));
      unawaited(
        viewModel.doIntent(const DriverProfileLocaleChanged(locale: 'en')),
      );

      en.complete(const ApiSuccessResult(data: englishProfile));
      ar.complete(const ApiSuccessResult(data: profile));

      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.profile, englishProfile);
      expect(viewModel.state.localeCode, 'en');
    });

    test('preserves content and sets inlineFailure on refresh failure',
        () async {
      // First load successfully
      repository.addHandler(
        () async => const ApiSuccessResult(data: profile),
      );
      await viewModel.doIntent(const DriverProfileStarted(locale: 'ar'));

      // Now refresh with error
      repository.addHandler(
        () async => ApiErrorResult(
          failure: ServerFailure(
            errorMessage: 'Server error',
            exception: const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Server error',
            ),
          ),
        ),
      );
      await viewModel.doIntent(const DriverProfileRefreshed(locale: 'ar'));

      expect(viewModel.state.profile, profile);
      expect(viewModel.state.isRefreshing, isFalse);
      expect(viewModel.state.inlineFailure, isNotNull);
      expect(viewModel.state.failure, isNull);
    });

    test('tab activation does not refetch if data is fresh (< 15 mins)',
        () async {
      repository.addHandler(
        () async => const ApiSuccessResult(data: profile),
      );
      await viewModel.doIntent(const DriverProfileStarted(locale: 'ar'));
      expect(repository.callCount, 1);

      // Reactivate tab
      await viewModel.doIntent(const DriverProfileActivated(locale: 'ar'));
      expect(repository.callCount, 1);
    });
  });
}
