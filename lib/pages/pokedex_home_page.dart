import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_dart/controllers/home_page_controller.dart';
import 'package:pokedex_dart/models/page_data.dart';
import 'package:pokedex_dart/models/pokemon.dart';
import 'package:pokedex_dart/pages/captured_pokemons_page.dart';
import 'package:pokedex_dart/pages/pokemon_catch_page.dart';
import 'package:pokedex_dart/providers/pokemon_data_providers.dart';
import 'package:pokedex_dart/widgets/pokemon_card.dart';
import 'package:pokedex_dart/widgets/pokemon_list_tile.dart';

final homePageControllerProvider =
    StateNotifierProvider<HomePageController, HomePageData>((ref) {
      return HomePageController(HomePageData.initial());
    });

class PokedexHomePage extends ConsumerStatefulWidget {
  const PokedexHomePage({super.key});

  @override
  ConsumerState<PokedexHomePage> createState() => _PokedexHomePageState();
}

class _PokedexHomePageState extends ConsumerState<PokedexHomePage> {
  final ScrollController _allPokemonsListScrollController = ScrollController();
  late HomePageController _homePageController;
  late HomePageData _homePageData;
  late List<String> _favoritePokemons;

  @override
  void initState() {
    _allPokemonsListScrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _allPokemonsListScrollController.removeListener(_scrollListener);
    _allPokemonsListScrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_allPokemonsListScrollController.offset >=
            _allPokemonsListScrollController.position.maxScrollExtent &&
        !_allPokemonsListScrollController.position.outOfRange) {
      _homePageController.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    _homePageController = ref.watch(homePageControllerProvider.notifier);
    _homePageData = ref.watch(homePageControllerProvider);
    _favoritePokemons = ref.watch(favoritePokemonsProvider);

    return Scaffold(body: _buildUI(context));
  }

  Widget _buildUI(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * 0.1,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _favoritePokemonsList(context),
              _allPokemonsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _favoritePokemonsList(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Favorites', style: TextStyle(fontSize: 25)),
              IconButton(
                icon: const Icon(Icons.catching_pokemon, color: Colors.red),
                tooltip: 'Catch a Random Pokemon!',
                onPressed: () {
                  if (_favoritePokemons.isNotEmpty) {
                    final randomIndex = Random().nextInt(
                      _favoritePokemons.length,
                    );
                    final randomPokemonURL = _favoritePokemons[randomIndex];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonCatchPage.fromPokemonUrl(
                          pokemonUrl: randomPokemonURL,
                          userId: 'bb1fb742-d353-4644-ab3a-10b61f1f5579',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No favorite pokemons to capture yet.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.50,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_favoritePokemons.isNotEmpty)
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.48,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                      itemCount: _favoritePokemons.length,
                      itemBuilder: (context, index) {
                        String pokemonURL = _favoritePokemons[index];
                        return PokemonCard(pokemonURL: pokemonURL);
                      },
                    ),
                  ),
                if (_favoritePokemons.isEmpty)
                  const Text('No favorite pokemons yet, try choosing one!'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _allPokemonsList(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('All pokemons', style: TextStyle(fontSize: 25)),
              IconButton(
                icon: const Icon(Icons.inventory_2_outlined, color: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CapturedPokemonsPage(userId: 'bb1fb742-d353-4644-ab3a-10b61f1f5579',),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.60,
            child: ListView.builder(
              controller: _allPokemonsListScrollController,
              itemCount: _homePageData.data?.results?.length ?? 0,
              itemBuilder: (context, index) {
                PokemonListResult pokemon = _homePageData.data!.results![index];
                return PokemonListTile(pokemonURL: pokemon.url!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
