import 'package:projeto_flutter/domain/models/movie.dart';

class LibraryMovie {
  Movie movie;
  bool isWatched;

  LibraryMovie({required this.movie, this.isWatched = false});
}
