import 'package:flutter/foundation.dart';
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

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // -------------------------------------------------- Variables
  // Variables de connexió
  int? _mobileSignal;
  int? _wifiSignal;
  int? _wifiSpeed;
  String? _version;
  List<List<dynamic>> dataDecibels = [];

  final _internetSignal = FlutterInternetSignal();
  Timer? _timer;
  bool started = false;
  // FGC data
  List<dynamic> scheduleList = [];

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

  List<String> lineItems = ['---'];
  List<String> startStationItems = ['---'];
  List<String> directionItems = ['---'];
  List<String?> sel_values = [
    '---', // linea (S1, S2,...)
    '---', //origin station
    '---' // direction
  ];
  String selEndValue = '---'; // estació final
  // -------------------------------------------------- Funcions
  // ---------------- Funcions connexio

  void _startPeriodicUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getInternetSignal();
    });
  }

  void _stopPeriodicUpdate() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
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

      String formattedDate = DateFormat('kk:mm:ss').format(getTime());
      String formattedDay = DateFormat('yyyy-MM-dd').format(getTime());
      dataDecibels.add([formattedDay, formattedDate, _wifiSignal!]);
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
    return File('$path/$archivo.JSON');
  }

  Future<File> writeData(List<List<dynamic>> list) async {
    // Convertir la lista de listas a una lista de mapas
    final file = await _localFile;

    // Convertir la lista a una cadena JSON
    //final jsonString = json.encode(list);

    List<Map<String, dynamic>> listAsMap = list.map((sublist) {
      return {
        "time": sublist[1],
        "date": sublist[0],
        "connection": sublist[2],
      };
    }).toList();

    // Convertir la lista de mapas a una cadena JSON
    String jsonString = jsonEncode(listAsMap);

    // Escribir la cadena JSON en el archivo
    return file.writeAsString(jsonString);
  }

  void finalSave(List<List<dynamic>> list, String linea, String origen, String destino, String direccion, String t_inicio) async {
    final file = await _localFile;
    

    Map<String, String> opciones = {
      'linea': linea,
      'origen': origen,
      'destino': destino,
      'direccion': direccion,
      't_inicio': t_inicio
    };

    Map<String, dynamic> jsonMap = {'options': opciones, 'data': list};

    // Convertir el mapa a una cadena JSON
    String jsonString = jsonEncode(jsonMap);

    // Escribir la cadena JSON en el archivo
    file.writeAsString(jsonString);
  }

  List<int> getLast15Elements(List<List<dynamic>> list) {
    if (list.length > 15) {
      list = list.sublist(list.length - 15);
    }

    // Extraer el segundo valor de cada sublista.
    return list.map((sublist) => sublist[2] as int).toList();
  }

  // -------------------------  Fi Funcions Connexio

  void updateStage(int currentStage) {
    bool canSetState = false;

    if (startDataGiven[0] &&
        startDataGiven[1] &&
        startDataGiven[2] &&
        stage == 0) {
      canSetState = true; // Podem cambiar d'estat
      endDataGiven = false;
      selEndValue = '---';
      _startPeriodicUpdate();
    } else if (stage == 1) {
      _stopPeriodicUpdate();
      canSetState = true;
    } else if (endDataGiven && stage == 2) {
      String linea = sel_values[0]!;
      String origen = sel_values[1]!;
      String destino = selEndValue;
      String direccion = sel_values[2]!;
      //String t_inicio = getTimeForFile();
      String t_inicio = dataDecibels[0][1].toString();
      
      finalSave(dataDecibels, linea, origen, destino, direccion, t_inicio);
      startDataGiven[0] = false;
      startDataGiven[1] = false;
      startDataGiven[2] = false;
      canSetState = true;
      sel_values = ['---', '---', '---'];
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

  void updateStartState(
      String? line, String? station, String? destination, int nou) {
    if (nou == 0) {
      startDataGiven[0] = true;
      startDataGiven[1] = false;
      startDataGiven[2] = false;
      setState(() {
        sel_values = [line!, '---', '---'];
      });
    } else if (nou == 1 && startDataGiven[0]) {
      startDataGiven[1] = true;
      startDataGiven[2] = false;
      setState(() {
        sel_values = [line!, station!, '---'];
      });
    } else if (nou == 2 && startDataGiven[0] && startDataGiven[1]) {
      startDataGiven[2] = true;
      setState(() {
        sel_values = [line!, station!, destination!];
      });
    }
  }

  void updateEndState(String? endValue) {
    endDataGiven = true;
    setState(() {
      selEndValue = endValue!;
    });
  }

  // ----------------------------------------------- FGC
  Future<void> _loadData() async {
    try {
      final String scheduleRaw =
          await rootBundle.loadString('assets/data/schedule.json');
      scheduleList = json.decode(scheduleRaw);
    } catch (e) {
      throw Exception('Error loading data');
    }
  }

  // Funcions que recopilen les dades de FGC
  List<String> getLines(List<dynamic> scheduleList) {
    final List<String> lines = scheduleList
        .map((item) => item['route_short_name'] as String)
        .toSet()
        .toList();
    lines.insert(0, '---');
    return lines;
  }

  List<String> getStopNamesForRoute(String line, List<dynamic> scheduleList) {
    final List<String> stops = scheduleList
        .where((item) => item['route_short_name'] == line)
        .map((item) => item['stop_name'] as String)
        .toSet()
        .toList();
    stops.insert(0, '---');
    return stops;
  }

  List<String> getDestinations(String line, List<dynamic> scheduleList) {
    final List<String> dest = scheduleList
        .where((item) => item['route_short_name'] == line)
        .map((item) => item['trip_headsign'] as String)
        .toSet()
        .toList();
    dest.insert(0, '---');
    return dest;
  }

  // -------------------------------------------------- Overrides
  late Future<void> _dataLoadingFuture;
  @override
  void initState() {
    super.initState();
    _getPlatformVersion();
    //_startPeriodicUpdate();
    _dataLoadingFuture = _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('kk:mm:ss yyyy-MM-dd').format(getTime());
    List<int> dataText = getLast15Elements(dataDecibels);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
              fontSize: 30, color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.10,
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<void>(
        future: _dataLoadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.

              children: <Widget>[
                CurrentSignalText(
                  signal: _wifiSignal.toString(),
                ), // mostrem la conexió actual en un text

                MainContent(
                  stage: stage,
                  startDataGiven: startDataGiven,
                  endDataGiven: endDataGiven,
                  updateStartState: updateStartState,
                  updateEndState: updateEndState,
                  lineItems: getLines(scheduleList),
                  startStationItems:
                      getStopNamesForRoute(sel_values[0]!, scheduleList),
                  directionItems: getDestinations(sel_values[0]!, scheduleList),
                  selectedChoices: sel_values,
                  dataConnection: dataText,
                  selectedEndChoice: selEndValue,
                ),
                StartStopButton(
                  stage: stage,
                  updateStage: updateStage,
                  startDataGiven: startDataGiven,
                  endDataGiven: endDataGiven,
                ),
              ],
            );
          }
        },
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