import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/delivery_contact_case_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/driver_call_attempt_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_display_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_eligibility_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_snapshot_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_status.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/repo/driver_calling_repository.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/cancel_voice_call_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/check_call_eligibility_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/end_voice_call_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/get_active_voice_call_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/get_delivery_contact_case_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/get_voice_call_display_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/get_voice_call_snapshot_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/hold_delivery_contact_case_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/initiate_voice_call_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/resume_delivery_contact_case_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/reveal_customer_phone_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/manager/driver_calling_view_model.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/customer_call_attempts_sheet.dart';

class _FakeCallingRepo implements DriverCallingRepository {
  // ignore: close_sinks
  final _snapshotCtrl = StreamController<VoiceCallSnapshotEntity>.broadcast();
  // ignore: close_sinks
  final _statusCtrl = StreamController<VoiceCallStatus>.broadcast();

  @override
  Stream<VoiceCallSnapshotEntity> get onSnapshotUpdated => _snapshotCtrl.stream;

  @override
  Stream<VoiceCallStatus> get onStatusChanged => _statusCtrl.stream;

  @override
  Future<ApiResult<VoiceCallDisplayEntity>> getCallDisplay(
    String callId, {
    String? languageCode,
  }) async {
    return const ApiSuccessResult(
      data: VoiceCallDisplayEntity(callId: 'call-1', tripStopId: 'stop-1'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DriverCallingViewModel _createViewModel(_FakeCallingRepo repo) {
  return DriverCallingViewModel(
    checkCallEligibilityUseCase: CheckCallEligibilityUseCase(repo),
    initiateVoiceCallUseCase: InitiateVoiceCallUseCase(repo),
    cancelVoiceCallUseCase: CancelVoiceCallUseCase(repo),
    endVoiceCallUseCase: EndVoiceCallUseCase(repo),
    getActiveVoiceCallUseCase: GetActiveVoiceCallUseCase(repo),
    getVoiceCallSnapshotUseCase: GetVoiceCallSnapshotUseCase(repo),
    getDeliveryContactCaseUseCase: GetDeliveryContactCaseUseCase(repo),
    holdDeliveryContactCaseUseCase: HoldDeliveryContactCaseUseCase(repo),
    resumeDeliveryContactCaseUseCase: ResumeDeliveryContactCaseUseCase(repo),
    revealCustomerPhoneUseCase: RevealCustomerPhoneUseCase(repo),
    getVoiceCallDisplayUseCase: GetVoiceCallDisplayUseCase(repo),
    repository: repo,
  );
}

Widget _buildTestWidget({
  DriverCallAttemptEntity? attempt,
  VoidCallback? onStartCall,
  VoidCallback? onDirectCall,
  VoidCallback? onReportUnreachable,
  DriverCallingViewModel? viewModel,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: const Locale('ar'),
    home: Scaffold(
      body: CustomerCallAttemptsSheet(
        initialAttempt: attempt,
        onStartCall: onStartCall,
        onDirectCall: onDirectCall,
        onReportUnreachable: onReportUnreachable,
        viewModel: viewModel,
      ),
    ),
  );
}

void main() {
  group('CustomerCallAttemptsSheet', () {
    testWidgets('renders Attempt 1 UI with Call Now and Cancel buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestWidget(
          attempt: const DriverCallAttemptEntity(
            customerName: 'محمد علي',
            customerPhone: '+966 50 123 4567',
            attemptNumber: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الاتصال بالعميل'), findsOneWidget);
      expect(
        find.text('هل تريد الاتصال بالعميل محمد علي الآن؟'),
        findsOneWidget,
      );
      expect(find.text('اتصل الآن'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('رقم الهاتف محمي'), findsOneWidget);
    });

    testWidgets('renders Attempt 2 UI with warning banner', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          attempt: const DriverCallAttemptEntity(
            customerName: 'محمد علي',
            customerPhone: '+966 50 123 4567',
            attemptNumber: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لم يتم الرد من العميل'), findsOneWidget);
      expect(find.text('المحاولة 1 من 3'), findsOneWidget);
      expect(find.text('اتصل الآن'), findsOneWidget);
    });

    testWidgets(
      'renders Attempt 3 UI with recovery options and phone unlocked',
      (tester) async {
        var directCalled = false;
        var reportCalled = false;

        await tester.pumpWidget(
          _buildTestWidget(
            attempt: const DriverCallAttemptEntity(
              customerName: 'محمد علي',
              customerPhone: '+966 50 123 4567',
              attemptNumber: 3,
            ),
            onDirectCall: () => directCalled = true,
            onReportUnreachable: () => reportCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('تعذر التواصل مع العميل'), findsOneWidget);
        expect(find.text('تم إتاحة الاتصال الخارجي'), findsOneWidget);
        expect(find.text('اتصل برقم الهاتف الخارجي'), findsOneWidget);
        expect(find.text('إبلاغ عن تعذر التواصل'), findsOneWidget);

        await tester.tap(find.text('اتصل برقم الهاتف الخارجي'));
        await tester.pump();
        expect(directCalled, isTrue);

        await tester.tap(find.text('إبلاغ عن تعذر التواصل'));
        await tester.pump();
        expect(reportCalled, isTrue);
      },
    );

    testWidgets('triggers onStartCall callback when tapping Call Now', (
      tester,
    ) async {
      var callStarted = false;

      await tester.pumpWidget(
        _buildTestWidget(onStartCall: () => callStarted = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('اتصل الآن'));
      await tester.pump();
      expect(callStarted, isTrue);
    });

    testWidgets(
      'renders Call Now button when canHold is true but canInitiate is true and attempt < 3',
      (tester) async {
        final repo = _FakeCallingRepo();
        final vm = _createViewModel(repo);

        // State matching user's scenario: canHold is true, canInitiate is true, canRevealPhone is false
        vm.emit(
          vm.state.copyWith(
            contactCase: const DeliveryContactCaseEntity(
              contactCaseId: 'case-1',
              tripStopId: 'stop-1',
              status: 'Open',
              attemptCount: 1,
              canHold: true,
              canRevealPhone: false,
            ),
            eligibility: const VoiceCallEligibilityEntity(
              canInitiate: true,
              reasonCode: 'contact.eligible',
              canHold: false,
              canRevealPhone: false,
            ),
          ),
        );

        await tester.pumpWidget(
          _buildTestWidget(
            viewModel: vm,
            attempt: const DriverCallAttemptEntity(
              customerName: 'yyytttt',
              customerPhone: '+966 50 123 4567',
              attemptNumber: 1,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must show Call Now button ("اتصل الآن") and Cancel ("إلغاء")
        expect(find.text('اتصل الآن'), findsOneWidget);
        expect(find.text('إلغاء'), findsOneWidget);
        expect(find.text('رقم الهاتف محمي'), findsOneWidget);

        // Must NOT show recovery options when canInitiate is true and attempt < 3
        expect(find.text('اتصل برقم الهاتف الخارجي'), findsNothing);
        expect(find.text('إبلاغ عن تعذر التواصل'), findsNothing);
      },
    );
  });
}
