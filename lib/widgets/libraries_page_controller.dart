import 'package:flutter/material.dart';
import 'package:projeto_flutter/pages/watch_list_page.dart';
import 'package:projeto_flutter/pages/watched_movies_page.dart';

class LibrariesPageController extends StatelessWidget {
  const LibrariesPageController({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Listas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.watch_later), text: 'Quero Assistir'),
              Tab(icon: Icon(Icons.playlist_add_check), text: 'Assistidos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WatchListPage(),
            WatchedMoviesListPage(),
          ],
        ),
      ),
    );
  }
}