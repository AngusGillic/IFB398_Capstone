import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _replace(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        children: [
          const SizedBox(height: 72),
          const Text('Welcome Back!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('login to continue your sustainable\njourney!', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.greyText)),
          const SizedBox(height: 42),
          const IosField(icon: Icons.mail, label: 'Email', value: 'JohnDoe@email.com'),
          const IosField(icon: Icons.password, label: 'Password', value: 'password', obscure: true, trailing: Icons.visibility),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot password?', style: TextStyle(color: AppColors.green, fontSize: 11)))),
          GreenButton(text: 'Log In', onTap: () => _replace(context, const HomePage())),
          const SizedBox(height: 30),
          const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('or continue with', style: TextStyle(fontSize: 10, color: AppColors.greyText))), Expanded(child: Divider())]),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Social(label: 'G'),
              SizedBox(width: 14),
              _Social(icon: Icons.apple),
              SizedBox(width: 14),
              _Social(icon: Icons.face),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _open(context, const SignUpPage()),
            child: const Text.rich(
              TextSpan(text: "Don't have an account? ", children: [TextSpan(text: 'Sign up', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900))]),
              style: TextStyle(fontSize: 11),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _Social extends StatelessWidget {
  final IconData? icon;
  final String? label;
  const _Social({this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    // PLACEHOLDER_ASSET: replace with real Google/Apple/social SVGs later.
    return CircleAvatar(
      radius: 27,
      backgroundColor: Colors.grey.shade200,
      child: icon != null ? Icon(icon, color: Colors.black, size: 30) : Text(label!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.blue)),
    );
  }
}
