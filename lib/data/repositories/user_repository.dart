import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_flutter/constants.dart';
import 'package:projeto_flutter/domain/models/user.dart';
import 'package:projeto_flutter/domain/models/user_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository extends ChangeNotifier {

  Future<UserApi?> _getUserFromApi() async {
    final user = FirebaseAuth.instance.currentUser;
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

  Future<UserProfile?> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    String url = '$baseApi/users/${user.uid}' ;

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return null;

    final response = jsonDecode(resp.body);
    return UserProfile.fromMap(response);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final userFromApi = await _getUserFromApi();
    if (userFromApi == null) {
      String url = '$baseApi/users';

      await http.post(Uri.parse(url), body: {
        'uid': profile.uid,
        'cpf': profile.cpf,
        'birthdate': profile.birthDate?.toIso8601String() ?? '',
        'favoriteMoviesIds': jsonEncode(List.empty()),
        'watchedMoviesIds': jsonEncode(List.empty()),
        'toWatchMoviesIds': jsonEncode(List.empty()),
      });
      return;
    }
    String url = '$baseApi/users/${profile.uid}';

    await http.put(Uri.parse(url), body: {
      'uid': profile.uid,
      'cpf': profile.cpf,
      'birthdate': profile.birthDate?.toIso8601String() ?? '',
      'favoriteMoviesIds': jsonEncode(userFromApi.favoriteMoviesIds),
      'watchedMoviesIds': jsonEncode(userFromApi.watchedMoviesIds),
      'toWatchMoviesIds': jsonEncode(userFromApi.toWatchMoviesIds),
    });
  }

  Future<void> deleteUserProfile(String uid) async {
    String url = '$baseApi/users/$uid';

    await http.delete(Uri.parse(url));
  }
}
