import 'package:url_launcher/url_launcher.dart' as ul;
import 'package:url_launcher/url_launcher.dart' show LaunchMode;

typedef CanLaunchUrlFn = Future<bool> Function(Uri uri);
typedef LaunchUrlFn = Future<bool> Function(Uri uri, {LaunchMode mode});

abstract interface class DriverContactLauncher {
  Uri? phoneUri(String? phone);
  Uri? smsUri(String? phone);
  Uri? whatsAppUri(String? phone);

  Future<bool> launchPhone(String? phone);
  Future<bool> launchSms(String? phone);
  Future<bool> launchWhatsApp(String? phone);
}

class DriverContactLauncherImpl implements DriverContactLauncher {
  const DriverContactLauncherImpl({
    CanLaunchUrlFn? canLaunchFn,
    LaunchUrlFn? launchFn,
  }) : _canLaunchFn = canLaunchFn ?? ul.canLaunchUrl,
       _launchFn = launchFn ?? ul.launchUrl;

  final CanLaunchUrlFn _canLaunchFn;
  final LaunchUrlFn _launchFn;

  @override
  Uri? phoneUri(String? phone) {
    final cleaned = _cleanPhone(phone);
    if (cleaned == null) return null;
    return Uri(scheme: 'tel', path: cleaned);
  }

  @override
  Uri? smsUri(String? phone) {
    final cleaned = _cleanPhone(phone);
    if (cleaned == null) return null;
    return Uri(scheme: 'sms', path: cleaned);
  }

  @override
  Uri? whatsAppUri(String? phone) {
    if (phone == null) return null;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return Uri.parse('https://wa.me/$digits');
  }

  @override
  Future<bool> launchPhone(String? phone) async {
    final uri = phoneUri(phone);
    if (uri == null) return false;
    return _safeLaunch(uri);
  }

  @override
  Future<bool> launchSms(String? phone) async {
    final uri = smsUri(phone);
    if (uri == null) return false;
    return _safeLaunch(uri);
  }

  @override
  Future<bool> launchWhatsApp(String? phone) async {
    final uri = whatsAppUri(phone);
    if (uri == null) return false;
    return _safeLaunch(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> _safeLaunch(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      final can = await _canLaunchFn(uri);
      if (!can) return false;
      return await _launchFn(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }

  static String? _cleanPhone(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final hasLeadingPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return hasLeadingPlus ? '+$digits' : digits;
  }
}
