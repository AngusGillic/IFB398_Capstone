import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';
import 'route_options_page.dart';
import 'trip_active_page.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 3,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Positioned.fill(child: PlaceholderMap()),
          Positioned(
            top: 70,
            left: 24,
            right: 24,
            child: GreyPanel(
              child: Row(children: [
                const Icon(Icons.search),
                const SizedBox(width: 10),
                const Expanded(child: Text('Quick Trip', style: TextStyle(fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RouteOptionsPage())), icon: const Icon(Icons.arrow_forward)),
              ]),
            ),
          ),
          Positioned(
            bottom: 98,
            left: 24,
            right: 24,
            child: GreyPanel(
              child: Row(children: [
                const CircleAvatar(child: Icon(Icons.location_on)),
                const SizedBox(width: 10),
                const Expanded(child: Text('Location\nStreet, City, State', style: TextStyle(fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripActivePage())), icon: const Icon(Icons.play_arrow)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
