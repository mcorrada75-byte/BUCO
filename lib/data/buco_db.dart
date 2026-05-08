import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/buco_record.dart';

/// Singleton di accesso al database SQLite locale.
class BucoDb {
  BucoDb._();
  static final BucoDb instance = BucoDb._();

  static const _dbName = 'buco.db';
  static const _table = 'buche';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, _dbName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            latitude REAL,
            longitude REAL,
            photos TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<BucoRecord>> all() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return rows.map(BucoRecord.fromMap).toList();
  }

  Future<BucoRecord?> findById(int id) async {
    final db = await database;
    final rows = await db.query(_table, where: 'id=?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return BucoRecord.fromMap(rows.first);
  }

  Future<int> insert(BucoRecord record) async {
    final db = await database;
    final map = record.toMap()..remove('id');
    return db.insert(_table, map);
  }

  Future<void> update(BucoRecord record) async {
    if (record.id == null) {
      throw ArgumentError('Impossibile aggiornare un record senza id');
    }
    final db = await database;
    await db.update(_table, record.toMap(),
        where: 'id=?', whereArgs: [record.id]);
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(_table, where: 'id=?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await database;
    final result =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $_table'));
    return result ?? 0;
  }
}
