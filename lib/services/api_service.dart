import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://pokedex-api-lmk9.onrender.com/api/v1';

  static Future<void> capturePokemon({
    required String userId,
    required String pokemonId,
    required String pokemonName,
  }) async {
    final url = Uri.parse(
      'https://pokedex-api-lmk9.onrender.com/api/v1/poke/$userId',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': pokemonId, 'name': pokemonName}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao salvar na API: ${response.body}');
    }
  }

  static Future<void> removePokemon({
    required String userId,
    required String pokemonId,
  }) async {
    final url = Uri.parse('$baseUrl/pokedex/$userId/$pokemonId');
    await http.delete(url);
  }

  static Future<List<Map<String, dynamic>>> getCapturedPokemons(
    String userId,
  ) async {
    final url = Uri.parse(
      'https://pokedex-api-lmk9.onrender.com/api/v1/pokedex/$userId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao buscar Pokémons: ${response.body}');
    }
  }

  static Future<void> deleteCapturedPokemon(
    String userId,
    String pokemonId,
  ) async {
    final url = Uri.parse(
      'https://pokedex-api-lmk9.onrender.com/api/v1/poke/$userId/$pokemonId',
    );

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar Pokémon na API: ${response.body}');
    }
  }
}
