import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:projeto_flutter/constants.dart';
import 'package:projeto_flutter/domain/models/movie.dart';
import 'package:projeto_flutter/domain/models/user_api.dart';

class MovieRepository {
  Future<List<Movie>> getAllMovies() async {
    String url = '$baseApi/movie' ;

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return List.empty();

    final response = jsonDecode(resp.body) as List;
    return response.map((map) => Movie.fromMap(map)).toList();
  }

  Future<List<Movie>> getFavoriteMovies(String userId) async {
    final userFromApi = await _getUserFromApi(userId);
    if (userFromApi == null) return List.empty();

    List<String> favoriteMoviesIds = userFromApi.favoriteMoviesIds;

    final List<Future<http.Response>> futureMovies = [];
    for (var movieId in favoriteMoviesIds) {
      String movieUrl = '$baseApi/movie/$movieId';
      futureMovies.add(http.get(Uri.parse(movieUrl)));
    }
    final List<http.Response> results = await Future.wait(futureMovies);

    List<Movie> favoriteMovies = [];
    for (var i = 0; i < results.length; i++) {
      final movieResp = results[i];
      if (movieResp.statusCode == 200) {
        final movieResponse = movieResp.body;
        final movieMap = jsonDecode(movieResponse);
        final movie = Movie.fromMap(movieMap);
        favoriteMovies.add(movie);
      }
    }

    return favoriteMovies;
  }

  Future<Map<String, dynamic>?> getMovieById(String id) async {
    String url = '$baseApi/movie/$id' ;

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return null;

    return jsonDecode(resp.body);
  }

  Future<bool> checkMovieIsFavorite(String id, String userId) async {
    final userFromApi = await _getUserFromApi(userId);
    if (userFromApi == null) return false;

    List<String> favoriteMoviesIds = userFromApi.favoriteMoviesIds;

    return favoriteMoviesIds.contains(id);
  }

  Future<void> insertMovie(Movie movie) async {
    String url = '$baseApi/movie' ;

    await http.post(Uri.parse(url), body: {
      'title': movie.title,
      'genre': movie.genre,
      'year': movie.year,
    });
  }

  Future<void> deleteMovie(String id) async {
    String url = '$baseApi/movie/$id';

    await http.delete(Uri.parse(url));
  }

  Future<void> updateFavorite(String id, String userId) async {
    final userFromApi = await _getUserFromApi(userId);
    if (userFromApi == null) return;

    List<String> favoriteMoviesIds = userFromApi.favoriteMoviesIds;

    if (favoriteMoviesIds.contains(id)) {
      favoriteMoviesIds.remove(id);

      final url = Uri.parse('$baseApi/users/${userFromApi.id}');
      await http.put(url, body: {
        'uid': userFromApi.uid,
        'cpf': userFromApi.cpf,
        'birthdate': userFromApi.birthDate?.toIso8601String() ?? '',
        'favoriteMoviesIds': jsonEncode(favoriteMoviesIds),
        'watchedMoviesIds': jsonEncode(userFromApi.watchedMoviesIds),
        'toWatchMoviesIds': jsonEncode(userFromApi.toWatchMoviesIds),
      });
    } else {
      favoriteMoviesIds.add(id);

      final url = Uri.parse('$baseApi/users/${userFromApi.id}');
      await http.put(url, body: {
        'uid': userFromApi.uid,
        'cpf': userFromApi.cpf,
        'birthdate': userFromApi.birthDate?.toIso8601String() ?? '',
        'favoriteMoviesIds': jsonEncode(favoriteMoviesIds),
        'watchedMoviesIds': jsonEncode(userFromApi.watchedMoviesIds),
        'toWatchMoviesIds': jsonEncode(userFromApi.toWatchMoviesIds),
      });
    }
  }

  Future<void> updateMovie(
      String id, String title, String genre, String year) async {

    final url = Uri.parse('$baseApi/movie/$id');
    await http.put(url, body: {
      'title': title,
      'genre': genre,
      'year': year,
    });
  }

  Future<UserApi?> _getUserFromApi(String userId) async {
    String url = '$baseApi/users' ;

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return null;
    final userList = jsonDecode(resp.body) as List;
    UserApi? userFromApi;
    for (var userItem in userList) {
      if (userItem['uid'] == userId) {
        userFromApi = UserApi.fromJson(userItem);
        break;
      }
      userFromApi = null;
    }

    return userFromApi;
  }
}
