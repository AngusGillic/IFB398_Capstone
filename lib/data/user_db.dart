import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import '../data/user_data.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._constructor();

  // final String _tasksTableName = "users";
  static Database? _db;

  UserDatabase._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "travelly_db.db");
    return openDatabase(
      databasePath,
      version: 1,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile (
            user_id TEXT PRIMARY KEY NOT NULL,
            full_name TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE impact_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            period TEXT NOT NULL
              CHECK (period IN ('week', 'month', 'year')),
            co2_saved_kg REAL NOT NULL DEFAULT 0,
            goal_kg REAL NOT NULL DEFAULT 0,
            green_km REAL NOT NULL DEFAULT 0,
            driven_km REAL NOT NULL DEFAULT 0,
            change_vs_previous REAL NOT NULL DEFAULT 0,
            trips INTEGER NOT NULL DEFAULT 0,

            FOREIGN KEY (user_id)
              REFERENCES user_profile(user_id)
              ON DELETE CASCADE,

            UNIQUE (user_id, period)
          )
        ''');

        await db.execute('''
          CREATE TABLE impact_chart_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            impact_id INTEGER NOT NULL,
            position INTEGER NOT NULL,
            label TEXT NOT NULL,
            value REAL NOT NULL DEFAULT 0,

            FOREIGN KEY (impact_id)
              REFERENCES impact_stats(id)
              ON DELETE CASCADE,

            UNIQUE (impact_id, position)
          )
        ''');

        await db.execute('''
          CREATE TABLE impact_by_mode (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            impact_id INTEGER NOT NULL,
            transport_mode TEXT NOT NULL,
            co2_saved_kg REAL NOT NULL DEFAULT 0,

            FOREIGN KEY (impact_id)
              REFERENCES impact_stats(id)
              ON DELETE CASCADE,

            UNIQUE (impact_id, transport_mode)
          )
        ''');

        await db.execute('''
          CREATE TABLE lifetime_stats (
            user_id TEXT PRIMARY KEY NOT NULL,
            co2_saved_kg REAL NOT NULL DEFAULT 0,
            total_trips INTEGER NOT NULL DEFAULT 0,
            total_km REAL NOT NULL DEFAULT 0,

            FOREIGN KEY (user_id)
              REFERENCES user_profile(user_id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE pet_status (
            user_id TEXT PRIMARY KEY NOT NULL,
            coins INTEGER NOT NULL DEFAULT 0,
            happiness REAL NOT NULL DEFAULT 1.0
              CHECK (happiness BETWEEN 0 AND 1),
            energy REAL NOT NULL DEFAULT 1.0
              CHECK (energy BETWEEN 0 AND 1),
            health REAL NOT NULL DEFAULT 1.0
              CHECK (health BETWEEN 0 AND 1),
            days_together INTEGER NOT NULL DEFAULT 0,

            FOREIGN KEY (user_id)
              REFERENCES user_profile(user_id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE travel_suggestions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            label TEXT NOT NULL,
            mode TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL,
            co2_saved_kg REAL NOT NULL DEFAULT 0,
            leave_at TEXT NOT NULL,
            arrive_at TEXT NOT NULL,

            FOREIGN KEY (user_id)
              REFERENCES user_profile(user_id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE challenges (
            user_id TEXT PRIMARY KEY NOT NULL,
            title TEXT NOT NULL,
            days_done INTEGER NOT NULL DEFAULT 0,
            days_total INTEGER NOT NULL DEFAULT 0,
            steps INTEGER NOT NULL DEFAULT 0,
            step_goal INTEGER NOT NULL DEFAULT 0,

            FOREIGN KEY (user_id)
              REFERENCES user_profile(user_id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE trips (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            transport_mode TEXT NOT NULL,
            co2_saved_kg REAL NOT NULL,
            coins_earned INTEGER NOT NULL DEFAULT 0,
            trip_date TEXT NOT NULL,

            FOREIGN KEY (user_id)
              REFERENCES user_profile(user_id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> saveProfile({
    required String userId,
    required String fullName,
    required String email,
  }) async {
    final db = await database;

    // 1. Search for an existing user.
    final existingUser = await db.query(
      'user_profile',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (existingUser.isEmpty) {
      // 2. User doesn't exist: insert a new profile.
      await db.insert('user_profile', {
        'user_id': userId,
        'full_name': fullName,
        'email': email,
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      print('New user profile created.');
    } else {
      print('This user already exists in the database');
    }
  }

  // void addData(String content) async {
  //   final db = await database;
  //   await db.insert("user_profile", {

  //   });
  // }

  // Future<int> insertTrip({
  //   required String userId,
  //   required String transportMode,
  //   String? startLocation,
  //   String? endLocation,
  //   required double distanceKm,
  //   required int durationMinutes,
  //   required double co2SavedKg,
  //   required DateTime tripDate,
  // }) async {
  //   final db = await database;

  //   final now = DateTime.now();

  //   return await db.insert('trips', {
  //     'user_id': userId,
  //     'transport_mode': transportMode,
  //     'start_location': startLocation,
  //     'end_location': endLocation,
  //     'distance_km': distanceKm,
  //     'duration_minutes': durationMinutes,
  //     'co2_saved_kg': co2SavedKg,
  //     'trip_date': tripDate.toIso8601String(),
  //     'created_at': now.toIso8601String(),
  //   });
  // }

  Future<void> saveRecordedTrip({
    required String? userId,
    // required String tripId,
    required String transportMode,
    required double co2SavedKg,
    required int coinsEarned,
    required DateTime tripDate,
    required double distanceKm,
    required int durationMinutes,
  }) async {
    final db = await database;
    double greenKm = 0.0;
    double drivenKm = 0.0;
    double changeVsPrevious = 0.0;

    if (transportMode == "Drive") {
      drivenKm = distanceKm;
    } else {
      greenKm = distanceKm;
    }

    await db.insert('trips', {
      'user_id': userId,
      'transport_mode': transportMode,
      'co2_saved_kg': co2SavedKg,
      'coins_earned': coinsEarned,
      'trip_date': tripDate.toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

// Weekly trip data insert
    await db.rawInsert(
      '''
  INSERT INTO impact_stats (user_id, period, co2_saved_kg, goal_kg, green_km, driven_km, change_vs_previous, trips)
  VALUES (?, ?, ?, ?, ?, ?, ?, 1)
  ON CONFLICT(user_id, period) DO UPDATE SET
    co2_saved_kg = impact_stats.co2_saved_kg + excluded.co2_saved_kg,
    green_km = impact_stats.green_km + excluded.green_km,
    driven_km = impact_stats.driven_km + excluded.driven_km,
    change_vs_previous = impact_stats.change_vs_previous + excluded.change_vs_previous,
    trips = impact_stats.trips + 1
''',
      [userId, 'week', co2SavedKg, 15, greenKm, drivenKm, changeVsPrevious],
    );

// Monthly trip data insert
    await db.rawInsert(
      '''
  INSERT INTO impact_stats (user_id, period, co2_saved_kg, goal_kg, green_km, driven_km, change_vs_previous, trips)
  VALUES (?, ?, ?, ?, ?, ?, ?, 1)
  ON CONFLICT(user_id, period) DO UPDATE SET
    co2_saved_kg = impact_stats.co2_saved_kg + excluded.co2_saved_kg,
    green_km = impact_stats.green_km + excluded.green_km,
    driven_km = impact_stats.driven_km + excluded.driven_km,
    change_vs_previous = impact_stats.change_vs_previous + excluded.change_vs_previous,
    trips = impact_stats.trips + 1
''',
      [userId, 'month', co2SavedKg, 15 * 4, greenKm, drivenKm, changeVsPrevious],
    );

// Yearly Trip data insert
    await db.rawInsert(
      '''
  INSERT INTO impact_stats (user_id, period, co2_saved_kg, goal_kg, green_km, driven_km, change_vs_previous, trips)
  VALUES (?, ?, ?, ?, ?, ?, ?, 1)
  ON CONFLICT(user_id, period) DO UPDATE SET
    co2_saved_kg = impact_stats.co2_saved_kg + excluded.co2_saved_kg,
    green_km = impact_stats.green_km + excluded.green_km,
    driven_km = impact_stats.driven_km + excluded.driven_km,
    change_vs_previous = impact_stats.change_vs_previous + excluded.change_vs_previous,
    trips = impact_stats.trips + 1
''',
      [userId, 'year', co2SavedKg, 15 * 52 , greenKm, drivenKm, changeVsPrevious],
    );

    await db.rawInsert(
      '''
      INSERT INTO lifetime_stats (
        user_id,
        co2_saved_kg,
        total_trips,
        total_km
      )
      VALUES (?, ?, 1, ?)

      ON CONFLICT(user_id) DO UPDATE SET
        co2_saved_kg =
          lifetime_stats.co2_saved_kg + excluded.co2_saved_kg,
        total_trips = lifetime_stats.total_trips + 1,
        total_km =
          lifetime_stats.total_km + excluded.total_km
      ''',
      [userId, co2SavedKg, distanceKm],
    );
  }

  // Future<List<Map<String, dynamic>>> getTrips({
  //   required String userId,
  // });

  Future<Map<String, dynamic>> fetchUserData({required String? userId}) async {
    final db = await database;

    try {
      // 1. Fetch the user's profile.
      final profileResults = await db.query(
        'user_profile',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      final profile = profileResults.isNotEmpty
          ? profileResults.first
          : <String, dynamic>{};

      // 2. Fetch weekly, monthly, and yearly impact statistics.
      final Map<String, dynamic> impact = {};

      for (final period in ['week', 'month', 'year']) {
        // Fetch the main statistics for this period.
        final impactResults = await db.query(
          'impact_stats',
          where: 'user_id = ? AND period = ?',
          whereArgs: [userId, period],
          limit: 1,
        );

        if (impactResults.isEmpty) {
          impact[period] = null;
          continue;
        }

        final impactRow = impactResults.first;
        final impactId = impactRow['id'] as int;

        // Fetch the chart values for this period.
        final chartResults = await db.query(
          'impact_chart_data',
          where: 'impact_id = ?',
          whereArgs: [impactId],
          orderBy: 'position ASC',
        );

        // Fetch the CO2 savings breakdown by transport mode.
        final modeResults = await db.query(
          'impact_by_mode',
          where: 'impact_id = ?',
          whereArgs: [impactId],
        );

        // Reconstruct the values and labels expected by _series().
        final values = chartResults.map((row) => row['value']).toList();

        final labels = chartResults.map((row) => row['label']).toList();

        // Reconstruct the by_mode map.
        final Map<String, dynamic> byMode = {
          for (final row in modeResults)
            row['transport_mode'] as String: row['co2_saved_kg'],
        };

        impact[period] = {
          'co2_saved_kg': impactRow['co2_saved_kg'],
          'goal_kg': impactRow['goal_kg'],
          'values': values,
          'labels': labels,
          'by_mode': byMode,
          'green_km': impactRow['green_km'],
          'driven_km': impactRow['driven_km'],
          'change_vs_previous': impactRow['change_vs_previous'],
          'trips': impactRow['trips'],
        };
      }

      // 3. Fetch lifetime statistics.
      final lifetimeResults = await db.query(
        'lifetime_stats',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      final lifetime = lifetimeResults.isNotEmpty
          ? {
              'co2_saved_kg': lifetimeResults.first['co2_saved_kg'],
              'total_trips': lifetimeResults.first['total_trips'],
              'total_km': lifetimeResults.first['total_km'],
            }
          : <String, dynamic>{};

      // 4. Fetch pet statistics.
      final petResults = await db.query(
        'pet_status',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      final pet = petResults.isNotEmpty
          ? {
              'coins': petResults.first['coins'],
              'happiness': petResults.first['happiness'],
              'energy': petResults.first['energy'],
              'health': petResults.first['health'],
              'days_together': petResults.first['days_together'],
            }
          : <String, dynamic>{};

      // 5. Fetch travel suggestions.
      final suggestionResults = await db.query(
        'travel_suggestions',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'id ASC',
      );

      final suggestions = suggestionResults.map((row) {
        return {
          'label': row['label'],
          'mode': row['mode'],
          'duration_minutes': row['duration_minutes'],
          'co2_saved_kg': row['co2_saved_kg'],
          'leave_at': row['leave_at'],
          'arrive_at': row['arrive_at'],
        };
      }).toList();

      // 6. Fetch the user's challenge.
      final challengeResults = await db.query(
        'challenges',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      final challenge = challengeResults.isNotEmpty
          ? {
              'title': challengeResults.first['title'],
              'days_done': challengeResults.first['days_done'],
              'days_total': challengeResults.first['days_total'],
              'steps': challengeResults.first['steps'],
              'step_goal': challengeResults.first['step_goal'],
            }
          : null;

      // final Map<String, dynamic> userMap = {
      final Map<String, dynamic> userMap = {
        'profile': {
          // 'first_name': profile['first_name'] ?? '',
          'full_name': profile['full_name'] ?? '',
          'email': profile['email'] ?? '',
        },
        'impact': impact,
        'lifetime': lifetime,
        'pet': pet,
        'suggestions': suggestions,
        'challenge': challenge,
      };

      return userMap;

      // 8. Convert the map into your existing UserData model.
    } catch (error, stackTrace) {
      debugPrint("SQFLITE ERROR: ${error.toString()}");
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }

    // return {
    //   'profile': {'full_name': '', 'email': ''},
    //   'impact': <String, dynamic>{},
    //   'lifetime': <String, dynamic>{},
    //   'pet': <String, dynamic>{},
    //   'suggestions': <dynamic>[],
    //   'challenge': null,
    // };
  }
}
