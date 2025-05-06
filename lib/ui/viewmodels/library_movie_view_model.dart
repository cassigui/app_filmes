import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projeto_flutter/domain/models/library_movie.dart';
import 'package:projeto_flutter/domain/models/movie.dart';

abstract class LibraryMovieViewModel extends ChangeNotifier {
  List<LibraryMovie> get watchedMovies;
  List<LibraryMovie> get unwatchedMovies;

  bool checkMovieIsInLibrary(String movieId);
  void addMovieToLibrary(Movie movie);
  void updateMovieInfo(
      String id, String name, String genre, String year, File? image);
  void toggleLibraryMovieWatchStatus(String movieId);
  void removeMovieFromLibrary(String movieId);
}

class LibraryMovieRepositoryMemory extends ChangeNotifier
    implements LibraryMovieViewModel {
  final List<LibraryMovie> _libraryMovies = [];

  @override
  List<LibraryMovie> get watchedMovies =>
      _libraryMovies.where((m) => m.isWatched).toList();

  @override
  List<LibraryMovie> get unwatchedMovies =>
      _libraryMovies.where((m) => !m.isWatched).toList();

  @override
  bool checkMovieIsInLibrary(String movieId) {
    final index =
        _libraryMovies.indexWhere((lMovie) => lMovie.movie.id == movieId);

    return index != -1;
  }

  @override
  void addMovieToLibrary(Movie movie) {
    LibraryMovie libraryMovie = LibraryMovie(movie: movie);
    _libraryMovies.add(libraryMovie);
    notifyListeners();
  }

  @override
  void updateMovieInfo(
      String id, String name, String genre, String year, File? image) {
    final index = _libraryMovies.indexWhere((lMovie) => lMovie.movie.id == id);
    if (index != -1) {
      final movie =
          Movie(id: id, name: name, genre: genre, year: year, image: image);
      _libraryMovies[index].movie = movie;
      notifyListeners();
    }
  }

  @override
  void toggleLibraryMovieWatchStatus(String movieId) {
    int index =
        _libraryMovies.indexWhere((lMovie) => lMovie.movie.id == movieId);

    if (index != -1) {
      _libraryMovies[index].isWatched = !_libraryMovies[index].isWatched;
      notifyListeners();
    }
  }

  @override
  void removeMovieFromLibrary(String movieId) {
    _libraryMovies
        .removeWhere((libraryMovie) => libraryMovie.movie.id == movieId);
    notifyListeners();
  }
}
