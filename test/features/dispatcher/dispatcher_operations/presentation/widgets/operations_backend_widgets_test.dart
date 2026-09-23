import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_cached_network_image.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_counters_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_customer_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_indicator_color.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_pagination_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_pagination_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_status_tabs.dart';

Widget createLocalizedWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: const Locale('ar'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('OperationsCard variants', () {
    testWidgets(
      'renders completed card with AppCachedNetworkImage and customer info',
      (tester) async {
        const item = OperationItemEntity(
          id: '1',
          boxId: 'box-1',
          boxCode: '#BX-10256',
          status: OperationStatus.completed,
          customer: OperationsCustomerEntity(
            id: 'c1',
            name: 'شهد المطيري',
            area: 'حي الملقا',
            addressText: 'حي الملقا',
          ),
          timeText: '10:45 ص',
          driver: OperationsDriverEntity(
            id: 'd1',
            name: 'يوسف خالد',
            avatarUrl: 'https://example.com/avatar.jpg',
            indicatorColor: OperationsIndicatorColor.green,
          ),
        );

        OperationItemEntity? tappedItem;

        await tester.pumpWidget(
          createLocalizedWidget(
            OperationsCard(
              item: item,
              onTap: (selected) => tappedItem = selected,
            ),
          ),
        );

        expect(find.text('#BX-10256'), findsOneWidget);
        expect(find.text('يوسف خالد'), findsOneWidget);
        expect(find.text('عميل: شهد المطيري'), findsOneWidget);
        expect(find.byType(AppCachedNetworkImage), findsWidgets);

        await tester.tap(find.byType(OperationsCard));
        expect(tappedItem?.boxId, 'box-1');
      },
    );

    testWidgets(
      'renders reassigned card with original and replacement drivers',
      (tester) async {
        const item = OperationItemEntity(
          id: '2',
          boxId: 'box-2',
          boxCode: '#BX-10255',
          status: OperationStatus.reassigned,
          customer: OperationsCustomerEntity(
            id: 'c2',
            name: 'أحمد العتيبي',
            area: 'حي الياسمين',
            addressText: 'حي الياسمين',
          ),
          timeText: '11:00 ص',
          originalDriver: OperationsDriverEntity(
            id: 'd1',
            name: 'فهد المطيري',
            avatarUrl: 'https://example.com/fahd.jpg',
            indicatorColor: OperationsIndicatorColor.orange,
          ),
          replacementDriver: OperationsDriverEntity(
            id: 'd2',
            name: 'يوسف خالد',
            avatarUrl: 'https://example.com/yousef.jpg',
            indicatorColor: OperationsIndicatorColor.green,
          ),
        );

        await tester.pumpWidget(
          createLocalizedWidget(const OperationsCard(item: item)),
        );

        expect(find.text('فهد المطيري'), findsOneWidget);
        expect(find.text('يوسف خالد'), findsOneWidget);
        expect(find.byType(AppCachedNetworkImage), findsWidgets);
      },
    );

    testWidgets('renders cancelled card with reason and storefront icon', (
      tester,
    ) async {
      const item = OperationItemEntity(
        id: '3',
        boxId: 'box-3',
        boxCode: '#BX-10254',
        status: OperationStatus.cancelled,
        customer: OperationsCustomerEntity(
          id: 'c3',
          name: 'نورة السبيعي',
          area: 'حي النرجس',
          addressText: 'حي النرجس',
        ),
        timeText: '11:30 ص',
        cancelledByText: 'تم الإلغاء من قبل المطعم',
      );

      await tester.pumpWidget(
        createLocalizedWidget(const OperationsCard(item: item)),
      );

      expect(find.text('تم الإلغاء من قبل المطعم'), findsOneWidget);
      expect(find.text('#BX-10254'), findsOneWidget);
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
    });

    testWidgets('renders unknown operation status safely without crashing', (
      tester,
    ) async {
      const item = OperationItemEntity(
        id: '4',
        boxId: 'box-4',
        boxCode: '#BX-9999',
        status: OperationStatus.unknown,
        customer: OperationsCustomerEntity(
          id: 'c4',
          name: 'عميل مجهول',
          area: 'الرياض',
          addressText: 'الرياض',
        ),
        timeText: '01:00 م',
      );

      await tester.pumpWidget(
        createLocalizedWidget(const OperationsCard(item: item)),
      );
      expect(find.text('#BX-9999'), findsOneWidget);
    });
  });

  group('OperationsStatusTabs and OperationsPaginationBar', () {
    testWidgets(
      'OperationsStatusTabs renders backend counts and selects status',
      (tester) async {
        const counters = OperationsCountersEntity(
          allCount: 128,
          completedCount: 98,
          cancelledCount: 3,
          failedCount: 7,
          reassignedCount: 17,
        );

        OperationStatus? selected;

        await tester.pumpWidget(
          createLocalizedWidget(
            OperationsStatusTabs(
              counters: counters,
              selectedStatus: OperationStatus.all,
              onStatusSelected: (status) => selected = status,
            ),
          ),
        );

        expect(find.text('128'), findsOneWidget);
        expect(find.text('98'), findsOneWidget);

        await tester.tap(find.text('مكتملة'));
        expect(selected, OperationStatus.completed);
      },
    );

    testWidgets(
      'OperationsPaginationBar displays backend page info and respects isLoading',
      (tester) async {
        const pagination = OperationsPaginationEntity(
          pageNumber: 1,
          pageSize: 10,
          totalItems: 150,
          totalPages: 15,
          hasPreviousPage: false,
          hasNextPage: true,
        );

        var nextTapped = false;

        await tester.pumpWidget(
          createLocalizedWidget(
            OperationsPaginationBar(
              pagination: pagination,
              isLoading: false,
              onNextTap: () => nextTapped = true,
            ),
          ),
        );

        expect(find.text('1 من 15'), findsOneWidget);

        await tester.tap(find.text('التالي'));
        expect(nextTapped, isTrue);

        // When loading, interaction is disabled
        nextTapped = false;
        await tester.pumpWidget(
          createLocalizedWidget(
            OperationsPaginationBar(
              pagination: pagination,
              isLoading: true,
              onNextTap: () => nextTapped = true,
            ),
          ),
        );

        await tester.tap(find.text('التالي'));
        expect(nextTapped, isFalse);
      },
    );
  });
}
