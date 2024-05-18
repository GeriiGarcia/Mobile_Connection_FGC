
import 'package:flutter/foundation.dart';

//import 'dart:js_util';
// Dart packadges

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';

import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'dart:math';

//My files
import 'current_signal_text.dart';
import 'start_stop_button.dart';
import 'main_content.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FGC_connectivity',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.green,

      ),
      home: const MyHomePage(title: 'FGC connection app'),
    );
  }
}


class _MyHomePageState extends State<MyHomePage> {

  // -------------------------------------------------- Variables
  int? _mobileSignal;
  int? _wifiSignal;
  int? _wifiSpeed;
  String? _version;
  List<List<dynamic>> dataDecibels = [];

  final _internetSignal = FlutterInternetSignal();
  Timer? _timer; 
  
  
  // FGC data
  String _dataFromApi = 'Loading...';
  String _location = 'Location: Loading...';
  List<String> _uniqueRouteShortNames = [];
  
  // Controll variables
  String signal = '0';
  int stage = 0; // 0: Start, 1: Running, 2: end
  List<bool> startDataGiven = [
    false, // line
    false, // origin
    false // direction
  ];
  bool endDataGiven = false; // destination

  // Start menu lists
  List<String> lineItems = ['---', 'S1', 'S2'];
  List<String> startStationItems = [
    '---',
    'Bellaterra',
    'Universitat Autonoma'
  ];
  List<String> directionItems = ['---', 'Sabadell', 'Barcelona'];
  List<String?> selectedChoices = ['---', '---', '---'];

  // -------------------------------------------------- Funcions
  // ---------------- Funcions connexio
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
          DateFormat('kk:mm:ss yyyy-MM-dd').format(getTime());
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
        
  // -------------------------  Fi Funcions Connexio
        
  // ignore: non_constant_identifier_names
  String getConnectivity() {
    final random = Random();

    return random.nextInt(100).toString();
  }

  void updateStage(int currentStage) {
    bool canSetState = false;

    if (startDataGiven[0] &&
        startDataGiven[1] &&
        startDataGiven[2] &&
        stage == 0) {
      canSetState = true; // Podem cambiar d'estat
    } else if (endDataGiven && stage == 2) {
      canSetState = true;
    }

    if (canSetState) {
      setState(() {
        if (currentStage == 2) {
          // Aquí pot anar lo de enviar/finalitzar el fitxer
          stage = 0;
        } else {
          stage++;
        }
      });
    } else {
      // Podriem mostrar un missatge en plan "has d'omplir els camps"
    }
  }

  void updateMainMenu(String? line, String? station, String? destination) {
    setState(() {
      selectedChoices = [line, station, destination];
    });
  }

  // -------------------------------------------------- Override

  

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<List<dynamic>> _loadData() async {
    try {
      final String scheduleRaw = await rootBundle.loadString('assets/data/schedule.json');
      final List<dynamic> scheduleList = json.decode(scheduleRaw);
      return scheduleList;
    } catch (e) {
      throw Exception('Error loading data');
    }
  }

  List<String> _getLines(List<dynamic> scheduleList) {
    final List<String> lines = scheduleList.map((item) => item['route_short_name'] as String).toList();
    return lines.toList();
  }

  List<String> getStopNamesForRoute(String line, List<dynamic> scheduleList) {
    final stops = scheduleList.where((item) => item['route_short_name'] == line)
                              .map((item) => item['stop_name'] as String)
                              .toList();
    return stops;
  }

  List<String> getDestinations(String line, List<dynamic> scheduleList) {
    final dest = scheduleList.where((item) => item['route_short_name'] == line)
                              .map((item) => item['trip_headsign'] as String)
                              .toList();
    return dest;
  }



  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('kk:mm:ss yyyy-MM-dd').format(getTime());
    List<int> dataText = getLast15Elements(dataDecibels);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        toolbarHeight: MediaQuery.of(context).size.height * 0.10,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        // Invoke "debug painting" (press "p" in the console, choose the
        // "Toggle Debug Paint" action from the Flutter Inspector in Android
        // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
        // to see the wireframe for each widget.

        children: <Widget>[
          CurrentSignalText(
            signal: signal,
          ), // mostrem la conexió actual en un text
          MainContent(
            stage: stage,
            startDataGiven: startDataGiven,
            endDataGiven: endDataGiven,
            updateState: updateMainMenu,
            lineItems: lineItems,
            startStationItems: startStationItems,
            directionItems: directionItems,
            selectedChoices: selectedChoices,
          ),
          StartStopButton(
            stage: stage,
            updateStage: updateStage,
            startDataGiven: startDataGiven,
            endDataGiven: endDataGiven,
          ),
        ],

      ),
    );
  }
}

/*
            children: [
              Text('On Version: $_version \n'),
              Text('Mobile signal: ${_mobileSignal ?? '--'} [dBm]\n'),
              Text('Wifi signal: ${_wifiSignal ?? '--'} [dBm]\n'),
              Text('Wifi speed: ${_wifiSpeed ?? '--'} Mbps\n'),
              Text('TIME: $formattedDate \n'),
              Text('VECTOR: $dataText \n'),
            ],

 */