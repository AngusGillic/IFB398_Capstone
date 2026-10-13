import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../data/pet_data.dart';
import '../models/garden_catalogue.dart';
import '../models/pet.dart';
import '../models/pet_state.dart';
import '../models/pet_trip.dart';
import 'pet_api.dart';
import 'pet_repository.dart';

class LocalPetStore extends PetRepository {
  LocalPetStore({PetDatabase? database, DateTime Function()? clock})
    : _database = database ?? PetDatabase.instance,
      _clock = clock ?? DateTime.now;

  final PetDatabase _database;
  final DateTime Function() _clock;

  @override
  bool get local => true;

  static const _items = {
    'small_pot': {'price': 25, 'durable': true},
    'water': {'price': 5, 'durable': false},
    'fertiliser': {'price': 10, 'durable': false},
    'kennel': {'price': 50, 'durable': true},
  };
  static const _effects = {
    'water': {'health': 0.1, 'happiness': 0.05},
    'fertiliser': {'health': 0.2},
    'sunlight': {'energy': 0.15},
  };
  static const _decay = {'happiness': 0.02, 'energy': 0.04, 'health': 0.01};
  static const tripModes = ['Walking', 'Cycling', 'Public transport'];

  void _checkOwner(String owner) {
    if (owner.trim().isEmpty) {
      throw const PetApiException(
        'unauthorized',
        'Sign in to see your pets.',
        status: 401,
      );
    }
  }

  DateTime get _now => _clock().toUtc();
  String _date(DateTime date) => date.toUtc().toIso8601String();
  double _rounded(num value) => double.parse(value.toStringAsFixed(6));

  Map<String, dynamic> _newPet(DateTime now) => {
    'adopted_at': _date(now),
    'updated_at': _date(now),
    'happiness': 0.75,
    'energy': 0.65,
    'health': 0.8,
    'cooldowns': <String, dynamic>{},
  };

  Future<Map<String, dynamic>> _load(
    DatabaseExecutor db,
    String owner,
    DateTime now,
  ) async {
    var state = await _database.readPet(owner, executor: db);
    if (state == null) {
      state = {
        'selected_pet_id': 'puppy',
        'coins': 0,
        'inventory': <String, dynamic>{},
        'co2_saved_kg': 0.0,
        'version': 0,
        'pets': {'puppy': _newPet(now)},
      };
      await _database.writePet(owner, state, executor: db);
    } else if (!state.containsKey('pets')) {
      // The first SQLite helper stored API snapshots rather than full pet records.
      final old = PetState.fromJson(state);
      state = {
        'selected_pet_id': old.selectedPetId,
        'coins': old.stats.coins,
        'inventory': Map<String, dynamic>.from(old.inventory),
        'co2_saved_kg': old.co2SavedKg,
        'version': old.version,
        'pets': {
          old.selectedPetId: {
            'adopted_at': _date(old.adoptedAt),
            'updated_at': _date(old.serverTime ?? now),
            'happiness': old.stats.happiness,
            'energy': old.stats.energy,
            'health': old.stats.health,
            'cooldowns': old.cooldowns.map(
              (key, date) => MapEntry(key, _date(date)),
            ),
          },
        },
      };
      await _database.writePet(owner, state, executor: db);
    }
    return state;
  }

  Map<String, dynamic> _progress(Map<String, dynamic> state, DateTime now) {
    final updated = jsonDecode(jsonEncode(state)) as Map<String, dynamic>;
    final inventory = updated['inventory'] as Map<String, dynamic>;
    for (final raw in (updated['pets'] as Map<String, dynamic>).values) {
      final pet = raw as Map<String, dynamic>;
      final last = DateTime.parse(
        (pet['updated_at'] ?? pet['adopted_at']) as String,
      );
      final hours = (now.difference(last).inMilliseconds / 3600000).clamp(
        0.0,
        double.infinity,
      );
      for (final entry in _decay.entries) {
        var rate = entry.value;
        if (entry.key == 'happiness' &&
            (inventory['small_pot'] as num? ?? 0) > 0)
          rate /= 2;
        if (entry.key == 'energy' && (inventory['kennel'] as num? ?? 0) > 0)
          rate /= 2;
        pet[entry.key] = _rounded(
          ((pet[entry.key] as num) - hours * rate).clamp(0.0, 1.0),
        );
      }
      pet['updated_at'] = _date(now.isBefore(last) ? last : now);
    }
    return updated;
  }

  Map<String, dynamic> _snapshot(Map<String, dynamic> state, DateTime now) {
    final current = _progress(state, now);
    final pet =
        (current['pets'] as Map<String, dynamic>)[current['selected_pet_id']]
            as Map<String, dynamic>;
    final adopted = DateTime.parse(pet['adopted_at'] as String);
    return {
      'selected_pet_id': current['selected_pet_id'],
      'adopted_at': pet['adopted_at'],
      'pet': {
        'coins': current['coins'],
        'happiness': pet['happiness'],
        'energy': pet['energy'],
        'health': pet['health'],
        'days_together': now.difference(adopted).inDays.clamp(0, 1000000),
      },
      'inventory': current['inventory'],
      'co2_saved_kg': current['co2_saved_kg'],
      'version': current['version'],
      'server_time': _date(now),
      'cooldowns': Map<String, dynamic>.from(pet['cooldowns'] as Map)
        ..removeWhere(
          (_, until) => !DateTime.parse(until as String).isAfter(now),
        ),
    };
  }

  @override
  Future<PetState> fetch(String owner) async {
    _checkOwner(owner);
    final db = await _database.database;
    return db.transaction((tx) async {
      final now = _now;
      return PetState.fromJson(_snapshot(await _load(tx, owner, now), now));
    });
  }

  @override
  Future<GardenCatalogue> fetchCatalogue(String owner) async {
    _checkOwner(owner);
    final catalogue = {'items': _items, 'actions': _effects};
    await _database.writeCatalogue(catalogue);
    return GardenCatalogue.fromJson(catalogue);
  }

  @override
  Future<PetState> save(
    String owner,
    String operation,
    Map<String, dynamic> body,
  ) async {
    _checkOwner(owner);
    final field = switch (operation) {
      'selection' => 'pet_id',
      'purchases' => 'item_id',
      'actions' => 'action_id',
      'trips' => 'trip_id',
      _ => null,
    };
    final keys = {
      field,
      'version',
      'request_id',
      if (operation == 'trips') ...['mode', 'saved_kg'],
    };
    if (field == null ||
        body.length != keys.length ||
        !keys.containsAll(body.keys) ||
        body[field] is! String ||
        body['version'] is! int ||
        (body['version'] as int) < 0 ||
        body['request_id'] is! String ||
        !RegExp(
          r'^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
        ).hasMatch(body['request_id'] as String)) {
      throw const PetApiException(
        'invalid_body',
        'Invalid pet request.',
        status: 400,
      );
    }
    if (operation == 'trips') _validateTrip(body);
    final db = await _database.database;
    return db.transaction((tx) async {
      final requestId = (body['request_id'] as String).toLowerCase();
      final sortedBody = {
        for (final key in (body.keys.toList()..sort())) key: body[key],
      };
      final payload = jsonEncode(sortedBody);
      final previous = await tx.query(
        'pet_requests',
        where: 'owner_id = ? AND request_id = ?',
        whereArgs: [owner, requestId],
        limit: 1,
      );
      if (previous.isNotEmpty) {
        final row = previous.first;
        if (row['operation'] != operation || row['body_json'] != payload) {
          throw const PetApiException(
            'request_conflict',
            'Request ID was already used.',
            status: 409,
          );
        }
        return PetState.fromJson(
          jsonDecode(row['result_json'] as String) as Map<String, dynamic>,
        );
      }
      final now = _now;
      final state = await _load(tx, owner, now);
      if (state['version'] != body['version']) {
        throw const PetApiException(
          'stale_version',
          'Your pet changed. Please try again.',
          status: 409,
        );
      }
      final updated = _progress(state, now);
      if (operation == 'trips') {
        await _creditTrip(tx, owner, updated, body, now);
      } else {
        _apply(updated, operation, body[field] as String, now);
      }
      updated['version'] = (state['version'] as int) + 1;
      final result = _snapshot(updated, now);
      await _database.writePet(owner, updated, executor: tx);
      await tx.insert('pet_requests', {
        'owner_id': owner,
        'request_id': requestId,
        'operation': operation,
        'body_json': payload,
        'result_json': jsonEncode(result),
      });
      return PetState.fromJson(result);
    });
  }

  void _apply(
    Map<String, dynamic> state,
    String operation,
    String id,
    DateTime now,
  ) {
    final inventory = state['inventory'] as Map<String, dynamic>;
    final pets = state['pets'] as Map<String, dynamic>;
    if (operation == 'selection') {
      final matches = PetCatalogue.all.where((pet) => pet.id == id);
      if (matches.isEmpty)
        throw const PetApiException('unknown_pet', 'Unknown pet.', status: 400);
      if (!matches.first.isUnlockedAt(
        (state['co2_saved_kg'] as num).toDouble(),
      )) {
        throw const PetApiException(
          'pet_locked',
          'This pet is still locked.',
          status: 422,
        );
      }
      pets.putIfAbsent(id, () => _newPet(now));
      state['selected_pet_id'] = id;
      return;
    }
    if (operation == 'purchases') {
      final item = _items[id];
      if (item == null)
        throw const PetApiException(
          'unknown_item',
          'Unknown garden item.',
          status: 400,
        );
      final quantity = inventory[id] as int? ?? 0;
      if (item['durable'] == true && quantity > 0) {
        throw const PetApiException(
          'already_owned',
          'You already own this item.',
          status: 422,
        );
      }
      final price = item['price'] as int;
      if ((state['coins'] as int) < price) {
        throw const PetApiException(
          'insufficient_coins',
          'Not enough coins.',
          status: 422,
        );
      }
      state['coins'] = (state['coins'] as int) - price;
      inventory[id] = quantity + 1;
      return;
    }
    final effects = _effects[id];
    if (effects == null)
      throw const PetApiException(
        'unknown_action',
        'Unknown care action.',
        status: 400,
      );
    final pet = pets[state['selected_pet_id']] as Map<String, dynamic>;
    final cooldowns = pet['cooldowns'] as Map<String, dynamic>;
    if (cooldowns[id] != null &&
        DateTime.parse(cooldowns[id] as String).isAfter(now)) {
      throw const PetApiException(
        'cooldown',
        'This action is not ready yet.',
        status: 422,
      );
    }
    if (effects.keys.every((stat) => (pet[stat] as num) >= 1)) {
      throw const PetApiException(
        'care_not_needed',
        'Your pet does not need this care yet.',
        status: 422,
      );
    }
    if (id != 'sunlight') {
      final quantity = inventory[id] as int? ?? 0;
      if (quantity == 0)
        throw const PetApiException(
          'missing_inventory',
          'Buy this item first.',
          status: 422,
        );
      inventory[id] = quantity - 1;
    }
    for (final entry in effects.entries) {
      pet[entry.key] = _rounded(
        ((pet[entry.key] as num) + entry.value).clamp(0.0, 1.0),
      );
    }
    if (id == 'sunlight')
      cooldowns[id] = _date(now.add(const Duration(hours: 1)));
  }

  void _validateTrip(Map<String, dynamic> body) {
    final saving = body['saved_kg'];
    final id = body['trip_id'] as String;
    if (id.trim().isEmpty ||
        id.length > 128 ||
        saving is! num ||
        !saving.isFinite ||
        saving <= 0 ||
        saving > 1000 ||
        !tripModes.contains(body['mode'])) {
      throw const PetApiException(
        'invalid_trip',
        'Choose a valid trip and carbon saving.',
        status: 400,
      );
    }
  }

  Future<void> _creditTrip(
    DatabaseExecutor tx,
    String owner,
    Map<String, dynamic> state,
    Map<String, dynamic> body,
    DateTime now,
  ) async {
    final saving = body['saved_kg'] as num;
    final tripId = body['trip_id'] as String;
    final previous = await tx.query(
      'pet_trips',
      where: 'owner_id = ? AND trip_id = ?',
      whereArgs: [owner, tripId],
      limit: 1,
    );
    if (previous.isNotEmpty) {
      throw const PetApiException(
        'trip_already_recorded',
        'This trip has already been recorded.',
        status: 422,
      );
    }
    final coins = (saving * 10).floor();
    await tx.insert('pet_trips', {
      'owner_id': owner,
      'trip_id': tripId,
      'mode': body['mode'],
      'saved_kg': saving,
      'coins': coins,
      'completed_at': _date(now),
    });
    state['coins'] = (state['coins'] as int) + coins;
    state['co2_saved_kg'] = _rounded((state['co2_saved_kg'] as num) + saving);
  }

  @override
  Future<List<PetTrip>> trips(String owner) async {
    _checkOwner(owner);
    final db = await _database.database;
    final rows = await db.query(
      'pet_trips',
      where: 'owner_id = ?',
      whereArgs: [owner],
      orderBy: 'completed_at DESC, rowid DESC',
    );
    return rows.map(PetTrip.fromRow).toList();
  }
}
