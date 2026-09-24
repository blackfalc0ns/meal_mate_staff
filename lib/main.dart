import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config/routing/app_routes.dart';
import 'config/routing/routing_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/di/di.dart';
import 'core/l10n/translations/app_localizations.dart';
import 'core/services/app_locale_notifier.dart';
import 'core/services/app_navigator_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/push_notification_coordinator.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  // OS handles notification payload display; no local notification needed here.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (_) {}
  }

  await configureDependencies();

  try {
    final coordinator = getIt<PushNotificationCoordinator>();
    await getIt<LocalNotificationService>().initialize(
      onNotificationTap: coordinator.handleLocalNotificationTap,
    );
    await coordinator.initialize();
  } catch (_) {}

  runApp(const MyApp(initialRoute: AppRoutes.splash));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute = AppRoutes.splash});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          navigatorKey: AppNavigatorService.navigatorKey,
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
          initialRoute: initialRoute,
          onGenerateRoute: RouteGenerator.getRoute,
        );
      },
    );
  }
}
