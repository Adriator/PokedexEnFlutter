import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'PokemonDetailScreen.dart';
import 'api_service.dart';
import 'pokemon.dart';
import 'pokemon_tile.dart'; // Importamos el nuevo PokemonTile

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({super.key, required this.toggleTheme});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Pokemon> _pokemons = [];
  List<Pokemon> _filteredPokemons = [];
  List<Pokemon> _originalPokemons = []; // Lista para guardar el orden original
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false;  // Nueva variable para mostrar solo favoritos

  String? _selectedType;
  Map<String, String> _typeMapping = {
    'Todos': 'All',
    'Agua': 'water',
    'Fuego': 'fire',
    'Planta': 'grass',
    'Eléctrico': 'electric',
    'Bicho': 'bug',
    'Hada': 'fairy',
    'Fantasma': 'ghost',
    'Acero': 'steel',
    'Lucha': 'fighting',
    'Normal': 'normal',
    'Veneno': 'poison',
    'Volador': 'flying',
    'Psíquico': 'psychic',
    'Roca': 'rock',
    'Hielo': 'ice',
    'Dragón': 'dragon',
    'Siniestro': 'dark',
    'Terreno': 'ground',
  };

  List<String> _types = [
    'Todos',
    'Agua',
    'Fuego',
    'Planta',
    'Eléctrico',
    'Bicho',
    'Hada',
    'Fantasma',
    'Acero',
    'Lucha',
    'Normal',
    'Veneno',
    'Volador',
    'Psíquico',
    'Roca',
    'Hielo',
    'Dragón',
    'Siniestro',
    'Terreno',
  ];

  bool _isGridView = true;
  bool _isAlphabeticalOrder = false;  // Estado para saber si estamos en orden alfabético

  @override
  void initState() {
    super.initState();
    _loadPokemons();
    _searchController.addListener(_filterPokemons);
  }

  Future<void> _loadPokemons() async {
    try {
      List<Pokemon> allPokemons = await _apiService.fetchAllPokemons();
      setState(() {
        _pokemons = allPokemons;
        _originalPokemons = List.from(allPokemons); // Guardar el orden original
        _filteredPokemons = _pokemons;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _filterPokemons() {
    String query = _searchController.text.trim().toLowerCase();
    String? selectedType = _typeMapping[_selectedType];

    List<Pokemon> filteredList = _pokemons.where((pokemon) {
      final matchesQuery = pokemon.name.toLowerCase().contains(query);
      final matchesType = selectedType == null || selectedType == 'All' || pokemon.types.contains(selectedType);
      final matchesFavorites = !_showFavoritesOnly || pokemon.isFavorite;
      return matchesQuery && matchesType && matchesFavorites;
    }).toList();

    setState(() {
      _filteredPokemons = filteredList;
    });
  }

  void _onTypeSelected(String? type) {
    setState(() {
      _selectedType = type;
      _filterPokemons();
    });
  }

  // Método para alternar el filtro de favoritos
  void _toggleFavoritesOnly() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
      _filterPokemons();
    });
  }

  // Método para seleccionar un Pokémon aleatorio
  void _showRandomPokemon() {
    if (_pokemons.isNotEmpty) {
      final randomIndex = (DateTime.now().millisecondsSinceEpoch % _pokemons.length).toInt();
      final randomPokemon = _pokemons[randomIndex];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDetailScreen(pokemon: randomPokemon),
        ),
      );
    }
  }

  // Método para alternar entre orden alfabético y orden de la Pokédex
  void _toggleSortOrder() {
    setState(() {
      if (_isAlphabeticalOrder) {
        // Restaurar el orden original de la Pokédex
        _filteredPokemons = List.from(_originalPokemons);
      } else {
        // Ordenar alfabéticamente
        _filteredPokemons.sort((a, b) => a.name.compareTo(b.name));
      }
      _isAlphabeticalOrder = !_isAlphabeticalOrder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokédex',
          style: GoogleFonts.pressStart2p(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_on),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.star, color: _showFavoritesOnly ? Colors.yellow : Colors.white),
            onPressed: _toggleFavoritesOnly,  // Botón para alternar favoritos
          ),
          IconButton(
            icon: Icon(Icons.casino),
            onPressed: _showRandomPokemon,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadPokemons,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar Pokémon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _selectedType,
                hint: Text('Selecciona un tipo'),
                onChanged: _onTypeSelected,
                items: _types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
            ),
            // Aquí colocamos el botón flotante por encima de la cuadrícula
            Expanded(
              child: Stack(
                children: [
                  // Aquí mostramos la cuadrícula o lista de Pokémon
                  _filteredPokemons.isEmpty
                      ? Center(
                    child: Text(
                      _showFavoritesOnly
                          ? 'No hay Pokémon favoritos'
                          : 'No se encontraron resultados',
                      style: GoogleFonts.pressStart2p(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : _isGridView
                      ? GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _filteredPokemons.length,
                    itemBuilder: (context, index) {
                      return PokemonTile(pokemon: _filteredPokemons[index]);
                    },
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _filteredPokemons.length,
                    itemBuilder: (context, index) {
                      return PokemonTile(pokemon: _filteredPokemons[index]);
                    },
                  ),
                  // Botón flotante por encima de la cuadrícula
                  Positioned(
                    right: 16.0,
                    bottom: 16.0,
                    child: FloatingActionButton(
                      onPressed: _toggleSortOrder,  // Alterna el orden
                      child: Icon(Icons.sort_by_alpha),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
