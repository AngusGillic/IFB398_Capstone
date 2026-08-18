import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Positioned.fill(child: SoftCityBackground()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TravellyLogo(size: 76),
                const SizedBox(height: 14),
                const Text('travelly', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF39795B))),
                const Text('travel smart.\ntravel green.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF39795B), fontWeight: FontWeight.w700)),
                const SizedBox(height: 175),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 7, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      GreenButton(text: 'Create Account', onTap: () => _open(context, const SignUpPage())),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 46,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _open(context, const LoginPage()),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          ),
                          child: const Text('Login', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
