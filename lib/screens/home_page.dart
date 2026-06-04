import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';
import 'impact_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 2,
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 72, 24, 105),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Morning, John 👋', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, height: 1)),
                    SizedBox(height: 5),
                    Text('Lets get green!', style: TextStyle(fontSize: 13, color: AppColors.text)),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey.shade400,
                child: const Icon(Icons.notifications, size: 17, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => _open(context, const ImpactPage()),
            child: GreyPanel(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.fromLTRB(13, 9, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Impact this week', style: TextStyle(fontSize: 13)),
                  Container(height: 1, color: AppColors.green, margin: const EdgeInsets.only(top: 4, bottom: 10)),
                  Row(
                    children: const [
                      Expanded(child: _ImpactMetric(label: 'CO2 saved', value: '2.8kg')),
                      Expanded(child: _ImpactMetric(label: 'Trips', value: '10')),
                      MiniGraph(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 34),
          GreyPanel(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(13, 9, 13, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Suggested', style: TextStyle(fontSize: 14)),
                const Divider(height: 14, color: Colors.grey),
                ...List.generate(4, (index) => const _SuggestedRow()),
              ],
            ),
          ),
          const SizedBox(height: 34),
          MintPanel(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Challenge Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                const Divider(height: 28, color: Colors.grey),
                const Text('Green Week Walk Challenge! 🌍', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 13),
                const Row(
                  children: [
                    Expanded(child: Text('4/7 Days completed', style: TextStyle(fontSize: 11))),
                    Text('2000/4000 Steps', style: TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 28),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const LinearProgressIndicator(
                    value: 0.57,
                    minHeight: 17,
                    color: Color(0xFF71BDAE),
                    backgroundColor: Colors.white,
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

class _ImpactMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ImpactMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _SuggestedRow extends StatelessWidget {
  const _SuggestedRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: Colors.grey.shade400, child: const Icon(Icons.work, color: Colors.white, size: 17)),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Work', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, height: 1)),
                Text('22min • Bus 150', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, height: 1.2)),
                Text('Leave by 8:18am', style: TextStyle(fontSize: 8, color: AppColors.greyText, height: 1.2)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('0.8kg CO2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
              Text('Arrive by 8:30am', style: TextStyle(fontSize: 8, color: AppColors.greyText)),
            ],
          ),
        ],
      ),
    );
  }
}
