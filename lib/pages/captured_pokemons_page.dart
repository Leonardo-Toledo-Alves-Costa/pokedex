import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_dart/services/database_service.dart';
import 'package:pokedex_dart/providers/pokemon_data_providers.dart';
import 'package:pokedex_dart/services/api_service.dart';

class CapturedPokemonsPage extends ConsumerStatefulWidget {
  final String userId;

  const CapturedPokemonsPage({super.key, required this.userId});

  @override
  ConsumerState<CapturedPokemonsPage> createState() => _CapturedPokemonsPageState();
}

class _CapturedPokemonsPageState extends ConsumerState<CapturedPokemonsPage> {
  List<String> capturedPokemonUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCapturedPokemons();
  }

  Future<void> loadCapturedPokemons() async {
  try {
    final remoteData = await ApiService.getCapturedPokemons(widget.userId);

    List<String> urls = remoteData.map((item) {
      final id = item['id'];
      return 'https://pokeapi.co/api/v2/pokemon/$id/';
    }).toList();

    await DatabaseService().saveList('captured_pokemons', urls);

    setState(() {
      capturedPokemonUrls = urls;
      isLoading = false;
    });
  } catch (e) {
    print('Erro ao carregar da API: $e');
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> removePokemon(String url, String pokemonId) async {
    await DatabaseService().removeCapturedPokemon(url);
    await ApiService.deleteCapturedPokemon(widget.userId, pokemonId);
    await loadCapturedPokemons(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your pokemons.')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : capturedPokemonUrls.isEmpty
              ? const Center(child: Text('No pokemons captured yet.'))
              : ListView.builder(
                  itemCount: capturedPokemonUrls.length,
                  itemBuilder: (context, index) {
                    final url = capturedPokemonUrls[index];
                    final pokemonAsync = ref.watch(pokemonDataProvider(url));

                    return pokemonAsync.when(
                      loading: () => const ListTile(title: Text('Loading...')),
                      error: (err, _) => ListTile(title: Text('Error: $err')),
                      data: (pokemon) => ListTile(
                        leading: Image.network(pokemon?.sprites?.frontDefault ?? ''),
                        title: Text(pokemon?.name ?? 'Unknown'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await removePokemon(url, pokemon!.id.toString());
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
