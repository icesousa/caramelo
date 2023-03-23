import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CarameloApp());
}

class CarameloApp extends StatelessWidget {
  const CarameloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String> _estadoconsulta;
  var ready = false;
  List<String> listFavoritas = [];

  Future<String> consultarApi() async {
    var response =
        await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));

    var data = jsonDecode(response.body) as Map<String, dynamic>;

    return data["message"];
  }

  snackBarDialog(bool remover) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 500),
        backgroundColor: remover ? Colors.red : Colors.brown,
        content: remover
            ? Row(
                children: const [
                  Text(' Doguinho removido dos favoritos  '),
                  Icon(Icons.sentiment_very_dissatisfied),
                ],
              )
            : Row(
                children: const [
                  Text('Doguinho adicionado aos favoritos  '),
                  Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  addFavorite(String dog) {
    if (listFavoritas.contains(dog)) {
      listFavoritas.remove(dog);
      listFavoritas.toList();
      snackBarDialog(true);
    } else if (!listFavoritas.contains(dog)) {
      listFavoritas.add(dog);
      snackBarDialog(false);
    }
    listFavoritas.toList();
  }

  @override
  void initState() {
    super.initState();
    _estadoconsulta = consultarApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carameloszinhos'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => FavoritosPage(
                              favoritas: listFavoritas,
                            )));
              },
              icon: const Icon(Icons.favorite)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _estadoconsulta = consultarApi();
            });
          },
          label: Row(
            children: const [
              Text('Pesquisar  '),
              Icon(Icons.pets),
            ],
          )),
      body: Center(
          child: FutureBuilder<String>(
              future: _estadoconsulta,
              builder: ((context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Erro ao Consultar API');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          addFavorite(snapshot.data!);
                        });
                      },
                      child: Image.network(snapshot.data!));
                }
                return const Placeholder();
              }))),
    );
  }
}

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key, required this.favoritas});
  final List<String> favoritas;

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

List<String> selecionadas = [];
bool isPressed = false;

class _FavoritosPageState extends State<FavoritosPage> {
  addFavorito(int index) {
    if (!selecionadas.contains(widget.favoritas[index])) {
      setState(() {
        selecionadas.add(widget.favoritas[index]);
        selecionadas.toList();
      });
    } else if (selecionadas.contains(widget.favoritas[index])) {
      setState(() {
        selecionadas.remove(widget.favoritas[index]);
        selecionadas.toList();
      });
    }
    
    selecionadas.toList();
  }

  removerFavorito(int index) {
    if (selecionadas.contains(widget.favoritas[index])) {
      setState(() {
        selecionadas.remove(widget.favoritas[index]);
      });
    }
  }

  removerDog() {
    setState(() {});
  }

  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text('Favoritos  '),
            Icon(Icons.pets),
          ],
        ),
        actions: [
          selecionadas.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      widget.favoritas
                          .removeWhere((item) => selecionadas.contains(item));
                      selecionadas.clear();
                    });

                    /* //// OUTRA FORMA DE FAZER 
                  setState(() {
                    for(int i in selecionadas.asMap().keys.toList()){
                      widget.favoritas.remove(selecionadas[i]);
                    }
                          selecionadas.clear();

                  }); 

                  */
                  },
                  icon: const Icon(Icons.delete))
              : const SizedBox(),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                scrollDirection: Axis.vertical,
                itemCount: widget.favoritas.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => selecionadas.isNotEmpty
                          ? addFavorito(index)
                          : selecionadas.toList(),
                      onLongPress: () {
                        addFavorito(index);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: selecionadas
                                          .contains(widget.favoritas[index])
                                      ? 5
                                      : 1,
                                  color: selecionadas
                                          .contains(widget.favoritas[index])? Colors.red
                                      : Colors.transparent)),
                          width: 125,
                          height: 125,
                          child: Image.network(widget.favoritas[index], fit: BoxFit.cover,), ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
