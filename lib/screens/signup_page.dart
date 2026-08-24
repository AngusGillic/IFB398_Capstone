import 'package:flutter/cupertino.dart';
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

  @override
  void initState() {
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    confirmController.addListener(() => setState(() {}));
    super.initState();
  }

  /// Validates if the email matches a basic email pattern.
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validates password strength: at least 8 characters, with uppercase, lowercase, digit, and special character.
  bool isValidPassword(String password) {
    return charLength && includeNum && includeUpCse && includeLwCse && includeSpCh && pwdMatch;
  }

  void _onPasswordChanged(String password) {
    // safePrint("charLength = $charLength");
    setState(() {
      charLength = password.length >= 8 ;
      includeUpCse = RegExp(r'[A-Z]').hasMatch(password);
      includeLwCse = RegExp(r'[a-z]').hasMatch(password);
      includeNum = RegExp(r'\d').hasMatch(password);
      includeSpCh = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    });
    _onPasswordMatched();
  }

  void _onPasswordMatched() {
    // Current bug: confirm field is still green even if the first password field changed
    // Once matched, it stays green, unless the confirm password field changed
    final passwordCtrl = passwordController;
    final confirmCtrl = confirmController;
    
    safePrint("Password match: $pwdMatch");
    setState(() {
      pwdMatch = passwordCtrl.text.trim() == confirmCtrl.text.trim()
        && passwordCtrl.text.trim().isNotEmpty
        && confirmCtrl.text.trim().isNotEmpty;
    });
  }

  Future<void> _register(BuildContext context) async {
    safePrint("Form is validated, function _register is running");
  }

  
 void _showDialogError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context, 
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Sign Up Failed"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("Okay"),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      )
    );
 }

  bool isFormValidated(String email, String password, BuildContext context){
    if (isValidEmail(email) && (isValidPassword(password))) {
      return true;
    }

    // if (!isValidEmail(email)) {
    //   _showDialogError(context, "Please enter a valid email address");
    // }

    // if (!isValidPassword(password)) {
    //   _showDialogError(context, "Password must meet the criteria below");
    // }

    if (email.isEmpty || password.isEmpty) {
      _showDialogError(context, "Please enter all fields");
    } else if (!isValidEmail(email)) {
      _showDialogError(context, "Please enter a valid email address");
    } else if (!isValidEmail(password)) {
      _showDialogError(context, "Password must meet the criteria below");
    }

    return false;
  }


  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
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
                IosField(icon: Icons.lock, label: 'Confirm Password', value: '', controller: confirmController, obscure: true, trailing: Icons.visibility,),
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
                  isFormValidated(
                    emailController.text.trim(), 
                    passwordController.text.trim(), 
                    context
                  ) ? _register(context) : (){}
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
  // bool condition for dynamic input field tracking
  final bool condition;
  
  const _Rule({
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
