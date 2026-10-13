import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class PetDatabase {
  PetDatabase({DatabaseFactory? factory, String? path})
    : _factory = factory,
      _path = path;

  static final PetDatabase instance = PetDatabase();

  final DatabaseFactory? _factory;
  final String? _path;
  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    try {
      final desktop = Platform.isWindows || Platform.isLinux;
      if (desktop && _factory == null) ffi.sqfliteFfiInit();
      final factory =
          _factory ?? (desktop ? ffi.databaseFactoryFfi : databaseFactory);
      final String path;
      if (_path != null) {
        path = _path;
      } else if (desktop) {
        final directory = await getApplicationSupportDirectory();
        await directory.create(recursive: true);
        path = p.join(directory.path, 'pets.db');
      } else {
        path = p.join(await factory.getDatabasesPath(), 'pets.db');
      }
      return await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE pets (owner_id TEXT PRIMARY KEY, pet_json TEXT NOT NULL)',
            );
            await db.execute(
              'CREATE TABLE catalogues (catalogue_id TEXT PRIMARY KEY, catalogue_json TEXT NOT NULL)',
            );
            await _createRecords(db);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) await _createRecords(db);
          },
        ),
      );
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  static Future<void> _createRecords(Database db) async {
    await db.execute("""
      CREATE TABLE pet_requests (
        owner_id TEXT NOT NULL,
        request_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        body_json TEXT NOT NULL,
        result_json TEXT NOT NULL,
        PRIMARY KEY (owner_id, request_id)
      )
    """);
    await db.execute("""
      CREATE TABLE pet_trips (
        owner_id TEXT NOT NULL,
        trip_id TEXT NOT NULL,
        mode TEXT NOT NULL,
        saved_kg REAL NOT NULL CHECK (saved_kg >= 0),
        coins INTEGER NOT NULL CHECK (coins >= 0),
        completed_at TEXT NOT NULL,
        PRIMARY KEY (owner_id, trip_id)
      )
    """);
  }

  Future<Map<String, dynamic>?> readPet(
    String owner, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await database;
    final rows = await db.query(
      'pets',
      columns: ['pet_json'],
      where: 'owner_id = ?',
      whereArgs: [owner],
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : jsonDecode(rows.first['pet_json'] as String) as Map<String, dynamic>;
  }

  Future<void> writePet(
    String owner,
    Map<String, dynamic> petJson, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await database;
    await db.insert('pets', {
      'owner_id': owner,
      'pet_json': jsonEncode(petJson),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> readCatalogue() async {
    final db = await database;
    final rows = await db.query(
      'catalogues',
      where: 'catalogue_id = ?',
      whereArgs: ['default'],
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : jsonDecode(rows.first['catalogue_json'] as String)
              as Map<String, dynamic>;
  }

  Future<void> writeCatalogue(Map<String, dynamic> catalogueJson) async {
    final db = await database;
    await db.insert('catalogues', {
      'catalogue_id': 'default',
      'catalogue_json': jsonEncode(catalogueJson),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async {
    final opening = _opening;
    if (opening == null) return;
    await (await opening).close();
    _opening = null;
  }
}
