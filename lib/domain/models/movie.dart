import 'dart:io';

class Movie {
  final String id;
  String name;
  String genre;
  String year;
  bool isFavorite;
  File? image;

  Movie({
    required this.id,
    required this.name,
    required this.genre,
    required this.year,
    this.isFavorite = false,
    this.image,
  });
}
