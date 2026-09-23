import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/services/driver_contact_launcher.dart';

void main() {
  late DriverContactLauncherImpl launcher;
  Uri? launchedUri;
  LaunchMode? launchedMode;
  bool canLaunchResult = true;
  bool launchResult = true;

  setUp(() {
    launchedUri = null;
    launchedMode = null;
    canLaunchResult = true;
    launchResult = true;

    launcher = DriverContactLauncherImpl(
      canLaunchFn: (uri) async => canLaunchResult,
      launchFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
        launchedUri = uri;
        launchedMode = mode;
        return launchResult;
      },
    );
  });

  group('URI Formatting & Cleaning', () {
    test('phoneUri formats tel: with cleaned digits and leading plus', () {
      expect(
        launcher.phoneUri('+965 50 123 4567')?.toString(),
        'tel:+965501234567',
      );
      expect(launcher.phoneUri('965501234567')?.toString(), 'tel:965501234567');
      expect(
        launcher.phoneUri('  +965-50-123-4567  ')?.toString(),
        'tel:+965501234567',
      );
      expect(launcher.phoneUri(null), isNull);
      expect(launcher.phoneUri(''), isNull);
      expect(launcher.phoneUri('   '), isNull);
      expect(launcher.phoneUri('invalid-no-digits'), isNull);
    });

    test('smsUri formats sms: with cleaned digits', () {
      expect(
        launcher.smsUri('+965 50 123 4567')?.toString(),
        'sms:+965501234567',
      );
      expect(launcher.smsUri(null), isNull);
      expect(launcher.smsUri(''), isNull);
    });

    test(
      'whatsAppUri formats https://wa.me/ with digits only and NO leading plus',
      () {
        expect(
          launcher.whatsAppUri('+965 50 123 4567')?.toString(),
          'https://wa.me/965501234567',
        );
        expect(
          launcher.whatsAppUri('965501234567')?.toString(),
          'https://wa.me/965501234567',
        );
        expect(launcher.whatsAppUri(null), isNull);
        expect(launcher.whatsAppUri(''), isNull);
      },
    );
  });

  group('Launch Execution', () {
    test('launchPhone launches tel URI', () async {
      final success = await launcher.launchPhone('+965501234567');

      expect(success, isTrue);
      expect(launchedUri.toString(), 'tel:+965501234567');
    });

    test('launchSms launches sms URI', () async {
      final success = await launcher.launchSms('+965501234567');

      expect(success, isTrue);
      expect(launchedUri.toString(), 'sms:+965501234567');
    });

    test(
      'launchWhatsApp launches wa.me URI with externalApplication mode',
      () async {
        final success = await launcher.launchWhatsApp('+965 50 123 4567');

        expect(success, isTrue);
        expect(launchedUri.toString(), 'https://wa.me/965501234567');
        expect(launchedMode, LaunchMode.externalApplication);
      },
    );

    test(
      'returns false when phone is null or invalid without attempting launch',
      () async {
        final resultNull = await launcher.launchPhone(null);
        final resultEmpty = await launcher.launchSms('');
        final resultInvalid = await launcher.launchWhatsApp('no-digits');

        expect(resultNull, isFalse);
        expect(resultEmpty, isFalse);
        expect(resultInvalid, isFalse);
        expect(launchedUri, isNull);
      },
    );

    test('returns false when canLaunchUrl returns false', () async {
      canLaunchResult = false;
      final result = await launcher.launchPhone('+965501234567');

      expect(result, isFalse);
      expect(launchedUri, isNull);
    });

    test('returns false when launchUrl throws exception', () async {
      launcher = DriverContactLauncherImpl(
        canLaunchFn: (uri) async => true,
        launchFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          throw Exception('Platform launch failed');
        },
      );

      final result = await launcher.launchPhone('+965501234567');
      expect(result, isFalse);
    });
  });
}
