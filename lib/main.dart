import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() => runApp(const LDSWHttpApp());

class LDSWHttpApp extends StatelessWidget {
  const LDSWHttpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LDSW 3.6 Peticiones HTTP',
      home: const PokemonScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  String _pokemonName = '';
  String _pokemonImage = '';
  List<String> _pokemonTypes = [];
  bool _loading = false;

  Future<void> fetchPokemon() async {
    setState(() {
      _loading = true;
    });

    int randomId = Random().nextInt(151) + 1;

    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$randomId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _pokemonName = data['name'];
        _pokemonImage = data['sprites']['other']['official-artwork']['front_default'];
        _pokemonTypes = List<String>.from(
          data['types'].map((typeData) => typeData['type']['name']),
        );
        _loading = false;
      });
    } else {
      setState(() {
        _pokemonName = 'Error al cargar Pokémon';
        _pokemonImage = '';
        _pokemonTypes = [];
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Info'),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_pokemonImage.isNotEmpty)
              Image.network(
                _pokemonImage,
                height: 200,
              ),
            const SizedBox(height: 20),
            Text(
              _pokemonName.toUpperCase(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _pokemonTypes
                  .map((type) => Chip(
                label: Text(
                  type.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blueGrey,
              ))
                  .toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: fetchPokemon,
              child: const Text('Cargar otro Pokémon'),
            ),
          ],
        ),
      ),
    );
  }
}
