import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PokemonDetailScreen.dart';
import 'pokemon.dart';

class PokemonTile extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonTile({super.key, required this.pokemon});

  @override
  _PokemonTileState createState() => _PokemonTileState();
}

class _PokemonTileState extends State<PokemonTile> {
  String _favoriteMessage = ''; // Variable para mostrar el mensaje de "es tu favorito"

  // Mapeo de los tipos a sus colores
  final Map<String, Color> _typeColors = {
    'water': Colors.blue,
    'fire': Colors.red,
    'grass': Colors.green,
    'electric': Colors.yellow,
    'bug': Colors.greenAccent,
    'fairy': Colors.pink,
    'ghost': Colors.purple,
    'steel': Colors.grey,
    'fighting': const Color(0xFF8B0000),
    'normal': Colors.grey, // Color para el tipo normal
    'poison': Colors.purpleAccent,
    'flying': Colors.blueGrey,
    'psychic': Colors.deepPurple,
    'rock': Colors.orange,
    'ice': Colors.lightBlueAccent,
    'dragon': Colors.deepOrange,
    'dark': Colors.black,
    'ground': const Color(0xFFD2B48C),
    'unknown': Colors.grey, // Para Pokémon con tipo desconocido
    'todos': Colors.white, // Para mostrar todos sin filtro
  };

  // Guardar estado de favoritos en SharedPreferences
  void _saveFavoriteStatus(bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(widget.pokemon.name, isFavorite);  // Guardar como clave el nombre del Pokémon
  }

  // Cargar estado de favoritos desde SharedPreferences
  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.pokemon.isFavorite = prefs.getBool(widget.pokemon.name) ?? false; // Si no existe, es falso
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();  // Cargar estado de favoritos cuando se inicializa el widget
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el primer tipo del Pokémon (para simplificar, usamos solo el primer tipo)
    String pokemonType = widget.pokemon.types.isNotEmpty ? widget.pokemon.types[0] : 'unknown';

    // Seleccionar el color adecuado para el tipo de Pokémon
    Color borderColor = _typeColors[pokemonType] ?? _typeColors['unknown']!;

    // Detectar si el tema es oscuro o claro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Definir los colores de fondo y texto según el tema
    Color cardBackgroundColor = isDarkMode ? Colors.black : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () {
        // Al pulsar un Pokémon, se navega a la pantalla de detalles
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailScreen(pokemon: widget.pokemon),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: cardBackgroundColor, // Fondo de la tarjeta dependiendo del tema
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: borderColor, width: 2.0), // Borde más delgado (2.0)
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6.0,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Stack(  // Usamos un Stack para apilar el ícono de la estrella
          children: [
            Center(  // Centramos todo el contenido dentro del cuadrado
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.pokemon.imageUrl,
                      width: 60, // Tamaño de la imagen ajustado
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 60);
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.pokemon.name.toUpperCase(),
                    style: GoogleFonts.pressStart2p(
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0, // Fuente ajustada
                      color: textColor, // Cambiar color del texto según el tema
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Ícono de la estrella en la esquina superior derecha
            Positioned(
              right: 8.0,  // 8px de margen desde la derecha
              top: 8.0,    // 8px de margen desde la parte superior
              child: IconButton(
                icon: Icon(
                  widget.pokemon.isFavorite ? Icons.star : Icons.star_border,  // Ícono de estrella
                  color: widget.pokemon.isFavorite ? Colors.yellow : Colors.grey, // Cambia el color de la estrella
                ),
                onPressed: () {
                  setState(() {
                    widget.pokemon.isFavorite = !widget.pokemon.isFavorite; // Cambiar el estado de favorito
                    _favoriteMessage = widget.pokemon.isFavorite
                        ? '${widget.pokemon.name} ahora es tu favorito'
                        : ''; // Actualizar el mensaje
                  });

                  // Guardar el nuevo estado en SharedPreferences
                  _saveFavoriteStatus(widget.pokemon.isFavorite);

                  // Mostrar el mensaje en un SnackBar
                  if (widget.pokemon.isFavorite) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_favoriteMessage)),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
