import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CarameloApp());
}

class CarameloApp extends StatelessWidget {
  const CarameloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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
        duration: Duration(milliseconds: 500),
        backgroundColor: remover? Colors.red : Colors.brown,
        content: remover
            ? Text('Removido dos favoritos')
            : Text('Adicionado aos favoritos'),
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
        title: Text('Carameloszinhos'),
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
              icon: Icon(Icons.favorite)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _estadoconsulta = consultarApi();
            });
          },
          label: Text('Pesquisar')),
      body: Center(
          child: FutureBuilder<String>(
              future: _estadoconsulta,
              builder: ((context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Erro ao Consultar API');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          addFavorite(snapshot.data!);
                          print(listFavoritas);
                        });
                      },
                      child: Image.network(snapshot.data!));
                }
                return Placeholder();
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

class _FavoritosPageState extends State<FavoritosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: Column(
        children: [
          Flexible(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: widget.favoritas.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onDoubleTap: () {
                        
                      },
                      child: Container(
                          width: 125,
                          height: 125,
                          child: Image.network(widget.favoritas[index])),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
