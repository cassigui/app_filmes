import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/repositories/movie_repository.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:projeto_flutter/domain/models/movie.dart';
import 'package:uuid/uuid.dart';

class MovieViewModel extends ChangeNotifier {
  late AuthService auth;
  final MovieRepository _repository = MovieRepository();

  List<Movie> _movies = [];
  List<Movie> _favoriteMovies = [];

  List<Movie> get movies => _movies;
  List<Movie> get favoriteMovies => _favoriteMovies;

  MovieViewModel({required this.auth}) {
    loadMovies();
  }

  Future<void> loadMovies() async {
    _movies = await _repository.getAllMovies();
    _favoriteMovies = await _repository.getFavoriteMovies(auth.user!.uid);
    notifyListeners();
  }

  Future<bool> checkMovieIsFavorite(String id) async {
    return await _repository.checkMovieIsFavorite(id, auth.user!.uid);
  }

  Future<void> addMovie(
      String name, String genre, String year, File? image) async {
    final movie = Movie(
      id: const Uuid().v4(),
      title: name,
      genre: genre,
      year: year,
      image: image,
    );
    // _movies.add(movie);
    // notifyListeners();
    await _repository.insertMovie(movie);
    await loadMovies();
  }

  Future<void> removeMovie(String id) async {
    // _movies.removeWhere((movie) => movie.id == id);
    // notifyListeners();
    await _repository.deleteMovie(id);
    await loadMovies();
  }

  void editMovie(
      String id, String name, String genre, String year, File? image) async {
    // final index = _movies.indexWhere((movie) => movie.id == id);
    // if (index != -1) {
    //   _movies[index].title = name;
    //   _movies[index].genre = genre;
    //   _movies[index].year = year;
    //   _movies[index].image = image;
    //   notifyListeners();
    // }
    await _repository.updateMovie(id, name, genre, year);
    await loadMovies();
  }

  Future<void> toggleFavorite(String id) async {
    // final index = _movies.indexWhere((movie) => movie.id == id);
    // if (index != -1) {
    //   _movies[index].isFavorite = !_movies[index].isFavorite;
    //   notifyListeners();
    // }
    await _repository.updateFavorite(id, auth.user!.uid);
    await loadMovies();
  }
}
