import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'home_page.dart';
import 'signup_page.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({super.key});

  void _replace(BuildContext context, Widget page) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _login(BuildContext context) async {
    Db? db;
    try {
      final dbUser = dotenv.get('MONGODB_USER').trim();
      final dbPassword = dotenv.get('MONGODB_PASSWORD').trim();
      final rawCluster = dotenv.get('MONGODB_CLUSTER').trim();

      String uri;
      if (rawCluster.startsWith('mongodb+srv://') ||
          rawCluster.startsWith('mongodb://')) {
        uri = rawCluster;
      } else {
        var cluster = rawCluster.replaceAll(RegExp(r'\s+'), '');
        cluster = cluster.replaceFirst(RegExp(r'^mongodb\+srv://'), '');
        cluster = cluster.replaceFirst(RegExp(r'^mongodb://'), '');
        cluster = cluster.replaceAll(RegExp(r'/+$'), '');
        uri =
            'mongodb+srv://$dbUser:$dbPassword@$cluster/travelly?retryWrites=true&w=majority';
      }

      print('MongoDB URI: $uri');
      db = await Db.create(uri);
      await db.open();

      if (!context.mounted) return;

      var collection = db.collection('users');
      var user = await collection.findOne(
        where.eq('username', emailController.text.trim()),
      );

      print(emailController.text.trim());
      print(user);

      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(
            content: Text(
                'User not found. Please check your credentials.'),
          ));
        }
        return;
      }

      if (user['password'] != passwordController.text.trim()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(
            content:
                Text('Incorrect password. Please try again.'),
          ));
        }
        return;
      }

      if (context.mounted) {
        emailController.clear();
        passwordController.clear();
        _replace(context, const HomePage());
      }
      
    } catch (e) {
      print('Error: ${e.toString()}');
      if (context.mounted) {
        final message = e
                .toString()
                .contains('Invalid scheme in uri')
            ? 'Unable to connect: invalid MongoDB URI. Check your cluster value.'
            : 'Login failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    } finally {
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
        child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 72),
          const Text('Welcome Back!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('login to continue your sustainable\njourney!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.greyText)),
          const SizedBox(height: 42),
          _loginField(context),
          // const IosField(icon: Icons.mail, label: 'Email', value: 'JohnDoe@email.com'),
          // const IosField(icon: Icons.password, label: 'Password', value: 'password', obscure: true, trailing: Icons.visibility),
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
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => _open(context, SignUpPage()),
            child: const Text.rich(
              TextSpan(text: "Don't have an account? ", children: [
                TextSpan(
                    text: 'Sign up',
                    style: TextStyle(
                        color: AppColors.green, fontWeight: FontWeight.w900))
              ]),
              style: TextStyle(fontSize: 11),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    ));
  }

  Form _loginField(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
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
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?',
                        style:
                            TextStyle(color: AppColors.green, fontSize: 11)))),
            GreenButton(
                text: 'Log In',
                onTap: () => _login(context),
            ),
            const SizedBox(height: 30),
            const Row(children: [
              Expanded(child: Divider()),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or continue with',
                      style:
                          TextStyle(fontSize: 10, color: AppColors.greyText))),
              Expanded(child: Divider())
            ]),
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



// Form is now interactable
// Need to connect Mongo with mongo_dart package and implement login logic with backend.
// Need form key and controller, then use it to interact with MongoDB and validate login credentials.