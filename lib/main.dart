import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';

import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _mobileSignal;
  int? _wifiSignal;
  int? _wifiSpeed;
  String? _version;
  List<List<dynamic>> dataDecibels = [];

  final _internetSignal = FlutterInternetSignal();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getPlatformVersion();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getInternetSignal();
    });
  }

  Future<void> _getPlatformVersion() async {
    try {
      _version = await _internetSignal.getPlatformVersion();
    } on PlatformException {
      if (kDebugMode) print('Error get Android version.');
      _version = null;
    }
    setState(() {});
  }

  DateTime getTime() {
    DateTime now = DateTime.now();
    return now;
  }

  DateTime nouFile = DateTime.now();
  String getTimeForFile() {
    String formattedDate = DateFormat('kk:mm:ss').format(nouFile);
    return formattedDate;
  }

  Future<void> _getInternetSignal() async {
    int? mobile;
    int? wifi;
    int? wifiSpeed;
    try {
      mobile = await _internetSignal.getMobileSignalStrength();
      wifi = await _internetSignal.getWifiSignalStrength();
      wifiSpeed = await _internetSignal.getWifiLinkSpeed();
    } on PlatformException {
      if (kDebugMode) print('Error get internet signal.');
    }
    setState(() {
      _mobileSignal = mobile;
      _wifiSignal = wifi;
      _wifiSpeed = wifiSpeed;

      String formattedDate =
          DateFormat('kk:mm:ss \n EEE d MMM').format(getTime());
      dataDecibels.add([formattedDate, _wifiSignal!]);
      writeData(dataDecibels);
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String archivo = getTimeForFile();
    return File('$path/$archivo.txt');
  }

  Future<File> writeData(List<List<dynamic>> list) async {
    // Convertir la lista de listas a una lista de mapas
    final file = await _localFile;

    // Convertir la lista a una cadena JSON
    //final jsonString = json.encode(list);

    List<Map<String, dynamic>> listAsMap = list.map((sublist) {
      return {
        "string": sublist[0],
        "int": sublist[1],
      };
    }).toList();

    // Convertir la lista de mapas a una cadena JSON
    String jsonString = jsonEncode(listAsMap);

    // Escribir la cadena JSON en el archivo
    return file.writeAsString(jsonString);
  }

  List<int> getLast15Elements(List<List<dynamic>> list) {
      if (list.length > 15) {
      list = list.sublist(list.length - 15);
    }

    // Extraer el segundo valor de cada sublista.
    return list.map((sublist) => sublist[1] as int).toList();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('kk:mm:ss \n EEE d MMM').format(getTime());
    List<int> dataText = getLast15Elements(dataDecibels);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Internet Signal Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('On Version: $_version \n'),
              Text('Mobile signal: ${_mobileSignal ?? '--'} [dBm]\n'),
              Text('Wifi signal: ${_wifiSignal ?? '--'} [dBm]\n'),
              Text('Wifi speed: ${_wifiSpeed ?? '--'} Mbps\n'),
              Text('TIME: $formattedDate \n'),
              Text('VECTOR: $dataText \n'),
              ElevatedButton(
                onPressed: _getInternetSignal,
                child: const Text('Get internet signal'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
