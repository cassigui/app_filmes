import 'package:flutter/material.dart';
import 'package:projeto_flutter/ui/viewmodels/library_movie_view_model.dart';
import 'package:projeto_flutter/ui/viewmodels/movie_view_model.dart';
import 'package:projeto_flutter/ui/widgets/app_widget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MovieViewModel>(create: (_) => MovieViewModel()),
        ChangeNotifierProvider<LibraryMovieRepositoryMemory>(
            create: (_) => LibraryMovieRepositoryMemory())
      ],
      child: const AppWidget(),
    ),
  );
}
