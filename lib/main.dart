import 'package:flutter/material.dart';

import 'config/routing/app_routes.dart';
import 'config/routing/routing_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/l10n/translations/app_localizations.dart';
import 'core/services/app_locale_notifier.dart';
import 'core/di/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp(initialRoute: AppRoutes.splash));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute = AppRoutes.splash});

  final String initialRoute;

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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          builder: (context, child) {
            return child ?? const SizedBox();
          },
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute:AppRoutes.appShell,
          // AppRoutes.splash,
          //initialRoute,
          onGenerateRoute: RouteGenerator.getRoute,
        );
      },
    );
  }
}
