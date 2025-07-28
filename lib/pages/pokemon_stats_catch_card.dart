import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_dart/providers/pokemon_data_providers.dart';

class PokemonStatsCatchCard extends ConsumerWidget {
  final String pokemonURL;

  const PokemonStatsCatchCard({required this.pokemonURL, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonDataProvider(pokemonURL));

    return AlertDialog(
      title: const Text('Statistics'),
      content: pokemon.when(
        data: (data) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: data?.stats?.map((s) {
             return Text("${s.stat?.name?.toUpperCase()}: ${s.baseStat}"); 
            }).toList() ?? [],
          );
        },
        error: (error, stackTrace) {
          return Text('Error: $error');
        },
        loading: () {
          return const CircularProgressIndicator(color: Colors.white);
        },
      ),
    );
  }
}
