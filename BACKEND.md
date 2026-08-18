# Connecting the backend

All user statistics come from one file: `lib/data/user_data.dart`. No screen
hard-codes a number. To go live you change one method and delete one variable.

---

## 1. Where the data lives

```
lib/data/user_data.dart
  UserProfile      name, email, member since
  ImpactSeries     one period of travel (week, month or year)
  LifetimeImpact   running totals since sign-up
  PetStats         coins, happiness, energy, health, days together
  SuggestedTrip    a route offered on the home screen
  Challenge        current challenge and progress
  UserData         all of the above for one user
  AppData          the ValueNotifier the whole app reads
```

`AppData` is a `ValueNotifier<UserData>`. Screens read `AppData.current` or
listen with a `ValueListenableBuilder`, so publishing new data refreshes the UI
with no further changes.

---

## 2. What to change

Replace the body of `AppData.load()`:

```dart
Future<void> load() async {
  value = await ApiClient.fetchUserData();
}
```

Call it once at startup, in `lib/main.dart`:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppData.instance.load();          // fire and forget, UI shows zeros meanwhile
  runApp(const TravellyApp());
}
```

Then delete the `_mock` variable at the bottom of `user_data.dart` and change
the constructor to start empty:

```dart
AppData._() : super(empty);
```

That is the whole integration.

---

## 3. Example client

A minimal version. Adjust to whatever the API actually returns.

```dart
// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/user_data.dart';

class ApiClient {
  static const _base = 'https://api.travelly.example';

  static Future<UserData> fetchUserData({String? token}) async {
    final response = await http.get(
      Uri.parse('$_base/v1/me/summary'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Summary failed: ${response.statusCode}');
    }

    return _parse(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static UserData _parse(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final pet = json['pet'] as Map<String, dynamic>? ?? {};
    final lifetime = json['lifetime'] as Map<String, dynamic>? ?? {};

    return UserData(
      profile: UserProfile(
        firstName: profile['first_name'] as String? ?? '',
        fullName: profile['full_name'] as String? ?? '',
        email: profile['email'] as String? ?? '',
        memberSince:
            DateTime.tryParse(profile['member_since'] as String? ?? '') ??
                DateTime.now(),
      ),
      impact: {
        for (final range in ImpactRange.values)
          range: _series(json['impact']?[range.name] as Map<String, dynamic>?),
      },
      lifetime: LifetimeImpact(
        co2SavedKg: _toDouble(lifetime['co2_saved_kg']),
        totalTrips: _toInt(lifetime['total_trips']),
        totalKm: _toDouble(lifetime['total_km']),
      ),
      pet: PetStats(
        coins: _toInt(pet['coins']),
        happiness: _toDouble(pet['happiness']),
        energy: _toDouble(pet['energy']),
        health: _toDouble(pet['health']),
        daysTogether: _toInt(pet['days_together']),
      ),
      suggestions: ((json['suggestions'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map((s) => SuggestedTrip(
                label: s['label'] as String? ?? '',
                mode: s['mode'] as String? ?? '',
                durationMinutes: _toInt(s['duration_minutes']),
                co2SavedKg: _toDouble(s['co2_saved_kg']),
                leaveAt: s['leave_at'] as String? ?? '',
                arriveAt: s['arrive_at'] as String? ?? '',
              ))
          .toList(),
      challenge: _challenge(json['challenge'] as Map<String, dynamic>?),
    );
  }

  static ImpactSeries _series(Map<String, dynamic>? json) {
    if (json == null) return ImpactSeries.empty;
    return ImpactSeries(
      co2SavedKg: _toDouble(json['co2_saved_kg']),
      goalKg: _toDouble(json['goal_kg']),
      values: ((json['values'] as List?) ?? []).map(_toDouble).toList(),
      labels: ((json['labels'] as List?) ?? []).cast<String>(),
      byMode: ((json['by_mode'] as Map?) ?? {})
          .map((k, v) => MapEntry(k as String, _toDouble(v))),
      greenKm: _toDouble(json['green_km']),
      drivenKm: _toDouble(json['driven_km']),
      changeVsPrevious: _toDouble(json['change_vs_previous']),
      trips: _toInt(json['trips']),
    );
  }

  static Challenge _challenge(Map<String, dynamic>? json) {
    if (json == null) {
      return const Challenge(
        title: 'No challenge yet',
        daysDone: 0,
        daysTotal: 0,
        steps: 0,
        stepGoal: 0,
      );
    }
    return Challenge(
      title: json['title'] as String? ?? '',
      daysDone: _toInt(json['days_done']),
      daysTotal: _toInt(json['days_total']),
      steps: _toInt(json['steps']),
      stepGoal: _toInt(json['step_goal']),
    );
  }

  static double _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  static int _toInt(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
}
```

---

## 4. Expected JSON

```json
{
  "profile": {
    "first_name": "John",
    "full_name": "John Doe",
    "email": "john.doe@example.com",
    "member_since": "2026-05-02"
  },
  "impact": {
    "week": {
      "co2_saved_kg": 2.4,
      "goal_kg": 3.5,
      "values": [0.2, 0.45, 0.3, 0.55, 0.4, 0.1, 0.5],
      "labels": ["M", "T", "W", "T", "F", "S", "S"],
      "by_mode": { "Transit": 1.8, "Walking": 0.4, "Cycling": 0.2 },
      "green_km": 18.6,
      "driven_km": 4.2,
      "change_vs_previous": 0.38,
      "trips": 10
    },
    "month": { "...": "same shape, labels W1-W4" },
    "year":  { "...": "same shape, labels J-D" }
  },
  "lifetime": { "co2_saved_kg": 52, "total_trips": 148, "total_km": 412.7 },
  "pet": {
    "coins": 200,
    "happiness": 0.82,
    "energy": 0.64,
    "health": 0.95,
    "days_together": 38
  },
  "suggestions": [
    {
      "label": "Work",
      "mode": "Bus 150",
      "duration_minutes": 22,
      "co2_saved_kg": 0.8,
      "leave_at": "8:18am",
      "arrive_at": "8:40am"
    }
  ],
  "challenge": {
    "title": "Green Week Walk Challenge",
    "days_done": 4,
    "days_total": 7,
    "steps": 2000,
    "step_goal": 4000
  }
}
```

---

## 5. Rules the API must follow

**Send zero, never null.** Every numeric field defaults to `0` and every list to
empty. A missing field renders an empty state; a null in a non-nullable position
throws.

**`values` and `labels` must be the same length.** One bar per label. The chart
tolerates a mismatch but the axis will be wrong.

**Ratios are 0.0 to 1.0.** `happiness`, `energy` and `health` are fractions, not
percentages. The UI multiplies by 100.

**`change_vs_previous` is a signed fraction.** `0.38` is 38% more than the
previous period, `-0.12` is 12% less.

**`lifetime.co2_saved_kg` drives pet unlocks.** Thresholds are in
`lib/models/pet.dart`. Send a running total, never a per-period figure.

**Any set of ranges is acceptable.** Send only `week` and the Month and Year
tabs show an empty state rather than failing.

---

## 6. Testing without the API

```
flutter run --dart-define=EMPTY_DATA=true
```

Boots with every stat at zero, which is what a new user sees. Worth checking
before release: no crashes, no NaN, no blank charts.

To test with different figures, edit `_mock` in `user_data.dart` and hot reload.

---

## 7. Not covered here

These still hold their own data and are separate pieces of work:

- **Pet catalogue** — `lib/models/pet.dart`. Static, ten entries. Only the
  unlock thresholds interact with backend data.
- **Selected pet** — `PetController`, in memory. Needs persisting.
- **Appearance mode** — `lib/ui/app_theme.dart`, in memory. Add
  `shared_preferences` to keep it between launches.
- **Maps** — `lib/services/maps_config.dart` and `geo_service.dart`. Currently
  OpenStreetMap, Nominatim and OSRM, none of which need a key. Not suitable for
  production traffic; see the notes in `maps_config.dart`.
- **Bus routes** — `lib/services/gtfs_service.dart` reads a bundled GTFS file.
  Real transit routing needs `stops.txt`, `trips.txt`, `stop_times.txt` and
  `calendar.txt`, which are not in the repo.
