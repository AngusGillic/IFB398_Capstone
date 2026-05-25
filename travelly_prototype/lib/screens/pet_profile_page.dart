import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';

class PetProfilePage extends StatelessWidget {
  const PetProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 4,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(2, 50, 2, 100),
        children: const [
          Center(child: PlaceholderPet(size: 120)),
          SizedBox(height: 8),
          Text('Puppy ✎', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: Colors.grey, fontWeight: FontWeight.w900)),
          Text('3 months • Dingo • 5 kg', textAlign: TextAlign.center),
          SizedBox(height: 14),
          GreyPanel(child: Text('Level 2\n━━━━━━━━━━━━━━━━', style: TextStyle(fontWeight: FontWeight.w900))),
          GreyPanel(child: Text('About Puppy\n\nPuppy is a puppy that likes other puppies')),
          Text('Stats', style: TextStyle(fontWeight: FontWeight.w900)),
          Row(children: [Expanded(child: GreyPanel(child: Text('Happiness'))), SizedBox(width: 8), Expanded(child: GreyPanel(child: Text('Health'))), SizedBox(width: 8), Expanded(child: GreyPanel(child: Text('Energy')))]),
        ],
      ),
    );
  }
}
