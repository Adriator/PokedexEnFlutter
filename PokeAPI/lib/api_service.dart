import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pokemon.dart';

class ApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  /// 🔹 Obtiene TODOS los Pokémon con solicitudes en paralelo para acelerar la carga
  Future<List<Pokemon>> fetchAllPokemons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?limit=1025'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        // 🔥 Solicitudes en paralelo
        final pokemonResponses = await Future.wait(
          results.map((item) => http.get(Uri.parse(item['url']))),
        );

        // Procesar respuestas exitosas
        List<Pokemon> pokemonList = pokemonResponses
            .where((res) => res.statusCode == 200)
            .map((res) => Pokemon.fromJson(json.decode(res.body)))
            .toList();

        return pokemonList;
      } else {
        throw Exception('Error al cargar los Pokémon (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('No se pudo conectar con la API. Verifica tu conexión a internet. Error: $e');
    }
  }

  /// 🔍 Busca un Pokémon por nombre
  Future<Pokemon?> fetchPokemonByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$name'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error al buscar Pokémon: $e');
      return null;
    }
  }
}
