import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projeto_flutter/models/movie.dart';
import 'package:uuid/uuid.dart';

class MovieProvider extends ChangeNotifier {
  final List<Movie> _movies = [];

  List<Movie> get movies => _movies;
  List<Movie> get favoriteMovies => _movies.where((m) => m.isFavorite).toList();

  void addMovie(String name, String genre, String year, File? image) {
    _movies.add(
      Movie(
        id: const Uuid().v4(),
        name: name,
        genre: genre,
        year: year,
        image: image,
      ),
    );
    notifyListeners();
  }

  void removeMovie(String id) {
    _movies.removeWhere((movie) => movie.id == id);
    notifyListeners();
  }

  void editMovie(
      String id, String name, String genre, String year, File? image) {
    final index = _movies.indexWhere((movie) => movie.id == id);
    if (index != -1) {
      _movies[index].name = name;
      _movies[index].genre = genre;
      _movies[index].year = year;
      _movies[index].image = image;
      notifyListeners();
    }
  }

  void toggleFavorite(String id) {
    final index = _movies.indexWhere((movie) => movie.id == id);
    if (index != -1) {
      _movies[index].isFavorite = !_movies[index].isFavorite;
      notifyListeners();
    }
  }
}
