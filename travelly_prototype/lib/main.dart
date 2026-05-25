import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'theme/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
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
      home: const WelcomePage(),
    );
  }
}
