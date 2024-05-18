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
  String _signal = '0';
  bool startPressed = false;

  // ------------------------------------ Funcions
  // ignore: non_constant_identifier_names
  String _get_connectivity() {
    final random = Random();

    return random.nextInt(100).toString();
  }

  void _StartRecording() {
    setState(() {
      startPressed = !startPressed;
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _signal = _get_connectivity();
    });
  }

  // ------------------------------------ Override
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
            signal: _signal,
          ), // mostrem la conexió actual en un text
          MainContent(),
          StartStopButton(
              updateStart: _StartRecording, startPressed: startPressed),
        ],
      ),
    );
  }
}
