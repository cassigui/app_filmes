import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projeto_flutter/constants.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:projeto_flutter/domain/models/library_movie.dart';
import 'package:projeto_flutter/domain/models/movie.dart';
import 'package:projeto_flutter/domain/models/user_api.dart';

import 'package:http/http.dart' as http;

class LibraryMovieRepository extends ChangeNotifier{
  late AuthService auth;
  List<LibraryMovie> _watchedMovies = [];
  List<LibraryMovie> _watchlistMovies = [];

  List<LibraryMovie> get watchedMovies => _watchedMovies;
  List<LibraryMovie> get watchlistMovies => _watchlistMovies;

  LibraryMovieRepository({required this.auth}) {
    _getMovies();
  }

  _addToWatchedMovieList(watchedMovies) {
    _watchedMovies = [];

    for (var movie in watchedMovies) {
      _watchedMovies.add(LibraryMovie(movie: movie, isWatched: true));
    }

    notifyListeners();
  }

  _addToWatchList(unwatchedMovies) {
    _watchlistMovies = [];

    for (var movie in unwatchedMovies) {
      _watchlistMovies.add(LibraryMovie(movie: movie, isWatched: false));
    }

    notifyListeners();
  }

  _getMovies() async {
    final userFromApi = await _getUserFromApi();
    if (userFromApi == null) return;
    String url = '$baseApi/users/${userFromApi.id}';

    final resp = await http.get(Uri.parse(url));

    if (resp.statusCode != 200) return;

    final response = resp.body;
    final parsedResponse = jsonDecode(response);
    final List<String> watchedMoviesIds = List<String>.from(jsonDecode(parsedResponse['watchedMoviesIds']));
    final List<String> toWatchMovieIds = List<String>.from(jsonDecode(parsedResponse['toWatchMoviesIds']));
    var movieIds = [watchedMoviesIds, toWatchMovieIds].expand((x) => x).toList();
    Set<String> uniqueMovieIds = Set<String>.from(movieIds);

    final List<Future<http.Response>> futureMovies = [];
    for (var movieId in uniqueMovieIds) {
      String movieUrl = '$baseApi/movie/$movieId';
      futureMovies.add(http.get(Uri.parse(movieUrl)));
    }
    final List<http.Response> results = await Future.wait(futureMovies);

    final List<Movie> watchedMovies = [];
    final List<Movie> watchListMovies = [];
    for (var i = 0; i < results.length; i++) {
      final movieResp = results[i];
      if (movieResp.statusCode == 200) {
        final movieResponse = movieResp.body;
        final movieMap = jsonDecode(movieResponse);
        final movie = Movie.fromMap(movieMap);
        if (watchedMoviesIds.contains(movie.id)) {
          watchedMovies.add(movie);
        } else {
          watchListMovies.add(movie);
        }
      }
    }

    _addToWatchedMovieList(watchedMovies);
    _addToWatchList(watchListMovies);
  }

  Future<void> ensureLoaded() async {
    if (_watchedMovies.isEmpty && _watchlistMovies.isEmpty) {
      await _getMovies();
    }
  }

  Future<void> loadMovies() async {
    await _getMovies();
  }

  Future<bool> checkMovieIsInLibrary(String movieId) async {
    List<String> movieIds = [_watchlistMovies, _watchedMovies].expand((x) => x).map((lb) => lb.movie.id).toList();
    return movieIds.contains(movieId);
  }

  Future<void> addMovieToLibrary(Movie movie) async {
    final userFromApi = await _getUserFromApi();
    if (userFromApi == null) return;

    final List<String> toWatchMoviesIds = userFromApi.toWatchMoviesIds;
    toWatchMoviesIds.add(movie.id);

    final url = '$baseApi/users/${userFromApi.id}';
    final response = await http.put(Uri.parse(url), body: {
      'uid': userFromApi.uid,
      'cpf': userFromApi.cpf,
      'birthdate': userFromApi.birthDate?.toIso8601String() ?? '',
      'favoriteMoviesIds': jsonEncode(userFromApi.favoriteMoviesIds),
      'watchedMoviesIds': jsonEncode(userFromApi.watchedMoviesIds),
      'toWatchMoviesIds': jsonEncode(toWatchMoviesIds)
    });

    if (response.statusCode == 200) {
      await _getMovies();
    }
  }

  Future<void> toggleLibraryMovieWatchStatus(String movieId) async {
    List<String> movieIdsInLibrary = [_watchedMovies, _watchlistMovies].expand((x) => x).map((lb) => lb.movie.id).toList();

    if (!movieIdsInLibrary.contains(movieId)) return;

    final userFromApi = await _getUserFromApi();
    if (userFromApi == null) return;

    List<String> watchedMoviesIds = userFromApi.watchedMoviesIds;
    List<String> toWatchMoviesIds = userFromApi.toWatchMoviesIds;
    if (watchedMoviesIds.contains(movieId)) {
      watchedMoviesIds.remove(movieId);
      toWatchMoviesIds.add(movieId);
    } else {
      toWatchMoviesIds.remove(movieId);
      watchedMoviesIds.add(movieId);
    }

    final url = Uri.parse('$baseApi/users/${userFromApi.id}');
    final response = await http.put(url, body: {
      'uid': userFromApi.uid,
      'cpf': userFromApi.cpf,
      'birthdate': userFromApi.birthDate?.toIso8601String() ?? '',
      'favoriteMoviesIds': jsonEncode(userFromApi.favoriteMoviesIds),
      'watchedMoviesIds': jsonEncode(watchedMoviesIds),
      'toWatchMoviesIds': jsonEncode(toWatchMoviesIds),
    });

    if (response.statusCode == 200) {
      await _getMovies();
    }
  }

  Future<void> removeMovieFromLibrary(String movieId) async {
    List<String> movieIdsInLibrary = [_watchedMovies, _watchlistMovies].expand((x) => x).map((lb) => lb.movie.id).toList();

    if (!movieIdsInLibrary.contains(movieId)) return;

    final userFromApi = await _getUserFromApi();
    if (userFromApi == null) return;

    List<String> watchedMoviesIds = userFromApi.watchedMoviesIds;
    List<String> toWatchMoviesIds = userFromApi.toWatchMoviesIds;
    watchedMoviesIds.remove(movieId);
    toWatchMoviesIds.remove(movieId);

    final url = Uri.parse('$baseApi/users/${userFromApi.id}');
    final response = await http.put(url, body: {
      'uid': userFromApi.uid,
      'cpf': userFromApi.cpf,
      'birthdate': userFromApi.birthDate?.toIso8601String() ?? '',
      'favoriteMoviesIds': jsonEncode(userFromApi.favoriteMoviesIds),
      'watchedMoviesIds': jsonEncode(watchedMoviesIds),
      'toWatchMoviesIds': jsonEncode(toWatchMoviesIds),
    });

    if (response.statusCode == 200) {
      await _getMovies();
    }
  }

  Future<UserApi?> _getUserFromApi() async {
    final user = auth.user;
    if (user == null) return null;

    String url = '$baseApi/users' ;

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return null;
    final userList = jsonDecode(resp.body) as List;
    UserApi? userFromApi;
    for (var userItem in userList) {
      if (userItem['uid'] == user.uid) {
        userFromApi = UserApi.fromJson(userItem);
        break;
      }
      userFromApi = null;
    }

    return userFromApi;
  }
}