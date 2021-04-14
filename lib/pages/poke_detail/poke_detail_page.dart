import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:pokeweakness/consts/consts_api.dart';
import 'package:pokeweakness/consts/consts_app.dart';
import 'package:pokeweakness/models/pokeapi.dart';
import 'package:pokeweakness/stores/pokeapi_store.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class PokeDetailPage extends StatefulWidget {
  final int index;
  PokeDetailPage({Key key, this.index}) : super(key: key);

  @override
  _PokeDetailPageState createState() => _PokeDetailPageState();
}

class _PokeDetailPageState extends State<PokeDetailPage> {
  PageController _pageController;
  Pokemon _pokemon;
  PokeApiStore _pokemonStore;
  double _progress;
  double _multiple;
  double _opacity;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.index, viewportFraction: 0.8);
    _pokemonStore = GetIt.instance<PokeApiStore>();
    _pokemon = _pokemonStore.pokemonAtual;
    _progress = 0;
    _multiple = 1;
    _opacity = 1;
  }

  double interval(double lower, double upper, double progress) {
    assert(lower < upper);

    if (progress > upper) return 1.0;
    if (progress < upper) return 0.0;

    return ((progress - lower) / (upper - lower).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Observer(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                AppBar(
                  title: Opacity(
                    child: Text(
                      _pokemonStore.pokemonAtual.name,
                      style: TextStyle(
                          fontFamily: 'Google',
                          fontWeight: FontWeight.bold,
                          fontSize: 21),
                    ),
                    opacity: 1,
                  ),
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: _pokemonStore.corPokemon,
                  leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        setTipos(_pokemonStore.pokemonAtual.type),
                        Text(
                          '#' + _pokemonStore.pokemonAtual.num.toString(),
                          style: TextStyle(
                              fontFamily: 'Google',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      ],
                    )),
              ],
            );
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          Observer(
            builder: (context) {
              return Container(color: _pokemonStore.corPokemon);
            },
          ),
          Container(height: MediaQuery.of(context).size.height / 3),
          SlidingSheet(
            listener: (state) {
              setState(() {
                _progress = state.progress;
                _multiple = 1 - interval(0.0, 0.7, _progress);
                _opacity = _multiple;
              });
            },
            elevation: 0,
            cornerRadius: 30,
            snapSpec: const SnapSpec(
              snap: true,
              snappings: [0.7, 1],
              positioning: SnapPositioning.relativeToAvailableSpace,
            ),
            builder: (context, state) {
              return Container(
                height: MediaQuery.of(context).size.height,
              );
            },
          ),
          Padding(
            child: SizedBox(
                height: 600,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    _pokemonStore.setPokemonAtual(index: index);
                  },
                  itemCount: _pokemonStore.pokeAPI.pokemon.length,
                  itemBuilder: (BuildContext context, int count) {
                    Pokemon _pokeitem = _pokemonStore.getPokemon(index: count);
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Hero(
                          tag: _pokeitem.name,
                          child: Opacity(
                            child: Image.asset(
                              ConstsApp.whitePokeball,
                              height: 300,
                              width: 300,
                            ),
                            opacity: 0.2,
                          ),
                        ),
                        Hero(
                          tag: _pokeitem.name,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 300.0),
                            child: CachedNetworkImage(
                              height: 200,
                              width: 200,
                              placeholder: (context, url) => new Container(
                                color: Colors.transparent,
                              ),
                              imageUrl:
                                  'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_pokeitem.num}.png',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            'Weak Againts:',
                            style: TextStyle(
                                fontFamily: 'Google',
                                fontSize: 10,
                                color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 300.0),
                          child: Hero(
                            tag: _pokeitem.name,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                setFraquezas(
                                    _pokemonStore.pokemonAtual.weakness),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )),
            padding: EdgeInsets.only(top: 60 - _progress * 50),
          )
        ],
      ),
    );
  }

  Widget setTipos(List<String> types) {
    List<Widget> lista = [];
    types.forEach((nome) {
      lista.add(
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromARGB(80, 255, 255, 255)),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  nome.trim(),
                  style: TextStyle(
                      fontFamily: 'Google',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            )
          ],
        ),
      );
    });
    return Row(
      children: lista,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget setFraquezas(List<String> weakness) {
    List<Widget> lista = [];
    weakness.forEach((nome) {
      lista.add(
        Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(0, 0, 0, 0)),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  nome.trim(),
                  style: TextStyle(
                      fontFamily: 'Google',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            )
          ],
        ),
      );
    });
    return Column(
      children: lista,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}
