import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:pokedex_dart/services/database_service.dart';
import 'package:pokedex_dart/services/http_service.dart';
import '../models/pokemon.dart';

final pokemonDataProvider = FutureProvider.family<Pokemon?, String>((
  ref,
  pokeURL,
) async {
  HttpService _httpService = GetIt.instance.get<HttpService>();
  Response? res = await _httpService.get(pokeURL);

  if (res != null && res.data != null) {
    return Pokemon.fromJson(res.data!);
  }
  return null;
});

final favoritePokemonsProvider =
    StateNotifierProvider<FavoritePokemonsProvider, List<String>>((ref) {
      return FavoritePokemonsProvider([]);
    });

class FavoritePokemonsProvider extends StateNotifier<List<String>> {
  final DatabaseService _databaseService = GetIt.instance
      .get<DatabaseService>();

  FavoritePokemonsProvider(super.state) {
    _setup();
  }

  String favoritePokemonListKey = 'favorite_pokemon_list_key';

  Future<void> _setup() async {
    List<String>? result = await _databaseService.getList(favoritePokemonListKey);
    state = result ?? [];
  }

  void addFavoritePokemon(String url) {
    state = [...state, url];
    _databaseService.saveList(favoritePokemonListKey, state);
  }

  void removeFavoritePokemon(String url) {
    state = state.where((element) => element != url).toList();
    _databaseService.saveList(favoritePokemonListKey, state);
  }
}
