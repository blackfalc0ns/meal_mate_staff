import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/driver_active_call_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_display_entity.dart';
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
import 'package:meal_mate_delivery/features/driver/calling/presentation/screens/driver_active_call_screen.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_address_card.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_avatar.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_controls_row.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_header.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_top_bar.dart';

class FakeScreenCallingRepo implements DriverCallingRepository {
  // ignore: close_sinks
  final _snapshotCtrl = StreamController<VoiceCallSnapshotEntity>.broadcast();
  // ignore: close_sinks
  final _statusCtrl = StreamController<VoiceCallStatus>.broadcast();

  @override
  Stream<VoiceCallSnapshotEntity> get onSnapshotUpdated => _snapshotCtrl.stream;

  @override
  Stream<VoiceCallStatus> get onStatusChanged => _statusCtrl.stream;

  int cancelCallCount = 0;
  int endCallCount = 0;

  @override
  Future<ApiResult<void>> cancelCall(String callId) async {
    cancelCallCount++;
    return const ApiSuccessResult(data: null);
  }

  @override
  Future<ApiResult<void>> endCall(String callId) async {
    endCallCount++;
    return const ApiSuccessResult(data: null);
  }

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

DriverCallingViewModel createScreenTestViewModel(FakeScreenCallingRepo repo) {
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

void main() {
  Widget buildSubject({
    DriverActiveCallEntity? callData,
    VoidCallback? onEndCall,
    VoidCallback? onDismiss,
    Locale locale = const Locale('ar'),
    bool enableTimer = false,
    DriverCallingViewModel? viewModel,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: DriverActiveCallScreen(
        callData: callData,
        onEndCall: onEndCall,
        onDismiss: onDismiss,
        enableTimer: enableTimer,
        viewModel: viewModel,
      ),
    );
  }

  group('DriverActiveCallScreen', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    testWidgets(
      'renders all call components in RTL Arabic with default fake data',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(DriverCallTopBar), findsOneWidget);
        expect(find.byType(DriverCallHeader), findsOneWidget);
        expect(find.byType(DriverCallAvatar), findsOneWidget);
        expect(find.byType(DriverCallAddressCard), findsOneWidget);
        expect(find.byType(DriverCallControlsRow), findsOneWidget);

        expect(find.text('اتصال جاري...'), findsOneWidget);
        expect(find.text('محمد علي'), findsOneWidget);
        expect(find.text('00:24'), findsOneWidget);
        expect(
          find.text('شارع الخليج العربي ، قطعة 12 ، منزل 45'),
          findsOneWidget,
        );
        expect(find.text('السلمانية'), findsOneWidget);
        expect(find.text('سماعة'), findsOneWidget);
        expect(find.text('كتم الميكروفون'), findsOneWidget);
        expect(find.text('إنهاء المكالمة'), findsOneWidget);
      },
    );

    testWidgets('renders all call components in LTR English', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const customCall = DriverActiveCallEntity(
        customerName: 'Mohammad Ali',
        addressLine: 'Arabian Gulf St, Block 12, House 45',
        area: 'Salmiya',
        initialDurationSeconds: 45,
      );

      await tester.pumpWidget(
        buildSubject(callData: customCall, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Call in progress...'), findsOneWidget);
      expect(find.text('Mohammad Ali'), findsOneWidget);
      expect(find.text('00:45'), findsOneWidget);
      expect(find.text('Arabian Gulf St, Block 12, House 45'), findsOneWidget);
      expect(find.text('Salmiya'), findsOneWidget);
      expect(find.text('Speaker'), findsOneWidget);
      expect(find.text('Mute Microphone'), findsOneWidget);
      expect(find.text('End Call'), findsOneWidget);
    });

    testWidgets('triggers onDismiss and onEndCall callbacks', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool dismissed = false;
      bool ended = false;

      await tester.pumpWidget(
        buildSubject(
          onDismiss: () => dismissed = true,
          onEndCall: () => ended = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);

      await tester.tap(find.byIcon(Icons.call_end_rounded));
      await tester.pumpAndSettle();
      expect(ended, isTrue);
    });

    testWidgets('timer increments duration when enableTimer is true', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(enableTimer: true));
      await tester.pump();
      expect(find.text('00:24'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:25'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:27'), findsOneWidget);
    });

    testWidgets(
      'displays localized status for Ringing and Connecting in Arabic and English',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final repo = FakeScreenCallingRepo();
        final vm = createScreenTestViewModel(repo);

        // Ringing in Arabic
        vm.emit(
          vm.state.copyWith(
            status: VoiceCallStatus.ringing,
            snapshot: const VoiceCallSnapshotEntity(
              callId: 'call-1',
              tripStopId: 'stop-1',
              protocolVersion: 2,
              sequence: 1,
              status: VoiceCallStatus.ringing,
            ),
          ),
        );
        await tester.pumpWidget(
          buildSubject(viewModel: vm, locale: const Locale('ar')),
        );
        await tester.pumpAndSettle();
        expect(find.text('جارٍ الرنين...'), findsOneWidget);

        // Ringing in English
        await tester.pumpWidget(
          buildSubject(viewModel: vm, locale: const Locale('en')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Ringing...'), findsOneWidget);

        // Connecting in Arabic
        vm.emit(vm.state.copyWith(status: VoiceCallStatus.connecting));
        await tester.pumpWidget(
          buildSubject(viewModel: vm, locale: const Locale('ar')),
        );
        await tester.pumpAndSettle();
        expect(find.text('جارٍ الاتصال...'), findsOneWidget);

        // Connecting in English
        await tester.pumpWidget(
          buildSubject(viewModel: vm, locale: const Locale('en')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Connecting...'), findsOneWidget);
      },
    );

    testWidgets(
      'hangup routes to cancelCall when status is Ringing and endCall when Active',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final repo = FakeScreenCallingRepo();
        final vm = createScreenTestViewModel(repo);

        // Ringing -> cancelCall
        vm.emit(
          vm.state.copyWith(
            status: VoiceCallStatus.ringing,
            snapshot: const VoiceCallSnapshotEntity(
              callId: 'call-ringing-1',
              tripStopId: 'stop-1',
              protocolVersion: 2,
              sequence: 1,
              status: VoiceCallStatus.ringing,
            ),
          ),
        );
        await tester.pumpWidget(buildSubject(viewModel: vm));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.call_end_rounded));
        await tester.pumpAndSettle();
        expect(repo.cancelCallCount, 1);
        expect(repo.endCallCount, 0);

        // Active -> endCall
        vm.emit(
          vm.state.copyWith(
            status: VoiceCallStatus.active,
            snapshot: const VoiceCallSnapshotEntity(
              callId: 'call-active-1',
              tripStopId: 'stop-1',
              protocolVersion: 2,
              sequence: 2,
              status: VoiceCallStatus.active,
            ),
          ),
        );
        await tester.pumpWidget(buildSubject(viewModel: vm));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.call_end_rounded));
        await tester.pumpAndSettle();
        expect(repo.endCallCount, 1);
      },
    );
  });
}
