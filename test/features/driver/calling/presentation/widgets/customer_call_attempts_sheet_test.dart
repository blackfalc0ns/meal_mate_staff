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
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/call_attempt_actions.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/call_attempt_indicator.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/call_failed_recovery_options.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/customer_call_info_card.dart';

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
  for (final count in [0, 2, 3]) {
    testWidgets('server count $count does not unlock recovery locally', (
      tester,
    ) async {
      final vm = _createViewModel(_FakeCallingRepo());
      addTearDown(vm.close);
      vm.emit(
        vm.state.copyWith(
          contactCase: DeliveryContactCaseEntity(
            contactCaseId: 'case-1',
            tripStopId: 'stop-1',
            status: 'Open',
            attemptCount: count,
          ),
          eligibility: const VoiceCallEligibilityEntity(
            reasonCode: 'contact.eligible',
            canInitiate: true,
          ),
        ),
      );
      await tester.pumpWidget(
        _buildTestWidget(
          viewModel: vm,
          attempt: const DriverCallAttemptEntity(
            customerName: 'Customer',
            customerPhone: '+965 12345678',
            attemptNumber: 3,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CustomerCallInfoCard>(find.byType(CustomerCallInfoCard))
            .isPhoneUnlocked,
        isFalse,
      );
      expect(find.byType(CallFailedRecoveryOptions), findsNothing);
      expect(find.byType(CallAttemptActions), findsOneWidget);
      expect(
        tester
            .widget<CallAttemptIndicator>(find.byType(CallAttemptIndicator))
            .currentAttempt,
        count,
      );
      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(CustomerCallAttemptsSheet)),
          )!.driverCallUnreachableTitle,
        ),
        findsNothing,
      );
      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(CustomerCallAttemptsSheet)),
          )!.driverCallUnreachableSubtitle,
        ),
        findsNothing,
      );
    });
  }

  for (final permissions in [(true, false), (false, true), (true, true)]) {
    testWidgets(
      'server permissions $permissions control each recovery action',
      (tester) async {
        final vm = _createViewModel(_FakeCallingRepo());
        addTearDown(vm.close);
        vm.emit(
          vm.state.copyWith(
            contactCase: DeliveryContactCaseEntity(
              contactCaseId: 'case-1',
              tripStopId: 'stop-1',
              status: 'Open',
              attemptCount: 1,
              canRevealPhone: permissions.$1,
              canHold: permissions.$2,
            ),
            eligibility: const VoiceCallEligibilityEntity(
              reasonCode: 'contact.eligible',
              canInitiate: false,
            ),
          ),
        );
        var directCalls = 0;
        var reports = 0;
        await tester.pumpWidget(
          _buildTestWidget(
            viewModel: vm,
            onDirectCall: () => directCalls++,
            onReportUnreachable: () => reports++,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<CustomerCallInfoCard>(find.byType(CustomerCallInfoCard))
              .isPhoneUnlocked,
          permissions.$1,
        );
        expect(
          find.text(
            AppLocalizations.of(
              tester.element(find.byType(CustomerCallAttemptsSheet)),
            )!.driverCallExternalButton,
          ),
          permissions.$1 ? findsOneWidget : findsNothing,
        );
        expect(
          find.text(
            AppLocalizations.of(
              tester.element(find.byType(CustomerCallAttemptsSheet)),
            )!.driverCallReportUnreachableButton,
          ),
          permissions.$2 ? findsOneWidget : findsNothing,
        );
        if (permissions.$1) {
          await tester.tap(
            find.text(
              AppLocalizations.of(
                tester.element(find.byType(CustomerCallAttemptsSheet)),
              )!.driverCallExternalButton,
            ),
          );
        }
        if (permissions.$2) {
          await tester.tap(
            find.text(
              AppLocalizations.of(
                tester.element(find.byType(CustomerCallAttemptsSheet)),
              )!.driverCallReportUnreachableButton,
            ),
          );
        }
        expect(directCalls, permissions.$1 ? 1 : 0);
        expect(reports, permissions.$2 ? 1 : 0);
        expect(
          find.text(
            AppLocalizations.of(
              tester.element(find.byType(CustomerCallAttemptsSheet)),
            )!.driverCallUnreachableSubtitle,
          ),
          findsNothing,
        );
      },
    );
  }

  testWidgets('case false overrides earlier eligibility true', (tester) async {
    final vm = _createViewModel(_FakeCallingRepo());
    addTearDown(vm.close);
    vm.emit(
      vm.state.copyWith(
        contactCase: const DeliveryContactCaseEntity(
          contactCaseId: 'case-1',
          tripStopId: 'stop-1',
          status: 'Open',
          attemptCount: 2,
        ),
        eligibility: const VoiceCallEligibilityEntity(
          reasonCode: 'contact.eligible',
          canInitiate: true,
          canHold: true,
          canRevealPhone: true,
        ),
      ),
    );
    await tester.pumpWidget(_buildTestWidget(viewModel: vm));
    await tester.pumpAndSettle();
    expect(find.byType(CallFailedRecoveryOptions), findsNothing);
    expect(
      tester
          .widget<CustomerCallInfoCard>(find.byType(CustomerCallInfoCard))
          .isPhoneUnlocked,
      isFalse,
    );
  });

  testWidgets('call starts only with server eligibility', (tester) async {
    final vm = _createViewModel(_FakeCallingRepo());
    addTearDown(vm.close);
    var started = false;
    await tester.pumpWidget(
      _buildTestWidget(viewModel: vm, onStartCall: () => started = true),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CallAttemptActions>(find.byType(CallAttemptActions))
          .onCallNowPressed,
      isNull,
    );
    vm.emit(
      vm.state.copyWith(
        eligibility: const VoiceCallEligibilityEntity(
          reasonCode: 'contact.eligible',
          canInitiate: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(
        AppLocalizations.of(
          tester.element(find.byType(CustomerCallAttemptsSheet)),
        )!.driverCallNow,
      ),
    );
    expect(started, isTrue);
  });
}
