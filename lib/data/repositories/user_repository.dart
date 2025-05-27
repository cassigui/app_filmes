import 'package:flutter/foundation.dart';
import 'package:projeto_flutter/domain/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_flutter/data/database/db.dart';

class UserRepository extends ChangeNotifier {
  Future<Database> get _db async => await DB.instance.database;

  Future<UserProfile?> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final db = await _db;

    final result = await db.query(
      'user_profile',
      where: 'uid = ?',
      whereArgs: [user.uid],
    );

    if (result.isNotEmpty) {
      return UserProfile.fromMap(result.first);
    }

    return null;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await _db;

    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteUserProfile(String uid) async {
    final db = await _db;

    await db.delete(
      'user_profile',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }
}
