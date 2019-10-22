import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?key=5a091119";

void main() async {
  runApp(MaterialApp(home: Home()));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double euro, dolar;

  TextEditingController realController = new TextEditingController();
  TextEditingController dolarController = new TextEditingController();
  TextEditingController euroController = new TextEditingController();

  void cleanFields() {
    euroController.text = "";
    dolarController.text = "";
    realController.text = "";
  }

  void realChange(String value) {
    if (value.isEmpty) {
      cleanFields();
    } else {
      double real = double.parse(value);
      euroController.text = (real / euro).toStringAsFixed(2);
      dolarController.text = (real / dolar).toStringAsFixed(2);
    }
  }

  void dolarChange(String value) {
    if (value.isEmpty) {
      cleanFields();
    } else {
      double real = double.parse(value) * dolar;
      euroController.text = (real / euro).toStringAsFixed(2);
      realController.text = (real).toStringAsFixed(2);
    }
  }

  void euroChange(String value) {
    if (value.isEmpty) {
      cleanFields();
    } else {
      double real = double.parse(value) * euro;
      dolarController.text = (real / dolar).toStringAsFixed(2);
      realController.text = (real).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.yellowAccent,
            title: Text(
              "Convesor de Moedas",
              style: TextStyle(color: Colors.black),
            )),
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text('Carregando dados ...',
                      style: TextStyle(color: Colors.amber, fontSize: 45),
                      textAlign: TextAlign.center),
                );

              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro na conexão, tente novamente em breve.',
                        style: TextStyle(color: Colors.amber, fontSize: 45),
                        textAlign: TextAlign.center),
                  );
                } else {
                  dolar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.attach_money,
                          size: 150,
                          color: Colors.amber,
                        ),
                        bildMoneyField(
                            "Reais", "R\$ ", realController, realChange),
                        Divider(),
                        bildMoneyField(
                            "Dolar", "US\$ ", dolarController, dolarChange),
                        Divider(),
                        bildMoneyField(
                            "Euro", "£ ", euroController, euroChange),
                        Divider(),
                      ],
                    ),
                  );
                }
            }
          },
        ));
  }
}

Widget bildMoneyField(
    String label, String prefix, TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: function,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 30, color: Colors.black),
        border: OutlineInputBorder(),
        prefixText: prefix),
  );
}