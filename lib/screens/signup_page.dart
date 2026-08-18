import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'login_page.dart';
import 'verify_email_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        children: [
          const SizedBox(height: 72),
          const Text('Create account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const Text("Let's get started", style: TextStyle(fontSize: 14, color: AppColors.greyText)),
          const SizedBox(height: 32),
          const IosField(icon: Icons.person, label: 'Full name', value: 'John Doe'),
          const IosField(icon: Icons.mail, label: 'Email', value: 'JohnDoe@email.com'),
          const IosField(icon: Icons.password, label: 'Password', value: 'password', obscure: true, trailing: Icons.visibility),
          const _Rule('At least 6 characters'),
          const _Rule('Includes Number'),
          const _Rule('Includes uppercase letter'),
          const Spacer(),
          GreenButton(text: 'Sign up', onTap: () => _open(context, const VerifyEmailPage())),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _open(context, const LoginPage()),
            child: const Text.rich(
              TextSpan(text: 'Already have an account? ', children: [TextSpan(text: 'Log in', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900))]),
              style: TextStyle(fontSize: 11),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String text;
  const _Rule(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 16, color: AppColors.green),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
