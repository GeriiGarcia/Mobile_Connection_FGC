//import 'dart:js_util';
// Dart packadges
import 'package:flutter/material.dart';
import 'dart:math';

//My files
import 'current_signal_text.dart';
import 'start_stop_button.dart';
import 'main_content.dart';

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
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
