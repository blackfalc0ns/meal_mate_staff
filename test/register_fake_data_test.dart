import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/register/data/register_fake_data.dart';

void main() {
  test('provides review data matching the registration review screen', () {
    const data = RegisterFakeData.review;

    expect(data.personal.firstName, 'Ahmad');
    expect(data.personal.lastName, 'Al Sayed');
    expect(data.personal.civilId, '287041812345');
    expect(data.vehicle.model, 'Toyota Corolla');
    expect(data.vehicle.plateNumber, '54821');
    expect(data.documents, hasLength(5));
    expect(
      data.documents.where((document) => document.isUploaded).map(
            (document) => document.id,
          ),
      ['driving-license', 'vehicle-photo'],
    );
  });
}
