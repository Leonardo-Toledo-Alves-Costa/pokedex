import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_dart/providers/pokemon_data_providers.dart';
import 'package:pokedex_dart/services/api_service.dart';

class PokemonCatchPage extends ConsumerStatefulWidget {
  final String userId;
  final String pokemonUrl;

  const PokemonCatchPage({
    super.key,
    required this.userId,
    required this.pokemonUrl,
  });

  factory PokemonCatchPage.fromPokemonUrl({
    required String pokemonUrl,
    required String userId,
  }) {
    return PokemonCatchPage(userId: userId, pokemonUrl: pokemonUrl);
  }

  @override
  ConsumerState<PokemonCatchPage> createState() => _CapturePokemonPageState();
}

class _CapturePokemonPageState extends ConsumerState<PokemonCatchPage> {
  int remainingBalls = 3;
  String message = '';
  bool isLoading = false;
  bool captured = false;

  @override
  Widget build(BuildContext context) {
    final pokemonAsync = ref.watch(pokemonDataProvider(widget.pokemonUrl));

    return Scaffold(
      appBar: AppBar(title: const Text('Captura de Pokémon')),
      body: pokemonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (pokemon) {
          if (pokemon == null) {
            return const Center(child: Text('Pokémon não encontrado.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pokemon.name!.toUpperCase(), style: const TextStyle(fontSize: 24)),
                Image.network(pokemon.sprites!.frontDefault!, height: 120),
                const SizedBox(height: 20),
                Text('Pokébolas restantes: $remainingBalls', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: (remainingBalls > 0 && !captured && !isLoading)
                      ? () async {
                          setState(() {
                            isLoading = true;
                          });

                          await Future.delayed(const Duration(milliseconds: 700));
                          final number = Random().nextInt(10) + 1;

                          if ([2, 5, 8].contains(number)) {
                            setState(() {
                              captured = true;
                              message = '${pokemon.name} foi capturado!';
                            });

                            await ApiService.capturePokemon(
                              userId: widget.userId,
                              pokemonId: pokemon.id.toString(),
                              pokemonName: pokemon.name ?? 'Unknown pokemon',
                            );

                            await Future.delayed(const Duration(seconds: 1));
                            if (mounted) Navigator.pop(context);
                          } else {
                            setState(() {
                              remainingBalls--;
                              message = 'Falhou! Número sorteado: $number';
                              isLoading = false;
                            });
                          }
                        }
                      : null,
                  icon: const Icon(Icons.catching_pokemon),
                  label: const Text('Lançar Pokébola'),
                ),
                const SizedBox(height: 20),
                if (message.isNotEmpty) Text(message, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
