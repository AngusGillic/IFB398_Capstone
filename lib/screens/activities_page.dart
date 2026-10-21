import 'package:flutter/cupertino.dart';

import '../core/pet_data.dart';
import '../models/pet_state.dart';
import '../models/pet_trip.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/pet_data_view.dart';
import '../core/user_data_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key, this.data});

  final PetData? data;

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  PetData get _data => widget.data ?? PetData.instance;
  String? _historyOwner;
  int? _historyVersion;
  Future<List<PetTrip>>? _history;

  @override
  void initState() {
    super.initState();
    _spawnDataDynamo();
    _data.addListener(_changed);
    _historyOwner = _data.owner;
    _historyVersion = _data.value?.version;
    _history = _data.tripHistory();
  }

  @override
  void dispose() {
    _data.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (_historyOwner == _data.owner && _historyVersion == _data.value?.version)
      return;
    setState(() {
      _historyOwner = _data.owner;
      _historyVersion = _data.value?.version;
      _history = _data.tripHistory();
    });
  }

  bool get _ready => !_data.busy && !_data.needsRetry && !_data.needsRefresh;

  Future<List<PetTrip>> _spawnDataDynamo() async {
    final userID = UserDataSession.boundUserId;
    List<PetTrip> trips = [];
    try {
      final apiURL =
          "https://9057i6cd5c.execute-api.ap-southeast-2.amazonaws.com/dev/trips";
      final url = Uri.parse('$apiURL?userId=$userID');
      final response = await http.get(url);
      // Map<String, dynamic> data = jsonDecode(response.body);
      // data = jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> resultDecoded = jsonDecode(response.body);
      trips = resultDecoded.values.map((item) {
        return PetTrip.fromRow(item as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Query Failed: $e");
    }
    return trips;
  }

  Future<void> _recordTrip() async {
    final owner = _data.owner;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Record a local trip'),
        message: const Text(
          'These demonstration trips save rewards on this device. They do not track a real journey.',
        ),
        actions: [
          for (final trip in [
            ('Walking', 0.5),
            ('Cycling', 1.0),
            ('Public transport', 2.0),
          ])
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                if (_data.owner == owner && _ready)
                  await _data.recordTrip(trip.$1, trip.$2);
              },
              child: Text(
                '${trip.$1} · ${trip.$2} kg CO₂ · ${(trip.$2 * 10).floor()} coins',
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _trips(BuildContext context) => FutureBuilder<List<PetTrip>>(
    future: _history,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return const CupertinoActivityIndicator();
      if (snapshot.hasError) {
        return GlassButton(
          label: 'Reload trips',
          onPressed: () => setState(() => _history = _data.tripHistory()),
        );
      }
      final trips = snapshot.data ?? [];
      if (trips.isEmpty)
        return Text(
          'No local trips recorded yet.',
          style: LGText.footnote(context),
        );
      return Column(
        children: [
          for (final trip in trips)
            GreyPanel(
              margin: const EdgeInsets.only(bottom: LGGap.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.mode, style: LGText.headline(context)),
                        const SizedBox(height: LGGap.xs),
                        Text(
                          '${trip.savedKg} kg CO₂ saved',
                          style: LGText.footnote(context),
                        ),
                        Text(
                          _tripDate(trip.completedAt),
                          style: LGText.caption1(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: LGGap.md),
                  Text('+${trip.coins} coins', style: LGText.subhead(context)),
                ],
              ),
            ),
        ],
      );
    },
  );

  String _tripDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year} · ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => PetDataView(
    data: widget.data,
    builder: (context, state) => _build(context, state),
  );

  Widget _build(BuildContext context, PetState state) => AppShell(
    showBottomNav: true,
    selectedIndex: 4,
    child: ListView(
      padding: EdgeInsets.fromLTRB(
        2,
        MediaQuery.paddingOf(context).top + LGGap.section,
        2,
        MediaQuery.paddingOf(context).bottom +
            AppShell.navHeight +
            LGGap.section,
      ),
      children: [
        PetStatus(data: _data),
        const BackTitle(title: 'Activities'),
        Text('${state.stats.coins} coins', style: LGText.title2(context)),
        const SizedBox(height: LGGap.edge),
        GreyPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _data.local ? 'Travel and care' : 'No pet activities yet',
                style: LGText.headline(context),
              ),
              const SizedBox(height: LGGap.md),
              Text(
                _data.local
                    ? 'Record a local trip to earn coins and unlock pets. Spend coins on care in the garden.'
                    : 'Pet activities are coming later. You can care for your pet in the garden.',
                style: LGText.footnote(context),
              ),
              if (_data.local) ...[
                const SizedBox(height: LGGap.edge),
                GlassButton(
                  label: 'Record a local trip',
                  onPressed: _ready ? _recordTrip : null,
                  loading: _data.busy,
                ),
              ],
            ],
          ),
        ),
        if (_data.local) ...[
          const SizedBox(height: LGGap.edge),
          Text('Local trip history', style: LGText.headline(context)),
          const SizedBox(height: LGGap.md),
          _trips(context),
        ],
      ],
    ),
  );
}
