/// Map, search and routing endpoints.
///
/// The defaults are free community services that need no API key, which is
/// what the app uses during development:
///
///   Tiles     OpenStreetMap
///   Search    Nominatim
///   Routing   OSRM demo server
///
/// These are volunteer-run and their usage policies do not permit production
/// traffic. Before release, switch [tileUrl] to a provider with a free tier
/// such as MapTiler or Stadia Maps, and either self-host OSRM or move to a
/// commercial directions API.
///
/// To use Google Maps instead:
///   1. flutter pub add google_maps_flutter
///   2. Supply the key with --dart-define=MAPS_API_KEY=...
///      or in android/app/src/main/AndroidManifest.xml:
///        <meta-data android:name="com.google.android.geo.API_KEY"
///                   android:value="YOUR_KEY"/>
///      and ios/Runner/AppDelegate.swift:
///        GMSServices.provideAPIKey("YOUR_KEY")
///   3. Replace the FlutterMap in map_page.dart with GoogleMap.
class MapsConfig {
  const MapsConfig._();

  static const String tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const String attribution = '© OpenStreetMap contributors';

  /// Sent with every tile and API request. The OSM and Nominatim policies both
  /// require a real identifier; requests without one get blocked.
  static const String userAgent = 'au.edu.qut.travelly';

  static const String nominatimSearch =
      'https://nominatim.openstreetmap.org/search';

  static const String osrmRoute =
      'https://router.project-osrm.org/route/v1';

  /// Restricts place search to Australia.
  static const String countryCodes = 'au';

  static const double defaultLat = -27.4698;
  static const double defaultLng = 153.0251;
  static const double defaultZoom = 13;

  static const String googleApiKey =
      String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

  static bool get usingGoogle => googleApiKey.isNotEmpty;
}
