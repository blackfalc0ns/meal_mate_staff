import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_cached_network_image.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_driver_suggestion_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/widgets/dispatcher_driver_suggestion_tile.dart';

void main() {
  Widget buildSubject({
    required DispatcherOrderEntity order,
    Locale locale = const Locale('ar'),
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: DispatcherDriverSuggestionTile(order: order),
        ),
      ),
    );
  }

  testWidgets(
    'renders SizedBox.shrink when suggestion is null',
    (tester) async {
      const order = DispatcherOrderEntity(
        id: '1',
        boxCode: '#BX-100',
        priority: DispatcherOrderPriority.newOrder,
        status: DispatcherOrderStatus.pending,
        area: 'السالمية',
        deliveryTimeWindow: '10:00',
        mealsCount: 5,
        distanceKm: 3.5,
        suggestion: null,
      );

      await tester.pumpWidget(buildSubject(order: order));
      expect(find.byType(DispatcherDriverSuggestionTile), findsOneWidget);
      expect(find.byType(AppCachedNetworkImage), findsNothing);
    },
  );

  testWidgets(
    'renders AppCachedNetworkImage with backend avatarUrl and driver details',
    (tester) async {
      const order = DispatcherOrderEntity(
        id: '1',
        boxCode: '#BX-100',
        priority: DispatcherOrderPriority.newOrder,
        status: DispatcherOrderStatus.pending,
        area: 'السالمية',
        deliveryTimeWindow: '10:00',
        mealsCount: 5,
        distanceKm: 3.5,
        suggestion: DispatcherDriverSuggestionEntity(
          driverId: 'drv-1',
          driverName: 'سعد المنصور',
          avatarUrl: 'https://cdn.mealmate.app/avatars/5db39f96.jpg',
          suggestionType: DispatcherDriverSuggestionType.nearest,
          label: 'الأقرب: سعد المنصور',
        ),
      );

      await tester.pumpWidget(buildSubject(order: order));
      await tester.pump();

      expect(find.textContaining('سعد المنصور'), findsOneWidget);
      final imageFinder = find.byType(AppCachedNetworkImage);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<AppCachedNetworkImage>(imageFinder);
      expect(
        imageWidget.imageUrl,
        'https://cdn.mealmate.app/avatars/5db39f96.jpg',
      );
      expect(imageWidget.shape, BoxShape.circle);
      expect(imageWidget.fit, BoxFit.cover);
      expect(imageWidget.errorWidget, isNotNull);
      expect(imageWidget.loadingWidget, isNotNull);
    },
  );

  testWidgets(
    'falls back to person icon when avatarUrl is null',
    (tester) async {
      const order = DispatcherOrderEntity(
        id: '1',
        boxCode: '#BX-100',
        priority: DispatcherOrderPriority.newOrder,
        status: DispatcherOrderStatus.pending,
        area: 'السالمية',
        deliveryTimeWindow: '10:00',
        mealsCount: 5,
        distanceKm: 3.5,
        suggestion: DispatcherDriverSuggestionEntity(
          driverId: 'drv-2',
          driverName: 'خالد',
          avatarUrl: null,
          suggestionType: DispatcherDriverSuggestionType.leastLoaded,
          label: 'الأقل حملاً: خالد',
        ),
      );

      await tester.pumpWidget(buildSubject(order: order));
      await tester.pump();

      expect(find.textContaining('خالد'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    },
  );
}
