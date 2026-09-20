import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenService tokenService;
  late FlutterSecureStorage secureStorage;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    sharedPreferences = await SharedPreferences.getInstance();
    secureStorage = const FlutterSecureStorage();
    tokenService = TokenService(
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
    );
  });

  group('TokenService Storage Isolation & Security Tests', () {
    test(
      'saves sensitive tokens in FlutterSecureStorage and flags in SharedPreferences',
      () async {
        await tokenService.saveAccessToken('secret_access_token');
        await tokenService.saveRefreshToken('secret_refresh_token');

        // Secure storage contains secrets
        expect(
          await secureStorage.read(key: CoreStorageKeys.accessToken),
          'secret_access_token',
        );
        expect(
          await secureStorage.read(key: CoreStorageKeys.refreshToken),
          'secret_refresh_token',
        );

        // SharedPreferences does NOT contain raw secret tokens
        expect(
          sharedPreferences.getString(CoreStorageKeys.accessToken),
          isNull,
        );
        expect(
          sharedPreferences.getString(CoreStorageKeys.refreshToken),
          isNull,
        );

        // SharedPreferences contains flags
        expect(
          sharedPreferences.getBool(CoreStorageKeys.isAccessTokenSaved),
          isTrue,
        );
        expect(
          sharedPreferences.getBool(CoreStorageKeys.isRefreshTokenSaved),
          isTrue,
        );
      },
    );

    test('saveSession and clearTokens perform atomic operations', () async {
      await tokenService.saveSession(
        accessToken: 'access-123',
        refreshToken: 'refresh-456',
        userId: 'user-789',
        role: 'Driver',
        phone: '+966501234567',
        fullName: 'Driver Name',
        restaurantId: 'rest-1',
        accountStatus: 'Active',
      );

      expect(await tokenService.getToken(), 'access-123');
      expect(await tokenService.getRefreshToken(), 'refresh-456');
      expect(tokenService.getCurrentUserId(), 'user-789');
      expect(tokenService.getSavedRole(), 'Driver');
      expect(tokenService.getSavedPhone(), '+966501234567');
      expect(tokenService.getSavedFullName(), 'Driver Name');
      expect(tokenService.getSavedRestaurantId(), 'rest-1');
      expect(tokenService.getSavedAccountStatus(), 'Active');

      // Clear tokens and session
      await tokenService.clearTokens();

      expect(await tokenService.getToken(), isNull);
      expect(await tokenService.getRefreshToken(), isNull);
      expect(tokenService.getCurrentUserId(), isNull);
      expect(tokenService.getSavedRole(), isNull);
      expect(tokenService.getSavedPhone(), isNull);
      expect(tokenService.getSavedFullName(), isNull);
      expect(
        sharedPreferences.getBool(CoreStorageKeys.isAccessTokenSaved),
        isFalse,
      );
      expect(
        sharedPreferences.getBool(CoreStorageKeys.isRefreshTokenSaved),
        isFalse,
      );
    });
  });
}
