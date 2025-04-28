import 'package:projeto_flutter/models/movie.dart';

class LibraryMovie {
  Movie movie;
  bool isWatched;

  LibraryMovie({required this.movie, this.isWatched = false});
}