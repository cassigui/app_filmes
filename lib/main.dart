import 'package:flutter/material.dart';
import 'package:projeto_flutter/repositories/library_movie_repository.dart';
import 'package:projeto_flutter/repositories/movie_provider.dart';
import 'package:projeto_flutter/widgets/app_widget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MovieProvider>(
          create: (_) => MovieProvider()),
        ChangeNotifierProvider<LibraryMovieRepositoryMemory>(
          create: (_) => LibraryMovieRepositoryMemory())
      ],
      child: const MyApp(),
    ),
  );
}
