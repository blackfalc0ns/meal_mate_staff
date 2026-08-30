import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/routing/app_routes.dart';
import 'config/routing/routing_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/app_locale_notifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          builder: (context, child) {
            final localizations = AppLocalizations.of(context);

            return Directionality(
              textDirection: localizations.textDirection,
              child: child ?? const SizedBox.shrink(),
            );
          },
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: RouteGenerator.getRoute,
        );
      },
    );
  }
}
