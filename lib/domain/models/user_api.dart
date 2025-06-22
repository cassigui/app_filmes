import 'dart:convert';

class UserApi {
  final String id;
  final String uid;
  final String cpf;
  final DateTime? birthDate;
  final List<String> favoriteMoviesIds;
  final List<String> watchedMoviesIds;
  final List<String> toWatchMoviesIds;

  UserApi({required this.id,required this.uid, required this.cpf, this.birthDate, required this.favoriteMoviesIds, required this.watchedMoviesIds, required this.toWatchMoviesIds});

  factory UserApi.fromMap(Map<String, dynamic> map) {
    return UserApi(
      id: map['id'],
      uid: map['uid'],
      cpf: map['cpf'],
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
      favoriteMoviesIds: map['favoriteMoviesIds'] != null ? map['favoriteMoviesIds'] as List<String> : List.empty(),
      watchedMoviesIds: map['watchedMoviesIds'] != null ? map['watchedMoviesIds'] as List<String> : List.empty(),
      toWatchMoviesIds: map['toWatchMoviesIds'] != null ? map['toWatchMoviesIds'] as List<String> : List.empty(),
    );
  }

  factory UserApi.fromJson(Map<String, dynamic> map) {
    return UserApi(
      id: map['id'],
      uid: map['uid'],
      cpf: map['cpf'], 
      favoriteMoviesIds: List<String>.from(jsonDecode(map['favoriteMoviesIds'])), 
      watchedMoviesIds: List<String>.from(jsonDecode(map['watchedMoviesIds'])), 
      toWatchMoviesIds: List<String>.from(jsonDecode(map['toWatchMoviesIds'])),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'cpf': cpf,
        'birthDate': birthDate?.toIso8601String(),
        'favoriteMoviesIds': favoriteMoviesIds,
        'watchedMoviesIds': watchedMoviesIds,
        'toWatchMoviesIds': toWatchMoviesIds,
      };
}
