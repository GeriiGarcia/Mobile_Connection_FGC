import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';

import 'package:intl/intl.dart';

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
  DateTime now = DateTime.now();
  

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

      String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
      dataDecibels.add([formattedDate, _wifiSignal!]);
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
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
              Text('VECTOR: $dataDecibels \n'),
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
