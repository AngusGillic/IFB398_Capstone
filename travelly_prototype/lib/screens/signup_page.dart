import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'login_page.dart';
import 'verify_email_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUpPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  SignUpPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _signUp(BuildContext context) async {
      Db? db;

      try {
      final dbUser = dotenv.get('MONGODB_USER').trim();
      final dbPassword = dotenv.get('MONGODB_PASSWORD').trim();
      final rawCluster = dotenv.get('MONGODB_CLUSTER').trim();
      print('Raw cluster from .env: "$rawCluster"');

      String uri;
      if (rawCluster.startsWith('mongodb+srv://') ||
          rawCluster.startsWith('mongodb://')) {
        uri = rawCluster;
      } else {
        var cluster = rawCluster.replaceAll(RegExp(r'\s+'), '');
        print('Cluster after whitespace removal: "$cluster"');
        cluster = cluster.replaceFirst(RegExp(r'^mongodb\+srv://'), '');
        print('Cluster after removing mongodb+srv://: "$cluster"');
        cluster = cluster.replaceFirst(RegExp(r'^mongodb://'), '');
        print('Cluster after removing mongodb://: "$cluster"');
        cluster = cluster.replaceAll(RegExp(r'/+$'), '');
        print('Cluster after removing trailing slashes: "$cluster"');
        uri =
            'mongodb+srv://$dbUser:$dbPassword@$cluster/travelly?retryWrites=true&w=majority';
      }

      print('MongoDB URI: $uri');
      db = await Db.create(uri);
      await db.open();

      if (!context.mounted) return;

      var usersCollection = db.collection('users');
      var profileCollection = db.collection('profile');

      await usersCollection.insertOne({
        'username': emailController.text.trim(),
        'password': passwordController.text.trim(),
      });

      var newUser = await usersCollection.findOne(
        where.eq('username', emailController.text.trim()),
      );

      print('Newly created user: $newUser');

      await profileCollection.insertOne({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'userId': newUser?['_id'],
      });

      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Account created successfully!'),
        ));
        await Future.delayed(const Duration(seconds: 3), () {
          if(context.mounted) {
            firstNameController.clear();
            lastNameController.clear();
            emailController.clear();
            passwordController.clear();
            _open(context, const VerifyEmailPage());
          }
        });
      }
      }catch (e) {
        print('Error during sign up: $e');
        String message = e.toString().contains('Invalid scheme in uri')
            ? 'Unable to connect: invalid MongoDB URI. Check your cluster value.'
            : 'Sign up failed. Please try again.';
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
          ));
        }
      }finally {
        if (db != null && db.isConnected) {
          await db.close();
          if (db.isConnected == false ) {
            print('Database connection closed.');
          } else {
            print('Failed to close database connection.');
          }
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 72),
                    const Text('Create account',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const Text("Let's get started",
                        style: TextStyle(fontSize: 14, color: AppColors.greyText)),
                    const SizedBox(height: 32),
                    Expanded(child: _signUpField(context)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Form _signUpField(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            // First Name
            Container(
              height: 58,
              margin: const EdgeInsets.only(bottom: 13),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.mail, size: 22, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              controller: firstNameController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontSize: 12, color: AppColors.greyText),
                                labelText: "First Name",
                                labelStyle: const TextStyle(
                                    fontSize: 15, color: AppColors.greyText),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Last Name
            Container(
              height: 58,
              margin: const EdgeInsets.only(bottom: 13),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.mail, size: 22, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              controller: lastNameController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontSize: 12, color: AppColors.greyText),
                                labelText: "Last Name",
                                labelStyle: const TextStyle(
                                    fontSize: 15, color: AppColors.greyText),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Username
            Container(
              height: 58,
              margin: const EdgeInsets.only(bottom: 13),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.mail, size: 22, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              controller: emailController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontSize: 12, color: AppColors.greyText),
                                labelText: "Email",
                                labelStyle: const TextStyle(
                                    fontSize: 15, color: AppColors.greyText),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Password
            Container(
              height: 58,
              margin: const EdgeInsets.only(bottom: 13),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.lock, size: 22, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              controller: passwordController,
                              maxLines: 1,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontSize: 12, color: AppColors.greyText),
                                labelText: "Password",
                                labelStyle: const TextStyle(
                                    fontSize: 15, color: AppColors.greyText),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const _Rule('At least 6 characters'),
            const _Rule('Includes Number'),
            const _Rule('Includes uppercase letter'),
            const Spacer(),
            GreenButton(
                text: 'Sign up',
                onTap: () => _signUp(context)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _open(context, LoginPage()),
              // onTap: () => _signUp(context),
              child: const Text.rich(
                TextSpan(text: 'Already have an account? ', children: [
                  TextSpan(
                      text: 'Log in',
                      style: TextStyle(
                          color: AppColors.green, fontWeight: FontWeight.w900))
                ]),
                style: TextStyle(fontSize: 11),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ));
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
      child: icon != null
          ? Icon(icon, color: Colors.black, size: 30)
          : Text(label!,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue)),
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
        const Icon(Icons.check_circle_outline,
            size: 16, color: AppColors.green),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
