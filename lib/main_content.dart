// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:flutter_application_1/main_content_pages/start_menu.dart';
import 'package:flutter_application_1/main_content_pages/running_menu.dart';
import 'package:flutter_application_1/main_content_pages/end_menu.dart';

class MainContent extends StatelessWidget {
  int stage;
  List<bool> startDataGiven;
  bool endDataGiven;

  MainContent(
      {required this.stage,
      required this.startDataGiven,
      required this.endDataGiven});

  Widget getCurrentMenu(BuildContext context) {
    switch (stage) {
      case 0:
        return StartMenu(startDataGiven: startDataGiven);
      case 1:
        return RunningMenu();
      case 2:
        return EndMenu(
          endDataGiven: endDataGiven,
        );
      default: // Error page
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          color: Colors.red,
          child: const Text('Ups, there has been an error'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return getCurrentMenu(context);
  }
}
