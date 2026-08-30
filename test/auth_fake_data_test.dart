import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/auth/data/auth_fake_data.dart';

void main() {
  test('provides configured phone and email verification targets', () {
    expect(AuthFakeData.phoneVerificationTarget.value, '+966 50 123 4567');
    expect(
      AuthFakeData.emailVerificationTarget.value,
      'IbrahimYasser@gmail.com',
    );
  });
}
