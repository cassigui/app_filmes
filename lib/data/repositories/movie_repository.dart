import 'package:projeto_flutter/data/database/db.dart';
import 'package:projeto_flutter/domain/models/movie.dart';
import 'package:sqflite/sqflite.dart';

class MovieRepository {
  late Database db;

  Future<List<Movie>> getAllMovies() async {
    db = await DB.instance.database;
    final maps = await db.query('movies');
    return maps.map((map) => Movie.fromMap(map)).toList();
  }

  Future<List<Movie>> getFavoriteMovies(String userId) async {
    db = await DB.instance.database;

    final result = await db.rawQuery('''
      SELECT m.* FROM movies m
      INNER JOIN favorite_movies f ON m.id = f.movie_id
      WHERE f.user_id = ?
    ''', [userId]);

  return result.map((map) => Movie.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>?> getMovieById(String id) async {
    db = await DB.instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query('movies', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<bool> checkMovieIsFavorite(String id, String userId) async {
    db = await DB.instance.database;
    final result = await db.query(
      'favorite_movies',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, id],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> insertMovie(Movie movie) async {
    db = await DB.instance.database;
    await db.insert('movies', {
      'id': movie.id,
      'title': movie.title,
      'genre': movie.genre,
      'year': movie.year,
    });
  }

  Future<void> deleteMovie(String id) async {
    db = await DB.instance.database;
    await db.delete('movies', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateFavorite(String id, String userId) async {
    db = await DB.instance.database;
    
    final result = await db.query(
      'favorite_movies',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, id],
    );

    if (result.isNotEmpty) {
      await db.delete(
        'favorite_movies',
        where: 'user_id = ? AND movie_id = ?',
        whereArgs: [userId, id],
      );
    } else {
      await db.insert(
        'favorite_movies',
        {
          'user_id': userId,
          'movie_id': id,
        },
      );
    }
  }

  Future<void> updateMovie(
      String id, String title, String genre, String year) async {
    db = await DB.instance.database;
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
