import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../core/pet_data.dart';
import '../models/garden_catalogue.dart';
import '../models/pet_state.dart';
import '../widgets/pet_data_view.dart';
import '../models/pet.dart';
import '../ui/entrance.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/pet_avatar.dart';
import 'activities_page.dart';
import 'pet_profile_page.dart';
import 'pet_selection_page.dart';

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key, this.data});

  final PetData? data;

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  late final PetData _data = widget.data ?? PetData.instance;
  Timer? _timer;
  Timer? _refresh;

  @override
  void initState() {
    super.initState();
    unawaited(Future.microtask(_data.loadShop));
    _refresh = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && !_data.busy && !_data.needsRetry) unawaited(_data.load());
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _data.value?.cooldowns.isNotEmpty == true) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refresh?.cancel();
    super.dispose();
  }

  bool get _ready =>
      !_data.busy &&
      !_data.shopBusy &&
      !_data.needsRetry &&
      !_data.needsRefresh &&
      _data.shop != null &&
      _data.shopError == null;

  Widget _itemButton(IconData icon, String label, String id) {
    final item = _data.shop?.items[id];
    final quantity = _data.value?.inventory[id] ?? 0;
    final owned = item?.durable == true && quantity > 0;
    final detail = owned
        ? 'Owned'
        : quantity > 0
        ? '$quantity owned'
        : item == null
        ? 'Loading…'
        : '${item.price} coins';
    return _Action(
      key: ValueKey('pet-action-$id'),
      icon: icon,
      label: label,
      detail: detail,
      onTap: _ready && item != null && !owned ? () => _itemOptions(id) : null,
    );
  }

  Future<void> _itemOptions(String id) async {
    final owner = _data.owner;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => ValueListenableBuilder<PetState?>(
        valueListenable: _data,
        builder: (context, state, _) {
          final item = _data.shop?.items[id];
          final available =
              state != null && _data.owner == owner && item != null;
          final quantity = state?.inventory[id] ?? 0;
          final owned = item?.durable == true && quantity > 0;
          final canBuy =
              available && _ready && !owned && state.stats.coins >= item.price;
          final canUse =
              available &&
              _ready &&
              quantity > 0 &&
              _data.shop!.actions.contains(id) &&
              _data.needsCare(id) &&
              _data.cooldownFor(id) == Duration.zero;
          return CupertinoActionSheet(
            title: Text(available ? item.name : 'Garden item'),
            message: Text(
              !available
                  ? 'Close this menu and try again.'
                  : '${item.price} coins · $quantity owned · ${state.stats.coins} coins available'
                        '${!owned && state.stats.coins < item.price ? '\nNot enough coins yet.' : ''}'
                        '${_data.shop!.actions.contains(id) && !_data.needsCare(id) ? '\nYour pet does not need this care yet.' : ''}',
            ),
            actions: [
              if (canUse)
                CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    if (_data.owner == owner) await _data.care(id);
                  },
                  child: Text('Use ${item.name}'),
                ),
              if (canBuy)
                CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    if (_data.owner == owner) await _data.buy(id);
                  },
                  child: Text('Buy ${item.name} (${item.price} coins)'),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: const Text('Cancel'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openShop() async {
    final owner = _data.owner;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => ValueListenableBuilder<PetState?>(
        valueListenable: _data,
        builder: (context, state, _) => CupertinoActionSheet(
          title: const Text('Garden shop'),
          message: Text(
            state != null && _data.owner == owner
                ? '${state.stats.coins} coins available'
                : 'Close this menu and try again.',
          ),
          actions: [
            if (_data.owner == owner && state != null)
              for (final item
                  in _data.shop?.items.values ?? const <GardenItem>[])
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    if (mounted && _data.owner == owner) _itemOptions(item.id);
                  },
                  child: Text('${item.name} · ${item.price} coins'),
                ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Cancel'),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => PetDataView(
    data: widget.data,
    builder: (context, state) => _build(context, state),
  );

  Widget _build(BuildContext context, PetState state) {
    final cooldown = _data.cooldownFor('sunlight');
    final eco = LGColor.resolve(LGColor.eco, context);

    return AppShell(
      showBottomNav: true,
      selectedIndex: 4,
      padding: EdgeInsets.zero,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          LGGap.edge,
          MediaQuery.paddingOf(context).top + LGGap.md,
          LGGap.edge,
          MediaQuery.paddingOf(context).bottom +
              AppShell.navHeight +
              LGGap.section,
        ),
        children: [
          PetStatus(data: _data),
          if (_data.shopBusy)
            const Padding(
              padding: EdgeInsets.only(bottom: LGGap.lg),
              child: CupertinoActivityIndicator(),
            ),
          if (_data.shopError != null) ...[
            Text(_data.shopError!, style: LGText.footnote(context)),
            GlassButton(
              label: 'Reload shop',
              onPressed: () => _data.loadShop(),
            ),
            const SizedBox(height: LGGap.lg),
          ],
          Entrance(
            index: 0,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${PetCatalogue.byId(state.selectedPetId).name}'s garden",
                    style: LGText.title2(context),
                  ),
                ),
                const SizedBox(width: LGGap.md),
                GlassPill(
                  label : '${state.stats.coins}',
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  color: LGColor.resolve(LGColor.effort, context),
                ),
              ],
            ),
          ),
          const SizedBox(height: LGGap.md),
          GlassButton(
            label: 'Change pet',
            onPressed: !_data.busy && !_data.needsRetry && !_data.needsRefresh
                ? () => Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (_) => PetSelectionPage(data: widget.data),
                    ),
                  )
                : null,
            style: GlassButtonStyle.tinted,
          ),
          const SizedBox(height: LGGap.edge),

          Entrance(
            index: 1,
            child: ClipRSuperellipse(
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
                    if ((state.inventory['kennel'] ?? 0) > 0)
                      Positioned(
                        key: const ValueKey('garden-kennel'),
                        left: 28,
                        top: 34,
                        child: Icon(
                          CupertinoIcons.house_fill,
                          size: 76,
                          color: LGColor.resolve(LGColor.effort, context),
                        ),
                      ),
                    Positioned(
                      right: 48,
                      top: 74,
                      child: PetAvatar(
                        pet: PetCatalogue.byId(state.selectedPetId),
                      ),
                    ),
                    if ((state.inventory['small_pot'] ?? 0) > 0)
                      Positioned(
                        key: const ValueKey('garden-small-pot'),
                        left: 100,
                        bottom: 26,
                        child: Icon(CupertinoIcons.tree, size: 38, color: eco),
                      ),
                    Positioned(
                      left: 18,
                      bottom: 26,
                      child: Icon(
                        CupertinoIcons.leaf_arrow_circlepath,
                        size: 38,
                        color: eco,
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 22,
                      child: Icon(
                        CupertinoIcons.leaf_arrow_circlepath,
                        size: 60,
                        color: LGColor.resolve(
                          LGColor.eco,
                          context,
                        ).withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: LGGap.edge),

          GreyPanel(
            padding: const EdgeInsets.all(LGGap.edge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Care for your pet', style: LGText.headline(context)),
                const SizedBox(height: LGGap.md),
                for (final stat in [
                  ('Happiness', state.stats.happiness),
                  ('Energy', state.stats.energy),
                  ('Health', state.stats.health),
                ]) ...[
                  Text(
                    '${stat.$1}: ${(stat.$2 * 100).round()}%',
                    style: LGText.footnote(context),
                  ),
                  const SizedBox(height: LGGap.xs),
                  GlassProgress(value: stat.$2),
                  const SizedBox(height: LGGap.md),
                ],
                Text(
                  'Water restores health and happiness. Fertiliser restores health. Sunlight restores energy. Condition drops gradually, even while you are away.',
                  style: LGText.footnote(context),
                ),
                const SizedBox(height: LGGap.sm),
                Text(
                  'A small pot slows happiness loss. A kennel slows energy loss.',
                  style: LGText.footnote(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: LGGap.edge),
          Entrance(
            index: 2,
            child: GreyPanel(
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
                          onTap: () =>
                              _open(context, ActivitiesPage(data: widget.data)),
                        ),
                      ),
                      const SizedBox(width: LGGap.lg),
                      Expanded(
                        child: GhostButton(
                          text: 'Profile',
                          icon: CupertinoIcons.person_fill,
                          onTap: () =>
                              _open(context, PetProfilePage(data: widget.data)),
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
                    children: [
                      _itemButton(
                        CupertinoIcons.leaf_arrow_circlepath,
                        'Small pot',
                        'small_pot',
                      ),
                      _itemButton(CupertinoIcons.drop_fill, 'Water', 'water'),
                      _itemButton(
                        CupertinoIcons.sparkles,
                        'Fertiliser',
                        'fertiliser',
                      ),
                      _Action(
                        key: const ValueKey('pet-action-sunlight'),
                        icon: CupertinoIcons.sun_max_fill,
                        label: 'Sunlight',
                        detail: cooldown > Duration.zero
                            ? 'Ready in ${(cooldown.inSeconds / 60).ceil()}m'
                            : _data.needsCare('sunlight')
                            ? 'Free'
                            : 'Rested',
                        onTap:
                            _ready &&
                                _data.shop!.actions.contains('sunlight') &&
                                _data.needsCare('sunlight') &&
                                cooldown == Duration.zero
                            ? () => _data.care('sunlight')
                            : null,
                      ),
                      _itemButton(
                        CupertinoIcons.house_fill,
                        'Kennel',
                        'kennel',
                      ),
                      _Action(
                        key: const ValueKey('pet-action-more'),
                        icon: CupertinoIcons.plus,
                        label: 'More',
                        detail: 'Shop',
                        onTap: _ready ? _openShop : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback? onTap;

  const _Action({
    super.key,
    required this.icon,
    required this.label,
    required this.detail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final eco = LGColor.resolve(LGColor.eco, context);

    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: GlassTappable(
        onTap: onTap,
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
              const SizedBox(height: LGGap.xxs),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LGText.caption2(context).copyWith(
                  color: LGColor.resolve(LGColor.secondaryLabel, context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
