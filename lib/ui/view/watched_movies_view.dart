import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/repositories/library_movie_repository.dart';
import 'package:provider/provider.dart';

class WatchedMoviesListView extends StatelessWidget {
  const WatchedMoviesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<LibraryMovieRepository>().watchedMovies;

    return Scaffold(
      body: movies.isEmpty
          ? const Center(child: Text('Sua lista está vazia.'))
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final libraryMovie = movies[index];
                final movie = movies[index].movie;
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
                        icon: const Icon(
                          Icons.watch_later,
                        ),
                        onPressed: () => context
                            .read<LibraryMovieRepository>()
                            .toggleLibraryMovieWatchStatus(movie.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context
                              .read<LibraryMovieRepository>()
                              .removeMovieFromLibrary(libraryMovie.movie.id);
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
