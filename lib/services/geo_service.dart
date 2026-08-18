import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' show LatLng;

import 'maps_config.dart';

class Place {
  const Place({required this.name, required this.detail, required this.point});

  final String name;
  final String detail;
  final LatLng point;
}

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMetres,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMetres;
  final double durationSeconds;

  Duration get duration => Duration(seconds: durationSeconds.round());

  double get distanceKm => distanceMetres / 1000;
}

class GeoService {
  const GeoService._();

  static const Map<String, String> _headers = {
    'User-Agent': MapsConfig.userAgent,
    'Accept': 'application/json',
  };

  /// Free-text place search.
  static Future<List<Place>> search(String query) async {
    if (query.trim().length < 3) return const [];

    final uri = Uri.parse(MapsConfig.nominatimSearch).replace(queryParameters: {
      'q': query,
      'format': 'jsonv2',
      'limit': '6',
      'countrycodes': MapsConfig.countryCodes,
      'addressdetails': '0',
    });

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) return const [];

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((raw) {
      final item = raw as Map<String, dynamic>;
      final display = (item['display_name'] as String?) ?? '';
      final parts = display.split(',');
      return Place(
        name: parts.isEmpty ? display : parts.first.trim(),
        detail: parts.length > 1 ? parts.sublist(1).take(2).join(',').trim() : '',
        point: LatLng(
          double.parse(item['lat'] as String),
          double.parse(item['lon'] as String),
        ),
      );
    }).toList();
  }

  /// Road geometry between two points.
  ///
  /// OSRM's demo server only serves the driving profile, so other modes reuse
  /// this geometry and get their duration from [estimateFor].
  static Future<RouteResult?> route(LatLng from, LatLng to) async {
    final coords = '${from.longitude},${from.latitude};'
        '${to.longitude},${to.latitude}';

    final uri = Uri.parse('${MapsConfig.osrmRoute}/driving/$coords').replace(
      queryParameters: {'overview': 'full', 'geometries': 'geojson'},
    );

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) return null;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = body['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return null;

    final first = routes.first as Map<String, dynamic>;
    final geometry = first['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    return RouteResult(
      points: coordinates
          .map((c) => LatLng((c as List)[1] as double, c[0] as double))
          .toList(),
      distanceMetres: (first['distance'] as num).toDouble(),
      durationSeconds: (first['duration'] as num).toDouble(),
    );
  }

  /// Door-to-door speeds in km/h.
  static const Map<String, double> speedsKmh = {
    'walk': 4.8,
    'cycle': 15.5,
    'transit': 22.0,
    'drive': 34.0,
  };

  /// Grams of CO2 per kilometre.
  static const Map<String, double> emissionsPerKm = {
    'walk': 0,
    'cycle': 0,
    'transit': 41,
    'drive': 170,
  };

  static Duration estimateFor(String mode, double distanceKm, RouteResult base) {
    if (mode == 'drive') return base.duration;
    final speed = speedsKmh[mode] ?? 20;
    return Duration(seconds: (distanceKm / speed * 3600).round());
  }

  /// CO2 avoided versus driving the same distance.
  static double savingKg(String mode, double distanceKm) {
    final drive = emissionsPerKm['drive']!;
    final chosen = emissionsPerKm[mode] ?? drive;
    return ((drive - chosen) * distanceKm) / 1000;
  }
}
