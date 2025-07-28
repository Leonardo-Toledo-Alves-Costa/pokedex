import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> capturePokemon({
    required String userId,
    required String pokemonId,
    required String pokemonName,
  }) async {
    const url = 'https://pokedex-api-i5r9.onrender.com/api/v1/pokedex';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userID": userId,
        "pokemonID": pokemonId,
        "name": pokemonName, 
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao capturar o Pokémon: ${response.body}');
    }
  }
}
