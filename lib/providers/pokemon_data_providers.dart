import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
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
