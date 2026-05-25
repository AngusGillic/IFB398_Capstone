import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'home_page.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        children: [
          const SizedBox(height: 72),
          const Text('Verify Your Email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('Enter the 6-digit code sent to', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
          const Text('JohnDoe@email.com', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 38),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (_) => const _CodeBox())),
          const SizedBox(height: 24),
          const Text('Resend Code in 26 seconds', style: TextStyle(fontSize: 11, color: AppColors.greyText)),
          const Spacer(),
          GreenButton(
            text: 'Verify',
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage())),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 5, offset: const Offset(0, 3))],
      ),
    );
  }
}
