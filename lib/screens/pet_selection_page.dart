import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';
import 'pet_home_page.dart';

class PetSelectionPage extends StatelessWidget {
  const PetSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 4,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 285,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF1F1F), Colors.white]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Puppy', style: TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                PlaceholderPet(size: 125),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 58,
            color: Colors.black87,
            alignment: Alignment.center,
            child: const Text('Choose your pet!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: PageView(
              controller: PageController(viewportFraction: 0.58),
              children: const [
                _PetCard(name: 'Koala', color: Colors.green),
                _PetCard(name: 'Frillie', color: Colors.lightBlue),
                _PetCard(name: 'Kanga', color: Colors.orange),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 92),
            child: GreenButton(text: 'SELECT', onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PetHomePage()))),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final String name;
  final Color color;

  const _PetCard({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PlaceholderPet(size: 85),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
