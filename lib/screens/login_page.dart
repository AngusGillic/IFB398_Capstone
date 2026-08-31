import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'home_page.dart';
import 'signup_page.dart';

// Deepak's packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../services/username_mapper.dart';
import '../core/user_data_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loadingAnimation = false;

  void _replace(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Performs login using Amplify Auth.
  ///
  /// Maps email to username, signs in, and navigates to HomeScreen on success.
  /// Shows error dialog on failure.
  Future<void> _login(BuildContext context) async {
    setState(() {
      loadingAnimation = true;
    });

    try {
      final username = UsernameMapper.emailToUsername(emailController.text);
      final result = await Amplify.Auth.signIn(
        username: username,
        password: passwordController.text,
      );
      if (result.isSignedIn) {
        // (?)Isolate local data (groups, points, trips filter) to this Cognito sub.
        await UserDataSession.onAuthenticated();
        if (!mounted) return;
        _replace(context, const HomePage());
      }
    } on AuthException catch (e) {
      safePrint('Error: ${e.toString()}');
      final message = e.message;
      _showDialogError(context, message);
    } finally {
      setState(() {
        loadingAnimation = false;
      });
    }
  }

  /// Displays an error dialog with the given message.
  void _showDialogError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Login Failed"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("Okay"),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      loading: loadingAnimation,
      // Added CustomScrollView + SliverFillRemaining to fix the renderflex overflow issue
      // Originally added SingleChildScrollView() but Spacer() is not compatible with it
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const SizedBox(height: 72),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Login to continue your sustainable\njourney!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.greyText),
                ),
                const SizedBox(height: 42),
                IosField(
                  icon: Icons.mail,
                  label: 'Email',
                  value: '',
                  controller: emailController,
                ),
                IosField(
                  icon: Icons.password,
                  label: 'Password',
                  value: '',
                  controller: passwordController,
                  obscure: true,
                  trailing: Icons.visibility,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: AppColors.green, fontSize: 11),
                    ),
                  ),
                ),
                GreenButton(
                  text: 'Log In',
                  // onTap: () => _replace(
                  //   context, const HomePage()
                  // )
                  onTap: () => {
                    _login(context),
                    FocusManager.instance.primaryFocus?.unfocus()
                  },
                ),
                const SizedBox(height: 30),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.greyText,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
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
                  onTap: () => _open(context, SignUpPage()),
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
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
    return CircleAvatar(
      radius: 27,
      backgroundColor: Colors.grey.shade200,
      child: icon != null
          ? Icon(icon, color: Colors.black, size: 30)
          : Text(
              label!,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.blue,
              ),
            ),
    );
  }
}
