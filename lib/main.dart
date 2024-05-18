//import 'dart:js_util';
// Dart packadges
import 'package:flutter/material.dart';

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

  // This widget is the root of your application.
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

  List<String> lineItems = ['S1', 'S2'];
  List<String> startStationItems = [
    '---',
    'Bellaterra',
    'Universitat Autonoma'
  ];
  List<String> directionItems = ['---', 'Sabadell', 'Barcelona'];
  List<String?> sel_values = ['---', '---', '---'];

  // -------------------------------------------------- Funcions
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
      sel_values = [line!, station!, destination!];
    });
  }

  // -------------------------------------------------- Override

  late Future<void> _dataLoadingFuture;

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String scheduleRaw = await rootBundle.loadString('assets/data/schedule.json');
      scheduleList = json.decode(scheduleRaw);
    } catch (e) {
      throw Exception('Error loading data');
    }
  }

  List<String> getLines(List<dynamic> scheduleList) {
    final List<String> lines = scheduleList.map((item) => item['route_short_name'] as String).toSet().toList();
    lines.insert(0, '---');
    return lines;
  }

  List<String> getStopNamesForRoute(String line, List<dynamic> scheduleList) {
    final List<String> stops = scheduleList.where((item) => item['route_short_name'] == line)
                              .map((item) => item['stop_name'] as String)
                              .toSet()
                              .toList();
    stops.insert(0, '---');
    return stops;
  }

  List<String> getDestinations(String line, List<dynamic> scheduleList) {
    final List<String> dest = scheduleList.where((item) => item['route_short_name'] == line)
                              .map((item) => item['trip_headsign'] as String)
                              .toSet()
                              .toList();
    dest.insert(0, '---');
    return dest;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        toolbarHeight: MediaQuery.of(context).size.height * 0.10,
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
                  signal: signal,
                ), // mostrem la conexió actual en un text
              
                MainContent(
                  stage: stage,
                  startDataGiven: startDataGiven,
                  endDataGiven: endDataGiven,
                  updateState: updateMainMenu,
                  lineItems: getLines(scheduleList),
                  startStationItems: getStopNamesForRoute(sel_values[0]!, scheduleList),
                  directionItems: getDestinations(sel_values[0]!, scheduleList),
                  selectedChoices: sel_values,
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