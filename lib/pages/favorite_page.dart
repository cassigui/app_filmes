import 'package:flutter/material.dart';
import 'package:projeto_flutter/repositories/movie_provider.dart';
import 'package:provider/provider.dart';

class FavoriteMoviesPage extends StatelessWidget {
  const FavoriteMoviesPage({super.key});

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
                return ListTile(
                  leading: movie.image != null
                      ? Image.file(movie.image!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.movie),
                  title: Text(movie.name),
                  subtitle: Text('${movie.genre} - ${movie.year}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () =>
                        context.read<MovieProvider>().toggleFavorite(movie.id),
                  ),
                );
              },
            ),
    );
  }
}
