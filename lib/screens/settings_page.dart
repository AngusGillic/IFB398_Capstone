import 'package:flutter/cupertino.dart';

import '../data/user_data.dart';
import '../ui/app_theme.dart';
import '../ui/entrance.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';
import 'appearance_page.dart';
import 'privacy_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    return AppShell(
      showBottomNav: true,
      selectedIndex: 0,
      padding: EdgeInsets.zero,
      child: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(
          LGGap.edge,
          MediaQuery.paddingOf(context).top + LGGap.section,
          LGGap.edge,
          MediaQuery.paddingOf(context).bottom + AppShell.navHeight + LGGap.section,
        ),
        children: [
          Entrance(index: 0, child: Text('Settings', style: LGText.largeTitle(context))),
          const SizedBox(height: LGGap.section),
          Entrance(index: 1, child: GlassSection(
            children: [
              GlassRow(
                title: AppData.current.profile.fullName,
                subtitle: AppData.current.profile.email,
                icon: CupertinoIcons.person_fill,
                onTap: () {},
              ),
            ],
          )),
          Entrance(index: 2, child: GlassSection(
            header: 'Preferences',
            children: [
              ValueListenableBuilder<AppThemeMode>(
                valueListenable: ThemeController.instance,
                builder: (context, mode, _) => GlassRow(
                  title: 'Appearance',
                  icon: CupertinoIcons.circle_lefthalf_fill,
                  trailing: Text(mode.label),
                  onTap: () => _open(context, const AppearancePage()),
                ),
              ),
              GlassRow(
                title: 'Notifications',
                icon: CupertinoIcons.bell_fill,
                iconColor: LGColor.resolve(LGColor.effort, context),
                onTap: () {},
              ),
              GlassRow(
                title: 'Units',
                icon: CupertinoIcons.arrow_right_arrow_left,
                trailing: const Text('Metric'),
                onTap: () {},
              ),
            ],
          )),
          Entrance(index: 3, child: GlassSection(
            header: 'Privacy',
            footer: 'Travelly processes location on your device wherever possible.',
            children: [
              GlassRow(
                title: 'Privacy settings',
                icon: CupertinoIcons.hand_raised_fill,
                iconColor: LGColor.resolve(LGColor.transit, context),
                onTap: () => _open(context, const PrivacySettingsPage()),
              ),
            ],
          )),
          Entrance(index: 4, child: GlassSection(
            header: 'About',
            children: [
              GlassRow(
                title: 'Version',
                icon: CupertinoIcons.info_circle_fill,
                iconColor: secondary,
                chevron: false,
                trailing: const Text('1.0.0'),
              ),
              GlassRow(
                title: 'Sign out',
                icon: CupertinoIcons.square_arrow_right,
                destructive: true,
                chevron: false,
                onTap: () async {
                  final confirmed = await showGlassConfirm(
                    context,
                    title: 'Sign out?',
                    confirmLabel: 'Sign Out',
                    destructive: true,
                  );
                  if (confirmed && context.mounted) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                },
              ),
            ],
          )),
        ],
      ),
    );
  }
}
