import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/repositories/library_movie_repository.dart';
import 'package:provider/provider.dart';

class WatchListView extends StatefulWidget {
  const WatchListView({super.key});

  @override
  State<WatchListView> createState() => _WatchListViewState();
}

class _WatchListViewState extends State<WatchListView> {

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<LibraryMovieRepository>().watchlistMovies;

    return Scaffold(
      body: movies.isEmpty
        ? const Center(child: Text('Sua lista está vazia.'))
        : ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final libraryMovie = movies[index];
              final movie = libraryMovie.movie;

              return ListTile(
                leading: movie.image != null
                    ? Image.file(movie.image!,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.movie),
                title: Text(movie.title),
                subtitle: Text('${movie.genre} - ${movie.year}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.playlist_add_check),
                      onPressed: () {
                        context.read<LibraryMovieRepository>()
                        .toggleLibraryMovieWatchStatus(movie.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<LibraryMovieRepository>()
                        .removeMovieFromLibrary(movie.id);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
