import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:projeto_flutter/ui/view/home_view.dart';
import 'package:projeto_flutter/ui/view/login_view.dart';
import 'package:provider/provider.dart';

class AuthCheckWidget extends StatefulWidget {
  const AuthCheckWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheckWidget> {
  bool _biometricChecked = false;
  bool _biometricSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!_biometricChecked && authService.user != null) {
      final authenticated = await authService.authenticateWithBiometrics();
      setState(() {
        _biometricChecked = true;
        _biometricSuccess = authenticated;
      });
      if (!authenticated) {
        await authService.logout();
      }
    } else if (!_biometricChecked) {
      setState(() {
        _biometricChecked = true;
        _biometricSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    if (authService.isLoading || !_biometricChecked) {
      return loading();
    }
    if (authService.user == null || !_biometricSuccess) {
      return const LoginView();
    }
    return const HomeView();
  }

  loading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
