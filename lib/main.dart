import 'package:flutter/material.dart';
//import 'screens/welcome_page.dart';
import 'theme/app_colors.dart';
import 'screens/bus_routes_screen.dart';

void main() {
  runApp(const TravellyApp());
}

class TravellyApp extends StatelessWidget {
  const TravellyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: AppColors.screen,
        useMaterial3: true,
      ),
      home: const BusRoutesScreen(), // change back to WelcomePage() after testing
    );
  }
}
