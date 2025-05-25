import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'meu_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        id TEXT PRIMARY KEY,
        title TEXT,
        genre TEXT,
        year TEXT,
        isFavorite INTEGER
      )
    ''');
  }

  Future<int> insertMovie(String id, String title, String year, String genre,
      bool isFavorite) async {
    final db = await database;
    return await db.insert('movies', {
      'id': id,
      'title': title,
      'genre': genre,
      'year': year,
      'isFavorite': isFavorite ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllMovies() async {
    final db = await database;
    return await db.query('movies');
  }

  Future<Map<String, dynamic>?> getMovieById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('movies', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> deleteMovie(String id) async {
    final db = await database;
    await db.delete('movies', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateFavorite(String id) async {
    final db = await database;

    final movie = await getMovieById(id);
    if (movie == null) return;

    final isFavorite = movie['isFavorite'] == 1 ? false : true;

    await db.update('movies', {'isFavorite': isFavorite ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateMovie(
      String id, String title, String genre, String year) async {
    final db = await database;
    await db.update(
        'movies',
        {
          'title': title,
          'genre': genre,
          'year': year,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }
}
