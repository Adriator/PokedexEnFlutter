import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // Importa audioplayers
import 'pokemon.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  bool _isShiny = false; // Estado para alternar entre normal y shiny
  final AudioPlayer _audioPlayer = AudioPlayer(); // 🎵 Controlador de audio

  void _playCry() async {
    if (widget.pokemon.cryUrl.isNotEmpty) {
      await _audioPlayer.play(UrlSource(widget.pokemon.cryUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay sonido disponible para este Pokémon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.yellow[100],
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              widget.pokemon.name.toUpperCase(),
              style: GoogleFonts.pressStart2p(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // GIF con pulsación para alternar entre normal y shiny
            GestureDetector(
              onTap: () {
                setState(() {
                  _isShiny = !_isShiny;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  _isShiny
                      ? widget.pokemon.shinyGifUrl.isNotEmpty
                      ? widget.pokemon.shinyGifUrl
                      : widget.pokemon.imageUrl
                      : widget.pokemon.gifUrl.isNotEmpty
                      ? widget.pokemon.gifUrl
                      : widget.pokemon.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 60, color: Colors.red);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _playCry, // Botón para reproducir el sonido
              icon: Icon(Icons.volume_up),
              label: Text('Escuchar sonido'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              _isShiny ? 'SHINY' : 'NORMAL',
              style: GoogleFonts.pressStart2p(
                fontSize: 14,
                color: _isShiny ? Colors.amber : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.pokemon.name.toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Height:', '${widget.pokemon.height} m', isDarkMode),
            _buildInfoRow('Weight:', '${widget.pokemon.weight} kg', isDarkMode),
            _buildInfoRow('Types:', widget.pokemon.types.join(', '), isDarkMode),
            const SizedBox(height: 16),
            Text(
              'Base Stats',
              style: GoogleFonts.pressStart2p(
                fontSize: 18.0,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.pokemon.stats.entries.map((entry) => _buildInfoRow(
              entry.key.toUpperCase(),
              entry.value.toString(),
              isDarkMode,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 16.0,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.pressStart2p(
              fontSize: 16.0,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
