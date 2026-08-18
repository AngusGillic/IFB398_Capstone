import 'package:flutter/services.dart';

import '../models/gtfs_route.dart';

class GtfsService {
  Future<List<GtfsRoute>> loadRoutes() async {
    final String data = await rootBundle.loadString(
      'assets/gtfs/routes.txt',
    );

    final List<String> lines = data.split('\n');

    if (lines.isEmpty) {
      return [];
    }

    final headers = lines.first.split(',');

    final routeIdIndex = headers.indexOf('route_id');
    final agencyIdIndex = headers.indexOf('agency_id');
    final shortNameIndex = headers.indexOf('route_short_name');
    final longNameIndex = headers.indexOf('route_long_name');
    final routeTypeIndex = headers.indexOf('route_type');

    final List<GtfsRoute> routes = [];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) continue;

      final columns = line.split(',');

      if (columns.length <= routeTypeIndex) continue;

      final routeType = columns[routeTypeIndex].replaceAll('"', '').trim();

      if (routeType != '3') continue;

      routes.add(
        GtfsRoute(
          routeId: columns[routeIdIndex].replaceAll('"', '').trim(),
          agencyId: agencyIdIndex >= 0
              ? columns[agencyIdIndex].replaceAll('"', '').trim()
              : '',
          routeShortName:
              columns[shortNameIndex].replaceAll('"', '').trim(),
          routeLongName:
              columns[longNameIndex].replaceAll('"', '').trim(),
          routeType: routeType,
        ),
      );
    }

    return routes;
  }
}
