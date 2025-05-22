import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:projeto_flutter/ui/viewmodels/library_movie_view_model.dart';
import 'package:projeto_flutter/ui/viewmodels/movie_view_model.dart';
import 'package:projeto_flutter/ui/widgets/app_widget.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<MovieViewModel>(create: (_) => MovieViewModel()),
        ChangeNotifierProvider<LibraryMovieRepositoryMemory>(
            create: (_) => LibraryMovieRepositoryMemory())
      ],
      child: const AppWidget(),
    ),
  );
}
