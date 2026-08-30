import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';

void main() {
  test(
    'loads Arabic auth and registration translations from core l10n',
    () async {
      final localizations = await AppLocalizations.delegate.load(
        const Locale('ar'),
      );

      expect(localizations.welcomeBack, 'مرحبا بعودتك!');
      expect(localizations.registrationPersonalData, 'البيانات الشخصية');
      expect(localizations.registrationVehicleData, 'بيانات المركبة');
      expect(localizations.registrationDocuments, 'المستندات');
      expect(localizations.registrationReviewOrder, 'مراجعة الطلب');
      expect(localizations.registrationChooseAccountType, 'اختر نوع الحساب');
      expect(localizations.registrationDriverRole, 'سائق');
      expect(localizations.registrationOpsRole, 'مندوب عمليات');
      expect(localizations.registrationConfirm, 'تأكيد');
      expect(localizations.registrationDefaultRole, 'افتراضي');
    },
  );
}
