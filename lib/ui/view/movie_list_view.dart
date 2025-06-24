import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto_flutter/data/repositories/library_movie_repository.dart';
import 'package:projeto_flutter/domain/models/movie.dart';
import 'package:projeto_flutter/ui/viewmodels/movie_view_model.dart';
import 'package:provider/provider.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  Map<String, bool> movieInLibrary = {};
  Map<String, bool> movieIsFavorite = {};

  Future<void> loadMovies(List<Movie> movies) async {
    for (var movie in movies) {
      bool isWatched = await context.read<LibraryMovieRepository>().checkMovieIsInLibrary(movie.id);
      bool isFavorite = await context.read<MovieViewModel>().checkMovieIsFavorite(movie.id);
      movieInLibrary[movie.id] = isWatched;
      movieIsFavorite[movie.id] = isFavorite;
    }
    if (!mounted) return;

    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieViewModel>().movies;
    loadMovies(movies);

    return Scaffold(
      body: movies.isEmpty
          ? const Center(child: Text('Nenhum filme cadastrado.'))
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                bool onLibrary = movieInLibrary[movie.id] == null ? false : movieInLibrary[movie.id]!;
                bool isFavorite = movieIsFavorite[movie.id] == null ? false : movieIsFavorite[movie.id]!;
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
                        icon: Icon(onLibrary
                            ? Icons.bookmark
                            : Icons.bookmark_outline),
                        onPressed: () {
                          if (onLibrary) {
                            context
                                .read<LibraryMovieRepository>()
                                .removeMovieFromLibrary(movie.id);
                          } else {
                            context
                                .read<LibraryMovieRepository>()
                                .addMovieToLibrary(movie);
                          }

                          setState(() {
                            movieInLibrary[movie.id] = !movieInLibrary[movie.id]!;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          context.read<MovieViewModel>()
                            .toggleFavorite(movie.id);

                          setState(() {
                            movieIsFavorite[movie.id] = !movieIsFavorite[movie.id]!;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMoviePage(movie: movie),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context
                              .read<LibraryMovieRepository>()
                              .removeMovieFromLibrary(movie.id);
                          context.read<MovieViewModel>().removeMovie(movie.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMoviePage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddMoviePage extends StatefulWidget {
  final Movie? movie;

  const AddMoviePage({super.key, this.movie});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _genreController;
  late final TextEditingController _yearController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.movie?.title ?? '');
    _genreController = TextEditingController(text: widget.movie?.genre ?? '');
    _yearController = TextEditingController(text: widget.movie?.year ?? '');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (widget.movie == null) {
        context.read<MovieViewModel>().addMovie(
              _nameController.text,
              _genreController.text,
              _yearController.text,
              _image,
            );
      } else {
        context.read<MovieViewModel>().editMovie(
              widget.movie!.id,
              _nameController.text,
              _genreController.text,
              _yearController.text,
              _image,
            );
        await context.read<LibraryMovieRepository>().loadMovies();
      }
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movie != null;

    return Scaffold(
      appBar:
          AppBar(title: Text(isEditing ? 'Editar Filme' : 'Adicionar Filme')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Filme'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o nome do filme'
                    : null,
              ),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Gênero'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o gênero' : null,
              ),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ano'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o ano' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Salvar Alterações' : 'Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
