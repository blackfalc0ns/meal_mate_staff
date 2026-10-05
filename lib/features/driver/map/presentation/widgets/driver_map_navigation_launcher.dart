import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/driver_map_navigation_entity.dart';

typedef UrlOpener = Future<bool> Function(Uri uri);

class DriverMapNavigationLauncher {
  DriverMapNavigationLauncher({
    UrlOpener? urlOpener,
  }) : _urlOpener = urlOpener ?? _defaultUrlOpener;

  final UrlOpener _urlOpener;

  static Future<bool> _defaultUrlOpener(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> launchNavigation({
    required DriverMapNavigationEntity? navigation,
    required String? selectedStopId,
  }) async {
    if (navigation == null || !navigation.canNavigate) return false;
    final url = navigation.googleMapsUrl?.trim();
    if (url == null || url.isEmpty) return false;

    // Must match the currently selected stop ID
    if (selectedStopId != null &&
        navigation.destinationStopId != null &&
        selectedStopId != navigation.destinationStopId) {
      return false;
    }

    try {
      final uri = Uri.parse(url);
      return await _urlOpener(uri);
    } catch (_) {
      return false;
    }
  }
}
