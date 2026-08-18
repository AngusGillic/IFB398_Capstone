import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../services/geo_service.dart';
import '../services/maps_config.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';

enum TravelMode { walk, cycle, transit, drive }

extension TravelModeMeta on TravelMode {
  String get label => switch (this) {
        TravelMode.walk => 'Walk',
        TravelMode.cycle => 'Cycle',
        TravelMode.transit => 'Transit',
        TravelMode.drive => 'Drive',
      };

  String get key => name;

  IconData get icon => switch (this) {
        TravelMode.walk => CupertinoIcons.person_fill,
        TravelMode.cycle => CupertinoIcons.gauge,
        TravelMode.transit => CupertinoIcons.bus,
        TravelMode.drive => CupertinoIcons.car_detailed,
      };
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapController = MapController();
  final _originCtrl = TextEditingController(text: 'Current location');
  final _destCtrl = TextEditingController();
  final _destFocus = FocusNode();

  static final _origin = LatLng(MapsConfig.defaultLat, MapsConfig.defaultLng);

  TravelMode _mode = TravelMode.transit;
  Timer? _debounce;

  List<Place> _suggestions = const [];
  Place? _destination;
  RouteResult? _route;

  bool _expanded = false;
  bool _searching = false;
  bool _routing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _destFocus.addListener(() {
      if (_destFocus.hasFocus) setState(() => _expanded = true);
    });
    _destCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _originCtrl.dispose();
    _destCtrl.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  /// Nominatim asks for no more than one request a second.
  void _onQueryChanged() {
    _debounce?.cancel();
    final query = _destCtrl.text;

    if (query.trim().length < 3) {
      setState(() => _suggestions = const []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 700), () async {
      setState(() => _searching = true);
      try {
        final results = await GeoService.search(query);
        if (mounted) setState(() => _suggestions = results);
      } catch (_) {
        if (mounted) setState(() => _error = 'Search unavailable');
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  Future<void> _selectPlace(Place place) async {
    FocusScope.of(context).unfocus();
    _destCtrl.removeListener(_onQueryChanged);
    _destCtrl.text = place.name;
    _destCtrl.addListener(_onQueryChanged);

    setState(() {
      _destination = place;
      _suggestions = const [];
      _routing = true;
      _error = null;
    });

    try {
      final result = await GeoService.route(_origin, place.point);
      if (!mounted) return;

      setState(() => _route = result);

      if (result != null && result.points.isNotEmpty) {
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: result.points,
            padding: const EdgeInsets.fromLTRB(50, 160, 50, 320),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Routing unavailable');
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    setState(() {
      _destCtrl.clear();
      _destination = null;
      _route = null;
      _suggestions = const [];
      _expanded = false;
      _error = null;
    });
    _mapController.move(_origin, MapsConfig.defaultZoom);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final accent = LGColor.resolve(LGColor.accent, context);
    final showResults = _route != null && _destination != null;

    return AppShell(
      showBottomNav: true,
      selectedIndex: 3,
      padding: EdgeInsets.zero,
      backdrop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _origin,
                initialZoom: MapsConfig.defaultZoom,
                onTap: (_, __) => FocusScope.of(context).unfocus(),
              ),
              children: [
                TileLayer(
                  urlTemplate: MapsConfig.tileUrl,
                  userAgentPackageName: MapsConfig.userAgent,
                  maxNativeZoom: 19,
                ),
                if (_route != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route!.points,
                        strokeWidth: 6,
                        color: accent,
                        borderStrokeWidth: 2,
                        borderColor: const Color(0x33FFFFFF),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _origin,
                      width: 22,
                      height: 22,
                      child: const _OriginDot(),
                    ),
                    if (_destination != null)
                      Marker(
                        point: _destination!.point,
                        width: 34,
                        height: 34,
                        child: _DestinationPin(color: accent),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: top + LGGap.md,
            left: LGGap.xl,
            right: LGGap.xl,
            child: _SearchCard(
              originCtrl: _originCtrl,
              destCtrl: _destCtrl,
              destFocus: _destFocus,
              expanded: _expanded,
              searching: _searching,
              suggestions: _suggestions,
              onSelect: _selectPlace,
              onClear: _reset,
            ),
          ),

          Positioned(
            right: LGGap.xl,
            bottom: bottom + AppShell.navHeight + (showResults ? 300 : LGGap.section),
            child: Column(
              children: [
                GlassIconButton(
                  icon: CupertinoIcons.location_fill,
                  semanticLabel: 'Centre on my location',
                  size: 42,
                  color: accent,
                  onPressed: () => _mapController.move(_origin, 15),
                ),
                const SizedBox(height: LGGap.md),
                GlassIconButton(
                  icon: CupertinoIcons.plus,
                  semanticLabel: 'Zoom in',
                  size: 42,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                ),
                const SizedBox(height: LGGap.sm),
                GlassIconButton(
                  icon: CupertinoIcons.minus,
                  semanticLabel: 'Zoom out',
                  size: 42,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                ),
              ],
            ),
          ),

          if (!showResults)
            Positioned(
              left: LGGap.xl,
              bottom: bottom + AppShell.navHeight + LGGap.md,
              child: const _Attribution(),
            ),

          if (_routing)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottom + AppShell.navHeight + 60,
              child: const Center(child: GlassLoader()),
            ),

          if (_error != null && !_routing)
            Positioned(
              left: LGGap.xl,
              right: LGGap.xl,
              bottom: bottom + AppShell.navHeight + 60,
              child: _ErrorCard(message: _error!),
            ),

          if (showResults)
            Align(
              alignment: Alignment.bottomCenter,
              child: _RoutesSheet(
                mode: _mode,
                onModeChanged: (m) => setState(() => _mode = m),
                destination: _destination!,
                route: _route!,
              ),
            ),
        ],
      ),
    );
  }
}

class _OriginDot extends StatelessWidget {
  const _OriginDot();

  @override
  Widget build(BuildContext context) {
    final accent = LGColor.resolve(LGColor.accent, context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFFFFF), width: 3),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 8),
        ],
      ),
    );
  }
}

class _DestinationPin extends StatelessWidget {
  const _DestinationPin({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFFFFF), width: 3),
      ),
      child: const Icon(CupertinoIcons.flag_fill,
          size: 14, color: Color(0xFFFFFFFF)),
    );
  }
}

/// Required by the OpenStreetMap licence.
class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: LGRadius.pill,
      blur: LGGlass.blurLight,
      dense: true,
      padding: const EdgeInsets.symmetric(horizontal: LGGap.lg, vertical: LGGap.xs),
      child: Text(
        MapsConfig.attribution,
        style: LGText.caption2(context).copyWith(
          color: LGColor.resolve(LGColor.secondaryLabel, context),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final danger = LGColor.resolve(LGColor.burn, context);

    return GlassSurface(
      radius: LGRadius.md,
      blur: LGGlass.blurHeavy,
      dense: true,
      padding: const EdgeInsets.all(LGGap.edge),
      child: Row(
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 17, color: danger),
          const SizedBox(width: LGGap.xl),
          Expanded(child: Text(message, style: LGText.subhead(context))),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.originCtrl,
    required this.destCtrl,
    required this.destFocus,
    required this.expanded,
    required this.searching,
    required this.suggestions,
    required this.onSelect,
    required this.onClear,
  });

  final TextEditingController originCtrl;
  final TextEditingController destCtrl;
  final FocusNode destFocus;
  final bool expanded;
  final bool searching;
  final List<Place> suggestions;
  final ValueChanged<Place> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    return GlassSurface(
      radius: LGRadius.lg,
      blur: LGGlass.blurHeavy,
      dense: true,
      padding: const EdgeInsets.all(LGGap.lg),
      child: AnimatedSize(
        duration: LGMotion.medium,
        curve: LGMotion.standard,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (expanded) ...[
              GlassField(
                controller: originCtrl,
                placeholder: 'Start',
                icon: CupertinoIcons.circle,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: LGGap.md),
            ],
            GlassField(
              controller: destCtrl,
              focusNode: destFocus,
              placeholder: 'Where to?',
              icon: CupertinoIcons.search,
              textInputAction: TextInputAction.search,
              suffix: searching
                  ? const CupertinoActivityIndicator(radius: 8)
                  : (destCtrl.text.isEmpty
                      ? null
                      : GlassTappable(
                          haptic: false,
                          scale: 0.85,
                          onTap: onClear,
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 17,
                            color: LGColor.resolve(LGColor.tertiaryLabel, context),
                          ),
                        )),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: LGGap.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: suggestions.length,
                  separatorBuilder: (context, _) => Container(
                    height: 0.33,
                    margin: const EdgeInsets.only(left: 34),
                    color: LGColor.resolve(LGColor.separator, context),
                  ),
                  itemBuilder: (context, i) {
                    final place = suggestions[i];
                    return GlassTappable(
                      haptic: false,
                      scale: 0.99,
                      onTap: () => onSelect(place),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: LGGap.lg),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.placemark, size: 16, color: secondary),
                            const SizedBox(width: LGGap.xl),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    place.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: LGText.subhead(context),
                                  ),
                                  if (place.detail.isNotEmpty)
                                    Text(
                                      place.detail,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: LGText.caption1(context)
                                          .copyWith(color: secondary),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoutesSheet extends StatelessWidget {
  const _RoutesSheet({
    required this.mode,
    required this.onModeChanged,
    required this.destination,
    required this.route,
  });

  final TravelMode mode;
  final ValueChanged<TravelMode> onModeChanged;
  final Place destination;
  final RouteResult route;

  String _duration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    final m = d.inMinutes.remainder(60);
    return m == 0 ? '${d.inHours} h' : '${d.inHours} h $m min';
  }

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);
    final eco = LGColor.resolve(LGColor.eco, context);

    final km = route.distanceKm;
    final options = TravelMode.values.map((m) {
      return (
        mode: m,
        duration: GeoService.estimateFor(m.key, km, route),
        saving: GeoService.savingKg(m.key, km),
      );
    }).toList()
      ..sort((a, b) => b.saving.compareTo(a.saving));

    return GlassSurface(
      radius: LGRadius.xl,
      blur: LGGlass.blurHeavy,
      dense: true,
      margin: EdgeInsets.fromLTRB(
        LGGap.xl,
        0,
        LGGap.xl,
        MediaQuery.paddingOf(context).bottom + AppShell.navHeight + LGGap.md,
      ),
      padding: const EdgeInsets.fromLTRB(LGGap.edge, 0, LGGap.edge, LGGap.edge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GlassGrabber(),
          Text(
            destination.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LGText.headline(context),
          ),
          const SizedBox(height: LGGap.xxs),
          Text(
            '${km.toStringAsFixed(1)} km · route via OSRM',
            style: LGText.caption1(context).copyWith(color: secondary),
          ),
          const SizedBox(height: LGGap.lg),
          GlassSegmented<TravelMode>(
            groupValue: mode,
            children: {for (final m in TravelMode.values) m: m.label},
            onChanged: onModeChanged,
          ),
          const SizedBox(height: LGGap.lg),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: LGGap.md),
              child: GlassCard(
                radius: LGRadius.md,
                blur: LGGlass.blurLight,
                selected: option.mode == mode,
                onTap: () => onModeChanged(option.mode),
                child: Row(
                  children: [
                    Icon(option.mode.icon, size: 18,
                        color: LGColor.resolve(LGColor.secondaryLabel, context)),
                    const SizedBox(width: LGGap.xl),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_duration(option.duration),
                              style: LGText.title3(context)),
                          Text(option.mode.label,
                              style: LGText.caption1(context)
                                  .copyWith(color: secondary)),
                        ],
                      ),
                    ),
                    if (option.saving > 0)
                      GlassPill(
                        label: '${option.saving.toStringAsFixed(2)} kg saved',
                        color: eco,
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
