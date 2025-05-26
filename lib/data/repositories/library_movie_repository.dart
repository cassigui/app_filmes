import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/database/db.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:projeto_flutter/domain/models/library_movie.dart';
import 'package:projeto_flutter/domain/models/movie.dart';
import 'package:sqflite/sqflite.dart';

class LibraryMovieRepository extends ChangeNotifier{
  late Database db;
  late AuthService auth;
  List<LibraryMovie> _watchedMovies = [];
  List<LibraryMovie> _watchlistMovies = [];

  List<LibraryMovie> get watchedMovies => _watchedMovies;
  List<LibraryMovie> get watchlistMovies => _watchlistMovies;

  LibraryMovieRepository({required this.auth}) {
    _initRepository();
  }

  _initRepository() async {
    await _getWatchedMovies();
    await _getWatchlistMovies();
  }

  _getWatchedMovies() async {
    _watchedMovies = [];
    db = await DB.instance.database;
    final result = await db.rawQuery('''
      SELECT m.* FROM movies m
      INNER JOIN library_movies l ON m.id = l.movie_id
      WHERE l.user_id = ? AND l.isWatched = 1
    ''', [auth.user!.uid]);

    _watchedMovies = result.map((map) => LibraryMovie(movie: Movie.fromMap(map), isWatched: true)).toList();
    notifyListeners();
  }

  _getWatchlistMovies() async {
    _watchlistMovies = [];
    db = await DB.instance.database;
    final result = await db.rawQuery('''
      SELECT m.* FROM movies m
      INNER JOIN library_movies l ON m.id = l.movie_id
      WHERE l.user_id = ? AND l.isWatched = 0
    ''', [auth.user!.uid]);
    _watchlistMovies = result.map((map) => LibraryMovie(movie: Movie.fromMap(map), isWatched: false)).toList();
    notifyListeners();
  }

  Future<void> ensureLoaded() async {
    if (_watchedMovies.isEmpty && _watchlistMovies.isEmpty) {
      await _initRepository();
    }
  }

  Future<void> loadMovies() async {
    await _initRepository();
  }

  Future<bool> checkMovieIsInLibrary(String movieId) async {
    db = await DB.instance.database;
    final result = await db.query(
      'library_movies',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [auth.user!.uid, movieId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> addMovieToLibrary(Movie movie) async {
    db = await DB.instance.database;
    await db.insert(
      'library_movies',
      {
        'user_id': auth.user!.uid,
        'movie_id': movie.id,
        'isWatched': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _initRepository();
  }

  Future<void> toggleLibraryMovieWatchStatus(String movieId) async {
    db = await DB.instance.database;

    final result = await db.query(
      'library_movies',
      columns: ['isWatched'],
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [auth.user!.uid, movieId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final currentStatus = result.first['isWatched'] as int;
      final newStatus = currentStatus == 1 ? 0 : 1;

      await db.update(
        'library_movies',
        {'isWatched': newStatus},
        where: 'user_id = ? AND movie_id = ?',
        whereArgs: [auth.user!.uid, movieId],
      );
      await _initRepository();
    }
  }

  Future<void> removeMovieFromLibrary(String movieId) async {
    db = await DB.instance.database;
    await db.delete(
      'library_movies',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [auth.user!.uid, movieId],
    );
    await _initRepository();
  }
}