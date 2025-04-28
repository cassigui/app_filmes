import 'package:flutter/material.dart';
import 'package:projeto_flutter/repositories/library_movie_repository.dart';
import 'package:projeto_flutter/repositories/movie_provider.dart';
import 'package:provider/provider.dart';

class FavoriteMoviesPage extends StatefulWidget {
  const FavoriteMoviesPage({super.key});

  @override
  State<FavoriteMoviesPage> createState() => _FavoriteMoviesPageState();
}

class _FavoriteMoviesPageState extends State<FavoriteMoviesPage> {
  List<bool> movieInLibrary = [];

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<MovieProvider>().favoriteMovies;

    return Scaffold(
      body: favorites.isEmpty
          ? const Center(child: Text('Nenhum favorito ainda.'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final movie = favorites[index];
                bool onLibrary = context.read<LibraryMovieRepositoryMemory>().checkMovieIsInLibrary(movie.id);
                movieInLibrary.add(onLibrary);
                return ListTile(
                  leading: movie.image != null
                      ? Image.file(movie.image!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.movie),
                  title: Text(movie.name),
                  subtitle: Text('${movie.genre} - ${movie.year}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          onLibrary 
                              ? Icons.bookmark 
                              :Icons.bookmark_outline
                        ),
                        onPressed: () {
                          if (onLibrary) {
                            context
                            .read<LibraryMovieRepositoryMemory>()
                            .removeMovieFromLibrary(movie.id);
                          } else {
                            context
                            .read<LibraryMovieRepositoryMemory>()
                            .addMovieToLibrary(movie);
                          }

                          setState(() {
                              movieInLibrary[index] = !movieInLibrary[index];
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () =>
                            context.read<MovieProvider>().toggleFavorite(movie.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
