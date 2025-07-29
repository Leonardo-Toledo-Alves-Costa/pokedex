import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_dart/providers/pokemon_data_providers.dart';
import 'package:pokedex_dart/providers/captured_pokemons_provider.dart';
import 'package:pokedex_dart/services/api_service.dart';

class CapturedPokemonsPage extends ConsumerWidget {
  final String userId;

  const CapturedPokemonsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedUrls = ref.watch(capturedPokemonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Pokémons'),
      ),
      body: capturedUrls.isEmpty
          ? const Center(child: Text('No captured Pokémons yet.'))
          : ListView.builder(
              itemCount: capturedUrls.length,
              itemBuilder: (context, index) {
                final url = capturedUrls[index];
                final asyncPokemon = ref.watch(pokemonDataProvider(url));

                return asyncPokemon.when(
                  data: (pokemon) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          pokemon?.sprites?.frontDefault ?? '',
                          width: 60,
                          height: 60,
                        ),
                        title: Text(pokemon?.name ?? 'Unknown'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await ApiService.deleteCapturedPokemon(userId, pokemon!.id.toString());
                            await ref.read(capturedPokemonsProvider.notifier).removeCapturedPokemon(url);
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => ListTile(
                    title: Text('Error loading Pokémon: $err'),
                  ),
                );
              },
            ),
    );
  }
}
