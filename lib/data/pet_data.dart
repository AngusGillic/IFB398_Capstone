
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class PetDatabase {
  PetDatabase._();

  static final PetDatabase instance = PetDatabase._();

  static const String _databaseName = 'pets.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pets (
            owner_id TEXT PRIMARY KEY,
            pet_json TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE catalogues (
            catalogue_id TEXT PRIMARY KEY,
            catalogue_json TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<Map<String, dynamic>?> readPet(String owner) async {
    final db = await database;

    final rows = await db.query(
      'pets',
      columns: ['pet_json'],
      where: 'owner_id = ?',
      whereArgs: [owner],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return Map<String, dynamic>.from(
      jsonDecode(rows.first['pet_json'] as String) as Map,
    );
  }

  Future<void> writePet(
    String owner,
    Map<String, dynamic> petJson,
  ) async {
    final db = await database;

    await db.insert(
      'pets',
      {
        'owner_id': owner,
        'pet_json': jsonEncode(petJson),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> readCatalogue() async {
    final db = await database;

    final rows = await db.query(
      'catalogues',
      columns: ['catalogue_json'],
      where: 'catalogue_id = ?',
      whereArgs: ['default'],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return Map<String, dynamic>.from(
      jsonDecode(rows.first['catalogue_json'] as String) as Map,
    );
  }

  Future<void> writeCatalogue(
    Map<String, dynamic> catalogueJson,
  ) async {
    final db = await database;

    await db.insert(
      'catalogues',
      {
        'catalogue_id': 'default',
        'catalogue_json': jsonEncode(catalogueJson),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db == null) return;

    await db.close();
    _database = null;
  }
}
