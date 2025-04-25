import 'package:flutter/material.dart';
import 'package:projeto_flutter/repositories/movie_provider.dart';
import 'package:projeto_flutter/widgets/app_widget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MovieProvider(),
      child: const MyApp(),
    ),
  );
}
