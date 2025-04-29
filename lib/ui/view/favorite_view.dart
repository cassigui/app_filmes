import 'package:flutter/material.dart';
import 'package:projeto_flutter/ui/viewmodels/movie_view_model.dart';
import 'package:provider/provider.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<MovieViewModel>().favoriteMovies;

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
                        context.read<MovieViewModel>().toggleFavorite(movie.id),
                  ),
                );
              },
            ),
    );
  }
}
