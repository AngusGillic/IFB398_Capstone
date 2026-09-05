import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import '../data/user_data.dart';
import '../core/user_data_session.dart';

import '../services/username_mapper.dart';

class ApiClient {
  static const _base = 'https://api.travelly.example';
  static const _base2 =
      "https://9057i6cd5c.execute-api.ap-southeast-2.amazonaws.com/dev/trips";

  static Future<UserData> fetchUserData({String? token}) async {
    safePrint("1. Fetching data...");
    final results = await Amplify.Auth.getCurrentUser();

    String userId = results.userId;

    safePrint("2. Current logged in user: $userId");

    final response2 = await http.get(Uri.parse('$_base2?userId=$userId'));

    final decoded = jsonDecode(response2.body);
    // safePrint("Decode type: ${decoded.runtimeType}");
    // safePrint("Decoded data: $decoded");

    // safePrint("3. Status code = ${response2.statusCode}");
    // safePrint("4. JSON Body: ${response2.body}");

    // if (decoded is List) {
    //   safePrint("API returned a List");
    // } else if (decoded is Map<String, dynamic>) {
    //   safePrint("API returned a Map");
    // }

    // safePrint("5. JSON data turned into list");
    // if (response2.statusCode == 200) {
    //   final data = json.decode(response2.body) as List<dynamic>;
    //   safePrint(data.toList());
    // }

    final List<AuthUserAttribute> attributes = await Amplify.Auth.fetchUserAttributes();

    final email = attributes.firstWhere(
      (element) => element.userAttributeKey == CognitoUserAttributeKey.email,
      orElse:() => const AuthUserAttribute(
        userAttributeKey: CognitoUserAttributeKey.email, value: "n/a",
      ),
    );
      
    final String fullName;
    
    if (email != "n/a") {
      fullName = UsernameMapper.displayNameFrom(email.toString());      
    } else {
      fullName = "n/a";
    }

    Map<String, dynamic> userMap = {
      "profile": {
        "first_name": "ChocolateMandarin",
        "full_name": fullName,
        "email": (attributes.firstWhere(
          (element) => element.userAttributeKey == CognitoUserAttributeKey.email,
          orElse:() => const AuthUserAttribute(
            userAttributeKey: CognitoUserAttributeKey.email, value: "n/a",
          ),
        )).toString(),
        "member_since": "2026-03-27",
      },
      "impact": {
        "week": {
          "co2_saved_kg": 2.5,
          "goal_kg": 3.8,
          "values": [0.4, 0.50, 0.3, 0.77, 0.5, 0.2, 0.6],
          "labels": ["M", "T", "W", "T", "F", "S", "S"],
          "by_mode": {"Transit": 1.7, "Walking": 0.6, "Cycling": 0.1},
          "green_km": 19.3,
          "driven_km": 3.8,
          "change_vs_previous": 0.42,
          "trips": 8,
        },
        "month": {"...": "same shape, labels W1-W4"},
        "year": {"...": "same shape, labels J-D"},
      },
      "lifetime": {"co2_saved_kg": 62, "total_trips": 158, "total_km": 415.8},
      "pet": {
        "coins": 300,
        "happiness": 0.85,
        "energy": 0.65,
        "health": 0.93,
        "days_together": 42,
      },
      "suggestions": [
        {
          "label": "Work",
          "mode": "Bus 150",
          "duration_minutes": 30,
          "co2_saved_kg": 0.8,
          "leave_at": "8:20am",
          "arrive_at": "8:50am",
        },
      ],
      "challenge": {
        "title": "Green Week Walk Challenge",
        "days_done": 4,
        "days_total": 7,
        "steps": 2000,
        "step_goal": 10000,
      },
    };

    // return _parse(jsonDecode(response2.body) as Map<String, dynamic>);
    return _parse(userMap);
  }

  static UserData _parse(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final pet = json['pet'] as Map<String, dynamic>? ?? {};
    final lifetime = json['lifetime'] as Map<String, dynamic>? ?? {};

    return UserData(
      profile: LocalProfile(
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
          .map(
            (s) => SuggestedTrip(
              label: s['label'] as String? ?? '',
              mode: s['mode'] as String? ?? '',
              durationMinutes: _toInt(s['duration_minutes']),
              co2SavedKg: _toDouble(s['co2_saved_kg']),
              leaveAt: s['leave_at'] as String? ?? '',
              arriveAt: s['arrive_at'] as String? ?? '',
            ),
          )
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
      byMode: ((json['by_mode'] as Map?) ?? {}).map(
        (k, v) => MapEntry(k as String, _toDouble(v)),
      ),
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

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('$v') ?? 0;
}
