import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_cached_network_image.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_area_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_sort.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_area_chips.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_avatar_with_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_card_action_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_content_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_empty_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_sort_sheet.dart';

void main() {
  Widget buildSubject(Widget child, {Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  const sampleAvailableDriver = DispatcherDriverEntity(
    driverId: '11111111-1111-1111-1111-111111111111',
    driverCode: 'ID:D-1025',
    fullName: 'أحمد إبراهيم',
    avatarUrl: 'https://example.com/avatar.png',
    rating: 4.9,
    status: DispatcherDriverStatus.available,
    statusText: 'متاح',
    statusDotColor: '#10B981',
    isAvailableForSelection: true,
    activeOrdersCount: 0,
    activeOrdersText: '0 بوكسات',
    completedOrdersTodayCount: 14,
    completedOrdersText: '14 توصيلة اليوم',
    distanceKm: 2.4,
    distanceText: '2.4 كم',
    currentZoneName: 'السالمية',
    currentZoneKey: 'salmiya',
  );

  const sampleUnavailableDriver = DispatcherDriverEntity(
    driverId: '22222222-2222-2222-2222-222222222222',
    driverCode: 'ID:D-1026',
    fullName: 'محمد السعيد',
    avatarUrl: null,
    rating: 4.7,
    status: DispatcherDriverStatus.busy,
    statusText: 'مشغول',
    statusDotColor: '#F59E0B',
    isAvailableForSelection: false,
    activeOrdersCount: 2,
    activeOrdersText: '2 بوكسات',
    completedOrdersTodayCount: 11,
    completedOrdersText: '11 توصيلة اليوم',
    distanceKm: 3.1,
    distanceText: '3.1 كم',
    currentZoneName: 'السالمية',
    currentZoneKey: 'salmiya',
  );

  group('DispatcherDriversShimmer & ContentShimmer', () {
    testWidgets(
      'full shimmer uses ShimmerWidget and no CircularProgressIndicator',
      (tester) async {
        await tester.pumpWidget(buildSubject(const DispatcherDriversShimmer()));
        expect(find.byType(ShimmerWidget), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('content shimmer uses ShimmerWidget', (tester) async {
      await tester.pumpWidget(
        buildSubject(const DispatcherDriversContentShimmer()),
      );
      expect(find.byType(ShimmerWidget), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('DispatcherDriversEmptyState', () {
    testWidgets('renders EmptyStateWidget with action button', (tester) async {
      bool refreshed = false;
      await tester.pumpWidget(
        buildSubject(
          DispatcherDriversEmptyState(onRefresh: () => refreshed = true),
        ),
      );

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('لا يوجد سائقون'), findsOneWidget);

      await tester.tap(find.text('تحديث'));
      expect(refreshed, isTrue);
    });
  });

  group('DispatcherDriversAreaChips', () {
    testWidgets('renders server names and driverCount chips', (tester) async {
      final areas = [
        const DispatcherDriverAreaEntity(
          name: 'السالمية',
          areaKey: 'salmiya',
          driverCount: 8,
          isSelected: true,
        ),
        const DispatcherDriverAreaEntity(
          name: 'حولي',
          areaKey: 'hawally',
          driverCount: 5,
          isSelected: false,
        ),
      ];

      DispatcherDriverAreaEntity? selected;
      await tester.pumpWidget(
        buildSubject(
          DispatcherDriversAreaChips(
            areas: areas,
            selectedAreaKey: 'salmiya',
            onAreaSelected: (a) => selected = a,
          ),
        ),
      );

      expect(find.text('السالمية'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('حولي'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.text('حولي'));
      expect(selected?.areaKey, 'hawally');
    });
  });

  group('DispatcherDriversAvatarWithStatus', () {
    testWidgets('renders AppCachedNetworkImage for network avatar', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          const DispatcherDriversAvatarWithStatus(
            status: DispatcherDriverStatus.available,
            avatarUrl: 'https://example.com/avatar.png',
          ),
        ),
      );

      expect(find.byType(AppCachedNetworkImage), findsOneWidget);
    });
  });

  group('DispatcherDriversCard and Action Button', () {
    testWidgets('available driver shows active action button and can tap', (
      tester,
    ) async {
      DispatcherDriverEntity? selected;
      await tester.pumpWidget(
        buildSubject(
          DispatcherDriversCard(
            driver: sampleAvailableDriver,
            onSelect: (d) => selected = d,
          ),
        ),
      );

      expect(find.text('ID:D-1025'), findsOneWidget);
      expect(find.text('أحمد إبراهيم'), findsOneWidget);
      expect(find.text('2.4 كم'), findsOneWidget);
      expect(find.text('اختيار'), findsOneWidget);

      await tester.tap(find.text('اختيار'));
      expect(selected?.driverId, sampleAvailableDriver.driverId);
    });

    testWidgets('unavailable driver shows disabled state and cannot tap', (
      tester,
    ) async {
      DispatcherDriverEntity? selected;
      await tester.pumpWidget(
        buildSubject(
          DispatcherDriversCard(
            driver: sampleUnavailableDriver,
            onSelect: (d) => selected = d,
          ),
        ),
      );

      expect(find.text('غير متاح'), findsOneWidget);
      await tester.tap(find.text('غير متاح'));
      expect(selected, isNull);
    });

    testWidgets(
      'assigning driver shows spinner and disabled state for others',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            const Column(
              children: [
                DispatcherDriversCard(
                  driver: sampleAvailableDriver,
                  isLoading: true,
                ),
                DispatcherDriversCard(
                  driver: sampleAvailableDriver,
                  isDisabled: true,
                ),
              ],
            ),
          ),
        );

        // Loading driver shows circular indicator inside action button
        expect(
          find.descendant(
            of: find.byType(DispatcherDriversCardActionButton),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('DispatcherDriversSortSheet', () {
    testWidgets('displays three sort options and selects one', (tester) async {
      DispatcherDriverSort? chosen;
      await tester.pumpWidget(
        buildSubject(
          DispatcherDriversSortSheet(
            selectedSort: DispatcherDriverSort.nearestDistance,
            onSortSelected: (s) => chosen = s,
          ),
        ),
      );

      expect(find.text('الأقرب مسافة'), findsOneWidget);
      expect(find.text('الأعلى تقييماً'), findsOneWidget);
      expect(find.text('الأقل حمولة نشطة'), findsOneWidget);

      await tester.tap(find.text('الأعلى تقييماً'));
      expect(chosen, DispatcherDriverSort.highestRating);
    });
  });
}
