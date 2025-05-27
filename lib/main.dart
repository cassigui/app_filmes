import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/repositories/library_movie_repository.dart';
import 'package:projeto_flutter/data/repositories/user_repository.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:projeto_flutter/ui/viewmodels/movie_view_model.dart';
import 'package:projeto_flutter/ui/widgets/app_widget.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<UserRepository>(create: (context) => UserRepository()), // <--- aqui
        ChangeNotifierProvider<MovieViewModel>(
          create: (context) => MovieViewModel(
            auth: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<LibraryMovieRepository>(
          create: (context) => LibraryMovieRepository(
            auth: context.read<AuthService>(),
          ),
        ),
      ],
      child: const AppWidget(),
    ),
  );
}
