import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations, Material, MaterialType;
import 'package:flutter/services.dart';

import 'screens/bus_routes_screen.dart';
import 'screens/welcome_page.dart';
import 'ui/app_theme.dart';
import 'ui/glass.dart';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'widgets/amplifyconfiguration.dart';


const String kStartScreen = String.fromEnvironment('START');

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _configureAmplify();
  } on AmplifyException catch (e) {
    safePrint("Error configuring Amplify: ${e.message}");
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    systemNavigationBarColor: Color(0x00000000),
    systemNavigationBarDividerColor: Color(0x00000000),
  ));

  runApp(const TravellyApp());
}


Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class TravellyApp extends StatelessWidget {
  const TravellyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, mode, _) => _app(ThemeController.instance.brightness),
    );
  }

  Widget _app(Brightness? brightness) {
    return CupertinoApp(
      title: 'Travelly',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: LGColor.accent,
        scaffoldBackgroundColor: LGColor.canvas,
        barBackgroundColor: LGColor.glassTint,
        applyThemeToAll: true,
        textTheme: const CupertinoTextThemeData(
          primaryColor: LGColor.accent,
          textStyle: TextStyle(
            fontSize: 17,
            letterSpacing: -0.41,
            color: LGColor.label,
          ),
        ),
      ),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      builder: (context, child) => Material(
        type: MaterialType.transparency,
        child: child ?? const SizedBox.shrink(),
      ),
      home: kStartScreen == 'bus' ? const BusRoutesScreen() : const WelcomePage(),
    );
  }
}
