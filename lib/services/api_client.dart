import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:travelly_flutter_ios_style/data/user_db.dart';

import '../data/user_data.dart';
import '../core/user_data_session.dart';

import '../services/username_mapper.dart';

class ApiClient {

  static Future<UserData> fetchUserData({String? token}) async {
    safePrint("1. Fetching data...");
    final results = await Amplify.Auth.getCurrentUser();

    String userId = results.userId;

    safePrint("2. Current logged in user: $userId");

    final attributes = await Amplify.Auth.fetchUserAttributes();

    final email = attributes.firstWhere(
      (element) => element.userAttributeKey == CognitoUserAttributeKey.email,
      orElse:() => const AuthUserAttribute(
        userAttributeKey: CognitoUserAttributeKey.email, value: "n/a",
      ),
    );

    final String fullName;

    if (email != "n/a") {
      fullName = UsernameMapper.displayNameFrom(email.value);      
    } else {
      fullName = "n/a";
    }
    safePrint("email variable: ${fullName}");

    final UserDatabase _dbService = UserDatabase.instance;
    final String? userID = UserDataSession.boundUserId;
    final result = await _dbService.fetchUserData(userId: userID);
    
    print(result);
    // return _parse(userMap);
    return _parse(result);
  }

  static UserData _parse(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final pet = json['pet'] as Map<String, dynamic>? ?? {};
    final lifetime = json['lifetime'] as Map<String, dynamic>? ?? {};

    return UserData(
      profile: LocalProfile(
        // firstName: profile['first_name'] as String? ?? '',
        fullName: profile['full_name'] as String? ?? '',
        email: profile['email'] as String? ?? '',
        // memberSince:
        //     DateTime.tryParse(profile['member_since'] as String? ?? '') ??
        //     DateTime.now(),
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
