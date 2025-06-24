import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:projeto_flutter/ui/view/home_view.dart';
import 'package:projeto_flutter/ui/view/login_view.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthCheckWidget extends StatefulWidget {
  const AuthCheckWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheckWidget> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthenticatedByBiometrics = false;
  bool _isLoadingBiometrics = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricsAndAuthenticate();
  }

  Future<void> _checkBiometricsAndAuthenticate() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print('Erro ao verificar biometria: $e');
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoading &&
        authService.user != null &&
        _canCheckBiometrics) {
      await _authenticateWithBiometrics();
    } else {
      setState(() {
        _isLoadingBiometrics = false;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Por favor, autentique-se para acessar o aplicativo.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Erro de autenticação biométrica: $e');
      authenticated = false;
    }

    if (!mounted) return;

    setState(() {
      _isAuthenticatedByBiometrics = authenticated;
      _isLoadingBiometrics = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isLoading || _isLoadingBiometrics) {
      return loading();
    }

    if (authService.user == null ||
        (_canCheckBiometrics && !_isAuthenticatedByBiometrics)) {
      return const LoginView();
    }

    return const HomeView();
  }

  Widget loading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
