import 'package:flutter/cupertino.dart';

import '../data/user_data.dart';
import '../models/pet.dart';
import '../ui/entrance.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';
import 'activities_page.dart';
import 'pet_profile_page.dart';

class PetHomePage extends StatelessWidget {
  const PetHomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final eco = LGColor.resolve(LGColor.eco, context);

    return AppShell(
      showBottomNav: true,
      selectedIndex: 4,
      padding: EdgeInsets.zero,
      child: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(
          LGGap.edge,
          MediaQuery.paddingOf(context).top + LGGap.md,
          LGGap.edge,
          MediaQuery.paddingOf(context).bottom + AppShell.navHeight + LGGap.section,
        ),
        children: [
          Entrance(index: 0, child: Row(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: PetController.instance,
                builder: (context, _, __) => Text(
                  "${PetController.instance.selected.name}'s garden",
                  style: LGText.title2(context),
                ),
              ),
              const Spacer(),
              GlassPill(
                label: '${AppData.current.pet.coins}',
                icon: CupertinoIcons.money_dollar_circle_fill,
                color: LGColor.resolve(LGColor.effort, context),
              ),
            ],
          )),
          const SizedBox(height: LGGap.edge),

          Entrance(index: 1, child: ClipRSuperellipse(
            borderRadius: LGShape.radius(LGRadius.xl),
            child: Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDCEEFF), Color(0xFFE8F6EC)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 28,
                    top: 34,
                    child: Icon(CupertinoIcons.house_fill, size: 76,
                        color: LGColor.resolve(LGColor.effort, context)),
                  ),
                  const Positioned(right: 48, top: 74, child: PlaceholderPet(size: 92)),
                  Positioned(
                    left: 18,
                    bottom: 26,
                    child: Icon(CupertinoIcons.leaf_arrow_circlepath, size: 38, color: eco),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 22,
                    child: Icon(CupertinoIcons.leaf_arrow_circlepath, size: 60,
                        color: LGColor.resolve(LGColor.eco, context)
                            .withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: LGGap.edge),

          Entrance(index: 2, child: GreyPanel(
            radius: LGRadius.lg,
            padding: const EdgeInsets.all(LGGap.edge),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GhostButton(
                        text: 'Activities',
                        icon: CupertinoIcons.flame_fill,
                        onTap: () => _open(context, const ActivitiesPage()),
                      ),
                    ),
                    const SizedBox(width: LGGap.lg),
                    Expanded(
                      child: GhostButton(
                        text: 'Profile',
                        icon: CupertinoIcons.person_fill,
                        onTap: () => _open(context, const PetProfilePage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LGGap.edge),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: LGGap.lg,
                  crossAxisSpacing: LGGap.lg,
                  childAspectRatio: 1.05,
                  children: const [
                    _Action(icon: CupertinoIcons.leaf_arrow_circlepath, label: 'Small pot'),
                    _Action(icon: CupertinoIcons.drop_fill, label: 'Water'),
                    _Action(icon: CupertinoIcons.sparkles, label: 'Fertiliser'),
                    _Action(icon: CupertinoIcons.sun_max_fill, label: 'Sunlight'),
                    _Action(icon: CupertinoIcons.house_fill, label: 'Kennel'),
                    _Action(icon: CupertinoIcons.plus, label: 'More'),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Action({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final eco = LGColor.resolve(LGColor.eco, context);

    return GlassTappable(
      onTap: () {},
      child: GlassSurface(
        radius: LGRadius.sm,
        blur: LGGlass.blurLight,
        shadows: LGShadow.low(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: eco, size: 22),
            const SizedBox(height: LGGap.sm),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LGText.caption2(context),
            ),
          ],
        ),
      ),
    );
  }
}
