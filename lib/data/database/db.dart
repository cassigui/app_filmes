import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  DB._();

  static final DB instance = DB._();

  static Database? _database;

  get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_filmes.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(_userProfile);
        }
      },
    );
  }

  _onCreate(db, versao) async {
    await db.execute(_movies);
    await db.execute(_libraryMovie);
    await db.execute(_favoriteMovies);
    await db.execute(_userProfile);
  }

  String get _movies => '''
    CREATE TABLE movies (
      id TEXT PRIMARY KEY,
      title TEXT,
      genre TEXT,
      year TEXT
    );
  ''';

  String get _libraryMovie => '''
    CREATE TABLE library_movies (
      user_id TEXT,
      movie_id TEXT,
      isWatched INTEGER CHECK (isWatched IN (0, 1)),
      PRIMARY KEY (user_id, movie_id),
      FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
    );
  ''';

  String get _favoriteMovies => '''
    CREATE TABLE favorite_movies (
      user_id TEXT,
      movie_id TEXT,
      PRIMARY KEY(user_id, movie_id),
      FOREIGN KEY(movie_id) REFERENCES movies(id) ON DELETE CASCADE
    );
  ''';

  String get _userProfile => '''
  CREATE TABLE user_profile (
    uid TEXT PRIMARY KEY,
    cpf TEXT,
    birthDate TEXT
  );
''';
}
