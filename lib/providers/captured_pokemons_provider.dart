import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_dart/services/database_service.dart';

final capturedPokemonsProvider =
    StateNotifierProvider<CapturedPokemonsNotifier, List<String>>((ref) {
  return CapturedPokemonsNotifier();
});

class CapturedPokemonsNotifier extends StateNotifier<List<String>> {
  final _db = DatabaseService();

  CapturedPokemonsNotifier() : super([]) {
    _loadCaptured();
  }

  Future<void> _loadCaptured() async {
    final list = await _db.getList('captured') ?? [];
    state = list;
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
