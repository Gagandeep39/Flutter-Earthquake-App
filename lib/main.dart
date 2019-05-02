import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

final apiUrl =
    "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Quake"),
          centerTitle: true,
        ),
        body: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasError)
                  return Center(
                      child: Text(
                          "Error\n ${snapshot.error}")); //make sure if condition has '.hasError' and not '.error'
                else
                  return ListDataWidget(snapshot.data);
            }
          },
          future: _fetchJsonData(),
        ),
      ),
    );
  }

  _fetchJsonData() async {
    http.Response response = await http.get(apiUrl);
    return jsonDecode(response.body);
  }
}

class ListDataWidget extends StatelessWidget {
  final _data;
  ListDataWidget(this._data);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.all(8.0),
        physics: BouncingScrollPhysics(),
        itemCount: _data['features'].length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(convertToHumanReadableForm(
                _data['features'][index]['properties']['time'])),
            subtitle: Text(_data['features'][index]['properties']['place']),
            onTap: () {
              _showAlertDialogue(
                  context, _data['features'][index]['properties']['place']);
            },
            leading: CircleAvatar(
              child: Text(
                _data['features'][index]['properties']['mag'].toString() + "",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor:
                  _getColor(_data['features'][index]['properties']['mag']),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
            Divider() //Divider must always be returned
        );
  }

  String convertToHumanReadableForm(data) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(data);

    var format = new DateFormat.yMMMd().add_jm();
    var dateString = format.format(date);
    return dateString.toString();
  }

  _getColor(num data) {
    int intData = data.toInt();
    switch (intData) {
      case 0:
      case 1:
        return Colors.green;
        break;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orangeAccent;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
        break;
      default:
        return Colors.red;
    }
  }

  void _showAlertDialogue(BuildContext context, data) {
    var alertDialog = AlertDialog(
      title: Text("Alert Dialog"),
      content: Text("$data"),
      actions: <Widget>[
        RaisedButton(
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK"),
        ),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"))
      ],
    );

    showDialog(context: context, child: alertDialog);
  }
}
