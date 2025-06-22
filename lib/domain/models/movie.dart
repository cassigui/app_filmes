import 'dart:io';

class Movie {
  final String id;
  String title;
  String genre;
  String year;
  bool isFavorite;
  File? image;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    this.isFavorite = false,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': title,
      'genero': genre,
      'ano': year,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      genre: map['genre'] ?? '',
      year: map['year'] ?? '',
    );
  }
}
