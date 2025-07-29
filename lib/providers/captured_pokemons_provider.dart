import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_dart/services/database_service.dart';
import 'package:pokedex_dart/services/api_service.dart';

final capturedPokemonsProvider =
    StateNotifierProvider<CapturedPokemonsNotifier, List<String>>((ref) {
  return CapturedPokemonsNotifier(userId: 'bb1fb742-d353-4644-ab3a-10b61f1f5579'); 
});

class CapturedPokemonsNotifier extends StateNotifier<List<String>> {
  final DatabaseService _db = DatabaseService();
  final String userId;

  CapturedPokemonsNotifier({required this.userId}) : super([]) {
    _loadCaptured();
  }

  Future<void> _loadCaptured() async {
    try {
      final remoteData = await ApiService.getCapturedPokemons(userId);

      final urls = remoteData.map((item) {
        final id = item['id'];
        return 'https://pokeapi.co/api/v2/pokemon/$id/';
      }).toList();

      await _db.saveList('captured', urls);

      state = urls;
    } catch (e) {
      Text('Erro ao carregar capturados da API: $e');
      final local = await _db.getList('captured') ?? [];
      state = local;
    }
  }

  Future<void> addCapturedPokemon(String pokemonUrl) async {
    if (!state.contains(pokemonUrl)) {
      final updated = [...state, pokemonUrl];
      state = updated;
      await _db.saveList('captured', updated);
    }
  }

  Future<void> removeCapturedPokemon(String pokemonUrl) async {
    final updated = state.where((url) => url != pokemonUrl).toList();
    state = updated;
    await _db.saveList('captured', updated);
  }
}
