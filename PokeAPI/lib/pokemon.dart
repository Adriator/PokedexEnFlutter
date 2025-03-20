class Pokemon {
  final String name;
  final String imageUrl;
  final String gifUrl;
  final String shinyGifUrl;
  final double weight;
  final double height;
  final List<String> types;
  final Map<String, int> stats;
  final Map<String, int> moves;
  final String cryUrl; // 🔊 Nuevo campo para el sonido
  bool isFavorite;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.gifUrl,
    required this.shinyGifUrl,
    required this.weight,
    required this.height,
    required this.types,
    required this.stats,
    required this.moves,
    required this.cryUrl, // 🔊 Incluir sonido
    this.isFavorite = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl: json['sprites']?['other']?['official-artwork']?['front_default'] ?? '',
      gifUrl: json['sprites']?['other']?['showdown']?['front_default'] ?? '',
      shinyGifUrl: json['sprites']?['other']?['showdown']?['front_shiny'] ?? '',
      weight: json['weight'] / 10.0,
      height: json['height'] / 10.0,
      types: (json['types'] as List).map((type) => type['type']['name'] as String).toList(),
      stats: {for (var stat in json['stats']) stat['stat']['name']: stat['base_stat'] as int},
      moves: {
        for (var move in json['moves']) move['move']['name']: move['version_group_details'][0]['level_learned_at'] as int,
      }..removeWhere((_, level) => level == 0),
      cryUrl: json['cries']?['latest'] ?? '', // 🔊 Obtener el sonido
    );
  }
}
