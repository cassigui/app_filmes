import 'package:flutter/material.dart';
import 'package:projeto_flutter/ui/widgets/auth_check_widget.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Filmes',
      theme: ThemeData.dark().copyWith(
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Colors.deepPurple,
              secondary: Colors.deepPurpleAccent,
            ),
      ),
      home: const AuthCheckWidget(),
    );
  }
}
