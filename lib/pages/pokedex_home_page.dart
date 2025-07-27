import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_dart/controllers/home_page_controller.dart';
import 'package:pokedex_dart/models/page_data.dart';
import 'package:pokedex_dart/models/pokemon.dart';
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
            children: [_allPokemonsList(context)],
          ),
        ),
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
          const Text('All pokemons', style: TextStyle(fontSize: 25)),
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
