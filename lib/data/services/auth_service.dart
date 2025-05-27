import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      user = (user != null) ? user : null;
      isLoading = false;
      notifyListeners();
    });
  }

  getUser() {
    user = _auth.currentUser;
    notifyListeners();
  }

  login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Usuário não encontrado');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta');
      } else if (e.code == 'invalid-email') {
        throw AuthException('Email inválido');
      } else if (e.code == 'invalid-credential') {
        throw AuthException('Credenciais inválidas. Verifique o e-mail e a senha.');
      } else {
        throw AuthException(e.message ?? 'Erro desconhecido');
      }
    }
  }

  register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('Senha muito fraca');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Email já cadastrado');
      } else if (e.code == 'invalid-email') {
        throw AuthException('Email inválido');
      } else {
        throw AuthException('Erro desconhecido');
      }
    }
  }

  logout() async {
    await _auth.signOut();
    user = null;
    notifyListeners();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
