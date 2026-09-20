import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/phone_lookup_request_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await getIt.reset();
  });

  test(
    'configureDependencies exposes one Dio and one ApiServices sharing the same Dio graph',
    () async {
      await configureDependencies();

      expect(getIt.isRegistered<Dio>(), isTrue);
      expect(getIt.isRegistered<ApiServices>(), isTrue);

      final dio = getIt<Dio>();
      final apiServices = getIt<ApiServices>();

      expect(dio, isNotNull);
      expect(apiServices, isNotNull);

      bool intercepted = false;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            intercepted = true;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'exists': true, 'isFirstTimeSetup': false},
              ),
            );
          },
        ),
      );

      final result = await apiServices.lookupPhone(
        const PhoneLookupRequestDto(phone: '+966500000000', role: 'Driver'),
      );

      expect(intercepted, isTrue);
      expect(result.exists, isTrue);
    },
  );
}
