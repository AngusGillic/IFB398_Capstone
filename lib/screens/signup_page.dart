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
  // final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  // final formValidated = false;

  bool charLength = false;
  bool includeNum = false;
  bool includeUpCse = false;
  bool includeLwCse = false;
  bool includeSpCh = false;
  bool pwdMatch = false;


  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override 
  void dispose() {
    // nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  /// Validates if the email matches a basic email pattern.
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validates password strength: at least 8 characters, with uppercase, lowercase, digit, and special character.
  bool isValidPassword(String password) {
    // if (password.length < 8) return false;
    // final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    // final hasLower = RegExp(r'[a-z]').hasMatch(password);
    // final hasDigit = RegExp(r'\d').hasMatch(password);
    // final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    // return hasUpper && hasLower && hasDigit && hasSpecial;
    return charLength && includeNum && includeUpCse && includeLwCse && includeSpCh && pwdMatch;
  }

  void _onPasswordChanged(String password) {
    safePrint("charLength = $charLength");
    setState(() {
      charLength = password.length >= 8 ;
      includeUpCse = RegExp(r'[A-Z]').hasMatch(password);
      includeLwCse = RegExp(r'[a-z]').hasMatch(password);
      includeNum = RegExp(r'\d').hasMatch(password);
      includeSpCh = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  void _onPasswordMatched(String password) {
    setState(() {
      pwdMatch = passwordController.text.contains(password);
    });
  }

  Future<void> _register(BuildContext context) async {
    safePrint("Form is validated, function _register is running");
  }

  bool isFormValidated(String email, String password) {
    if (isValidEmail(email) && (isValidPassword(password))) {
      return true;
    }
    return false;
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
                // IosField(icon: Icons.person, label: 'Full name', value: '', controller: nameController),
                IosField(icon: Icons.mail, label: 'Email', value: '', controller: emailController),
                IosField(icon: Icons.password, label: 'Password', value: '', controller: passwordController, obscure: true, trailing: Icons.visibility, onChanged: _onPasswordChanged,),
                IosField(icon: Icons.lock, label: 'Confirm Password', value: '', controller: confirmController, obscure: true, trailing: Icons.visibility, onChanged: _onPasswordMatched,),
                _Rule(text: 'At least 8 characters', condition: charLength,),
                _Rule(text: 'Includes number', condition: includeNum,),
                _Rule(text: 'Includes uppercase letter', condition: includeUpCse,),
                _Rule(text: 'Includes lowercase letter', condition: includeLwCse,),
                _Rule(text: 'Includes special characters', condition: includeSpCh,),
                _Rule(text: 'Password matching', condition: pwdMatch,),
                const Spacer(),
                GreenButton(
                  text: 'Sign up', 
                  onTap: () => 
                  // _open(context, const VerifyEmailPage())
                  isFormValidated(emailController.text.trim(), passwordController.text.trim()) ? _register(context) : (){}
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
  final bool condition;
  
  const _Rule({
    // super.key,
    required this.text,
    required this.condition
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
          Icon(Icons.check_circle_outline, size: 25, color: condition ? AppColors.green : AppColors.greyText),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        
      ],
    );
  }
}
