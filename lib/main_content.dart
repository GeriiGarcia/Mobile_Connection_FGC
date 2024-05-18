// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:flutter_application_1/main_content_pages/start_menu.dart';
import 'package:flutter_application_1/main_content_pages/running_menu.dart';
import 'package:flutter_application_1/main_content_pages/end_menu.dart';

class MainContent extends StatelessWidget {
  int stage;
  List<bool> startDataGiven;
  bool endDataGiven;
  final Function(String?, String?, String?, int) updateStartState;
  final Function(String?) updateEndState;
  List<String> lineItems;
  List<String> startStationItems;
  List<String> directionItems;
  List<String?> selectedChoices;
  String selectedEndChoice;

  MainContent({
    required this.stage,
    required this.startDataGiven,
    required this.endDataGiven,
    required this.updateStartState,
    required this.updateEndState,
    required this.lineItems,
    required this.startStationItems,
    required this.directionItems,
    required this.selectedEndChoice,
    required this.selectedChoices,
  });

  Widget getCurrentMenu(BuildContext context) {
    switch (stage) {
      case 0:
        return StartMenu(
          startDataGiven: startDataGiven,
          updateState: updateStartState,
          lineItems: lineItems,
          startStationItems: startStationItems,
          directionItems: directionItems,
          selectedChoices: selectedChoices,
        );
      case 1:
        return RunningMenu();
      case 2:
        return EndMenu(
          endDataGiven: endDataGiven,
          selectedEndChoice: selectedEndChoice,
          startStationItems: startStationItems,
          updateState: updateEndState,
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
