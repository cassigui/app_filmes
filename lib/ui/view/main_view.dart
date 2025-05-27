import 'package:flutter/material.dart';
import 'package:projeto_flutter/ui/view/favorite_view.dart';
import 'package:projeto_flutter/ui/view/movie_list_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

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
            FavoriteView(),
          ],
        ),
      ),
    );
  }
}
