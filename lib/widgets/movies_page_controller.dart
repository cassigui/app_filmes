import 'package:flutter/material.dart';
import 'package:projeto_flutter/pages/favorite_page.dart';
import 'package:projeto_flutter/pages/movie_list_page.dart';

class MoviesPageController extends StatelessWidget {
  const MoviesPageController({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de Filmes'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Todos'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MovieListPage(),
            FavoriteMoviesPage(),
          ],
        ),
      ),
    );
  }
}