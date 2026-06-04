import 'package:flutter/material.dart';
import '../models/gtfs_route.dart';
import '../services/gtfs_service.dart';

class BusRoutesScreen extends StatefulWidget {
  const BusRoutesScreen({super.key});

  @override
  State<BusRoutesScreen> createState() => _BusRoutesScreenState();
}

class _BusRoutesScreenState extends State<BusRoutesScreen> {
  final GtfsService _gtfsService = GtfsService();

  late Future<List<GtfsRoute>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _routesFuture = _gtfsService.loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translink Bus Routes'),
      ),
      body: FutureBuilder<List<GtfsRoute>>(
        future: _routesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading routes: ${snapshot.error}'),
            );
          }

          final routes = snapshot.data ?? [];

          if (routes.isEmpty) {
            return const Center(
              child: Text('No routes found.'),
            );
          }

          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];

              final shortName =
                  route.routeShortName.replaceAll('"', '').trim();

              final longName =
                  route.routeLongName.replaceAll('"', '').trim();

              final displayText =
                  shortName.length > 4 ? 'Bus' : shortName;

              final titleText =
                  shortName.length > 4
                      ? longName
                      : 'Route $shortName';

              final subtitleText =
                  shortName.length > 4
                      ? 'Translink bus route'
                      : longName;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  title: Text(
                    titleText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(subtitleText),
                ),
              );
            },
          );
        },
      ),
    );
  }
}