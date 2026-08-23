import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'login_page.dart';
import 'verify_email_page.dart';

// Deepak's packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../services/username_mapper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override 
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register(BuildContext context) async {
    final username = UsernameMapper.emailToUsername(emailController.text);

    try {
      final result = await Amplify.Auth.signUp(
        username: username,
        password: passwordController.text,
        options: SignUpOptions(
          userAttributes: {
            CognitoUserAttributeKey.email: emailController.text.trim(),
          },
        ),
      );

      if (result.isSignUpComplete) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful. Please login.')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          // Navigator.push(
          //   context,
          //   adaptivePageRoute(
          //     builder: (_) => ConfirmationScreen(
          //       username: username,
          //       email: emailCtrl.text.trim(),
          //     ),
          //   ),
          // );
        }
      }
    } on AuthException catch (e) {
      // setState(() => signupError = e.message);
    } finally {
      // setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const SizedBox(height: 72),
                const Text('Create account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const Text("Let's get started", style: TextStyle(fontSize: 14, color: AppColors.greyText)),
                const SizedBox(height: 32),
                IosField(icon: Icons.person, label: 'Full name', value: '', controller: nameController),
                IosField(icon: Icons.mail, label: 'Email', value: '', controller: emailController,),
                IosField(icon: Icons.password, label: 'Password', value: '', controller: passwordController, obscure: true, trailing: Icons.visibility),
                const _Rule('At least 6 characters'),
                const _Rule('Includes Number'),
                const _Rule('Includes uppercase letter'),
                const Spacer(),
                GreenButton(text: 'Sign up', onTap: () => 
                  // _open(context, const VerifyEmailPage())
                  _register(context)
                ),
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
          ),
        ]
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
