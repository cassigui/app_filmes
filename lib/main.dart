import 'package:flutter/material.dart';
import 'package:projeto_flutter/ui/viewmodels/movie_view_model.dart';
import 'package:projeto_flutter/ui/widgets/app_widget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MovieViewModel(),
      child: const AppWidget(),
    ),
  );
}
