import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/register/domain/register_document.dart';
import 'package:meal_mate_delivery/features/register/presentation/widgets/register_document_upload_card.dart';

void main() {
  testWidgets(
    'places document icon on the right and preview on the left in RTL',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: RegisterDocumentUploadCard(
              document: const RegisterDocument(
                id: 'civil-card',
                imageAsset:
                    'assets/images/auth/registration_license_sample.png',
              ),
              title: 'البطاقة المدنية',
              subtitle: 'صورة واضحة للبطاقة المدنية السارية',
              onTap: () {},
            ),
          ),
        ),
      );

      final documentIconLeft = tester
          .getTopLeft(find.byIcon(Icons.description_outlined))
          .dx;
      final previewIconLeft = tester
          .getTopLeft(find.byIcon(Icons.cloud_upload_outlined))
          .dx;

      expect(documentIconLeft, greaterThan(previewIconLeft));
    },
  );
}
