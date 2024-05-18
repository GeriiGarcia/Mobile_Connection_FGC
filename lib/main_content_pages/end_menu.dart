// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class EndMenu extends StatelessWidget {
  bool endDataGiven;
  String selectedEndChoice;
  List<String> startStationItems;
  final Function(String?) updateState;

  EndMenu({
    required this.endDataGiven,
    required this.selectedEndChoice,
    required this.startStationItems,
    required this.updateState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      color: Colors.grey.shade100,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300, // Set the width of the button
            height: 50,
            child: DropdownButton<String>(
                value: selectedEndChoice,
                items: startStationItems.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? choice) {
                  updateState(
                    choice,
                  );
                }),
          ),
        ],
      )),
    );
  }
}
