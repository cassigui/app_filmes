import 'package:projeto_flutter/data/services/database_service.dart';
import 'package:projeto_flutter/domain/models/movie.dart';

class MovieRepository {
  final _db = DatabaseService();

  Future<List<Movie>> getAllMovies() async {
    final maps = await _db.getAllMovies();
    return maps.map((map) => Movie.fromMap(map)).toList();
  }

  Future<void> insertMovie(Movie movie) async {
    await _db.insertMovie(
        movie.id, movie.title, movie.year, movie.genre, movie.isFavorite);
  }

  Future<void> deleteMovie(String id) async {
    await _db.deleteMovie(id);
  }

  Future<void> updateFavorite(String id) async {
    await _db.updateFavorite(id);
  }

  Future<void> updateMovie(
      String id, String title, String genre, String year) async {
    await _db.updateMovie(id, title, genre, year);
  }
}
