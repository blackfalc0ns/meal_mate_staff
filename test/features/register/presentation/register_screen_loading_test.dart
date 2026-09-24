import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/custom_progress_indecator.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_state.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_view_model.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_screen.dart';
import 'package:meal_mate_delivery/features/register/presentation/widgets/register_personal_data_shimmer.dart';
import 'package:meal_mate_delivery/features/register/presentation/widgets/register_submission_shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_event.dart';

class FakeDriverRegistrationViewModel extends Cubit<DriverRegistrationState>
    implements DriverRegistrationViewModel {
  FakeDriverRegistrationViewModel(super.initialState);

  @override
  void doIntent(DriverRegistrationEvent event) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app({required DriverRegistrationViewModel viewModel}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme,
    home: RegisterScreen(viewModel: viewModel),
  );
}

void main() {
  testWidgets(
    'renders RegisterPersonalDataShimmer and no progress indicators when catalogs loading',
    (tester) async {
      final fakeViewModel = FakeDriverRegistrationViewModel(
        const DriverRegistrationState(
          currentStep: 1,
          isLoadingRestaurants: true,
        ),
      );

      await tester.pumpWidget(_app(viewModel: fakeViewModel));
      await tester.pump();

      expect(find.byType(RegisterPersonalDataShimmer), findsOneWidget);
      expect(find.byType(ShimmerWidget), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'renders RegisterSubmissionShimmer with non-dismissible ModalBarrier and no spinners on submit',
    (tester) async {
      final fakeViewModel = FakeDriverRegistrationViewModel(
        const DriverRegistrationState(
          currentStep: 1,
          status: DriverRegistrationStatus.submitting,
        ),
      );

      await tester.pumpWidget(_app(viewModel: fakeViewModel));
      await tester.pump();

      expect(find.byType(RegisterSubmissionShimmer), findsOneWidget);
      final barrierFinder = find.descendant(
        of: find.byType(Stack),
        matching: find.byType(ModalBarrier),
      );
      expect(barrierFinder, findsOneWidget);
      final barrier = tester.widget<ModalBarrier>(barrierFinder);
      expect(barrier.dismissible, isFalse);
      expect(find.byType(CustomProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );
}
