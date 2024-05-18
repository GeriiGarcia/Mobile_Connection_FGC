import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _dataFromApi = 'Loading...';
  String _location = 'Location: Loading...';
  List<String> _uniqueRouteShortNames = [];

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

/*
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    } 

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
    });
  }


  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://api.example.com/data'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _dataFromApi = jsonData['message'];
      });
    } else {
      setState(() {
        _dataFromApi = 'Failed to load data';
      });
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text('Unique Route Short Names:'),
            _uniqueRouteShortNames.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _uniqueRouteShortNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_uniqueRouteShortNames[index]),
                        );
                      },
                    ),
                  )
                : const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
