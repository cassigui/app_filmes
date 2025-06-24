import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = true;

  static const String _userEmailKey = 'userEmail';
  static const String _userPasswordKey = 'userPassword';

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      user = firebaseUser;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userPasswordKey, password);
  }

  Future<Map<String, String?>> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_userEmailKey);
    final password = prefs.getString(_userPasswordKey);
    return {'email': email, 'password': password};
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPasswordKey);
  }

  login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveCredentials(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Usuário não encontrado');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta');
      } else if (e.code == 'invalid-email') {
        throw AuthException('Email inválido');
      } else if (e.code == 'invalid-credential') {
        throw AuthException(
            'Credenciais inválidas. Verifique o e-mail e a senha.');
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
      await _saveCredentials(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('Senha muito fraca');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Email já cadastrado');
      } else if (e.code == 'invalid-email') {
        throw AuthException('Email inválido');
      } else {
        throw AuthException(e.message ?? 'Erro desconhecido');
      }
    }
  }

  Future<void> loginWithBiometricsSuccess() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final credentials = await _loadCredentials();
    final email = credentials['email'];
    final password = credentials['password'];

    if (email != null && password != null) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } on FirebaseAuthException catch (e) {
        print('Erro ao tentar re-logar com credenciais salvas: $e');
        await _clearCredentials();
        throw AuthException(
            'Não foi possível re-autenticar o usuário. Faça login manualmente.');
      }
    } else {
      throw AuthException(
          'Nenhuma credencial salva para autenticação biométrica.');
    }

    user = _auth.currentUser;

    if (user == null) {
      throw AuthException(
          'Não há usuário logado após a autenticação biométrica.');
    }

    isLoading = false;
    notifyListeners();
  }

  logout() async {
    await _auth.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
