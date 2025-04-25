import 'package:flutter/material.dart';
import 'package:projeto_flutter/pages/main_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MainTabController(),
    );
  }
}
