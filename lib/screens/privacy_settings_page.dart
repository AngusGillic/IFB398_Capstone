import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travelly_flutter_ios_style/screens/login_page.dart';

import '../ui/glass.dart';
import '../ui/glass_widgets.dart';

// Deepak's packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

/// Placeholder. The switches hold local state only and are not wired to
/// anything yet.
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _locationTracking = true;
  bool _backgroundTracking = false;
  bool _shareAnalytics = false;
  bool _personalisedTips = true;

  void _replace(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Future<void> _deleteAccount (BuildContext context) async {
    try {
      final currentUser = await Amplify.Auth.getCurrentUser();

      final String userID = currentUser.userId;
      final String username = currentUser.username;

      safePrint("Deleting account for user: $username($userID)");

      // final result = await Amplify.Auth.deleteUser(); 
      await Amplify.Auth.deleteUser();

      // Consideration: possibly that it is still required to clean up user data that might still be in DynamoDB
      // As of now following the Amplify.Auth.deleteUser(), previous account wasn't able to login. 

      safePrint('Delete user succeeded');
      _replace(context, LoginPage());

    } on AuthException catch (e) {
      safePrint('Delete user failed with error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    return GlassScaffold(
      title: 'Privacy',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassSurface(
            radius: LGRadius.md,
            dense: true,
            padding: const EdgeInsets.all(LGGap.edge),
            shadows: LGShadow.low(context),
            child: Row(
              children: [
                Icon(CupertinoIcons.lock_shield_fill,
                    size: 20, color: LGColor.resolve(LGColor.eco, context)),
                const SizedBox(width: LGGap.xl),
                Expanded(
                  child: Text(
                    'Your trips are processed on this device wherever possible.',
                    style: LGText.footnote(context).copyWith(color: secondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: LGGap.section),

          GlassSection(
            header: 'Location',
            footer: 'Background tracking lets Travelly detect trips automatically.',
            children: [
              GlassRow(
                title: 'Location access',
                icon: CupertinoIcons.location_fill,
                chevron: false,
                trailing: CupertinoSwitch(
                  value: _locationTracking,
                  onChanged: (v) => setState(() => _locationTracking = v),
                ),
              ),
              GlassRow(
                title: 'Background tracking',
                icon: CupertinoIcons.arrow_2_circlepath,
                chevron: false,
                trailing: CupertinoSwitch(
                  value: _backgroundTracking,
                  onChanged: _locationTracking
                      ? (v) => setState(() => _backgroundTracking = v)
                      : null,
                ),
              ),
            ],
          ),

          GlassSection(
            header: 'Data',
            children: [
              GlassRow(
                title: 'Share anonymous analytics',
                icon: CupertinoIcons.chart_bar_alt_fill,
                iconColor: LGColor.resolve(LGColor.effort, context),
                chevron: false,
                trailing: CupertinoSwitch(
                  value: _shareAnalytics,
                  onChanged: (v) => setState(() => _shareAnalytics = v),
                ),
              ),
              GlassRow(
                title: 'Personalised suggestions',
                icon: CupertinoIcons.sparkles,
                iconColor: LGColor.resolve(LGColor.transit, context),
                chevron: false,
                trailing: CupertinoSwitch(
                  value: _personalisedTips,
                  onChanged: (v) => setState(() => _personalisedTips = v),
                ),
              ),
            ],
          ),

          GlassSection(
            header: 'Your data',
            children: [
              GlassRow(
                title: 'Download my data',
                icon: CupertinoIcons.arrow_down_circle_fill,
                iconColor: secondary,
                onTap: () => showGlassToast(context, 'Not implemented yet'),
              ),
              GlassRow(
                title: 'Delete account',
                icon: CupertinoIcons.trash_fill,
                destructive: true,
                onTap: () async { 
                  final confirmed = await showGlassConfirm(
                    context,
                    title: 'Delete account?',
                    message: 'This cannot be undone.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );

                  if (confirmed && context.mounted) {
                    _deleteAccount(context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
