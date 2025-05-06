import 'package:flutter/material.dart';
import 'package:projeto_flutter/ui/view/watch_list_view.dart';
import 'package:projeto_flutter/ui/view/watched_movies_view.dart';

class LibrariesView extends StatelessWidget {
  const LibrariesView({super.key});

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
            WatchListView(),
            WatchedMoviesListView(),
          ],
        ),
      ),
    );
  }
}
