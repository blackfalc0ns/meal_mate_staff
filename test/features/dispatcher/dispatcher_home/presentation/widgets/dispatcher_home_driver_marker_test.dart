import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/widget/app_cached_network_image.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_map_driver_pin_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_driver_marker.dart';

void main() {
  testWidgets('renders cached avatar, plate, and status in the marker', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DispatcherHomeDriverMarker(driver: _driver)),
      ),
    );

    expect(find.byType(AppCachedNetworkImage), findsOneWidget);
    expect(find.text('DX-439612'), findsOneWidget);
    expect(find.text('In delivery'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);
  });

  testWidgets('passes the backend avatar URL and reports when it resolves', (
    tester,
  ) async {
    bool? loadedSuccessfully;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DispatcherHomeDriverMarker(
            driver: _driver,
            onAvatarResolved: (didLoad) => loadedSuccessfully = didLoad,
          ),
        ),
      ),
    );

    final avatar = tester.widget<AppCachedNetworkImage>(
      find.byType(AppCachedNetworkImage),
    );
    expect(avatar.imageUrl, 'https://cdn.mealmate.app/avatars/ahmed.jpg');

    await tester.pump();
    expect(loadedSuccessfully, isFalse);
  });
}

const _driver = DispatcherHomeMapDriverPinEntity(
  id: 'driver-1',
  fullName: 'Ahmed',
  phone: '+96550000000',
  plateNumber: 'DX-439612',
  statusText: 'In delivery',
  status: DispatcherHomePinStatus.inDelivery,
  avatarUrl: 'https://cdn.mealmate.app/avatars/ahmed.jpg',
  latitude: 29.3759,
  longitude: 47.9774,
  heading: 0,
  speedKmh: 0,
  updatedAtUtc: null,
);
