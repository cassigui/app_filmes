import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MovieProvider(),
      child: const MyApp(),
    ),
  );
}

class Movie {
  final String id;
  String name;
  String genre;
  String year;
  bool isFavorite;
  File? image;

  Movie({
    required this.id,
    required this.name,
    required this.genre,
    required this.year,
    this.isFavorite = false,
    this.image,
  });
}

class MovieProvider extends ChangeNotifier {
  final List<Movie> _movies = [];

  List<Movie> get movies => _movies;
  List<Movie> get favoriteMovies => _movies.where((m) => m.isFavorite).toList();

  void addMovie(String name, String genre, String year, File? image) {
    _movies.add(
      Movie(
        id: const Uuid().v4(),
        name: name,
        genre: genre,
        year: year,
        image: image,
      ),
    );
    notifyListeners();
  }

  void removeMovie(String id) {
    _movies.removeWhere((movie) => movie.id == id);
    notifyListeners();
  }

  void editMovie(String id, String name, String genre, String year, File? image) {
    final index = _movies.indexWhere((movie) => movie.id == id);
    if (index != -1) {
      _movies[index].name = name;
      _movies[index].genre = genre;
      _movies[index].year = year;
      _movies[index].image = image;
      notifyListeners();
    }
  }

  void toggleFavorite(String id) {
    final index = _movies.indexWhere((movie) => movie.id == id);
    if (index != -1) {
      _movies[index].isFavorite = !_movies[index].isFavorite;
      notifyListeners();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Filmes',
      theme: ThemeData.dark().copyWith(
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Colors.deepPurple,
              secondary: Colors.deepPurpleAccent,
            ),
      ),
      home: const MainTabController(),
    );
  }
}

class MainTabController extends StatelessWidget {
  const MainTabController({super.key});

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

class MovieListPage extends StatelessWidget {
  const MovieListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>().movies;

    return Scaffold(
      body: movies.isEmpty
          ? const Center(child: Text('Nenhum filme cadastrado.'))
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  leading: movie.image != null ? Image.file(movie.image!, width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.movie),
                  title: Text(movie.name),
                  subtitle: Text('${movie.genre} - ${movie.year}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: movie.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => context.read<MovieProvider>().toggleFavorite(movie.id),
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
                          context.read<MovieProvider>().removeMovie(movie.id);
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
                  leading: movie.image != null ? Image.file(movie.image!, width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.movie),
                  title: Text(movie.name),
                  subtitle: Text('${movie.genre} - ${movie.year}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => context.read<MovieProvider>().toggleFavorite(movie.id),
                  ),
                );
              },
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
    _nameController = TextEditingController(text: widget.movie?.name ?? '');
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.movie == null) {
        context.read<MovieProvider>().addMovie(
              _nameController.text,
              _genreController.text,
              _yearController.text,
              _image,
            );
      } else {
        context.read<MovieProvider>().editMovie(
              widget.movie!.id,
              _nameController.text,
              _genreController.text,
              _yearController.text,
              _image,
            );
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
      appBar: AppBar(title: Text(isEditing ? 'Editar Filme' : 'Adicionar Filme')),
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
                  child: _image == null ? const Icon(Icons.camera_alt, size: 50) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Filme'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome do filme' : null,
              ),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Gênero'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o gênero' : null,
              ),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ano'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o ano' : null,
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
