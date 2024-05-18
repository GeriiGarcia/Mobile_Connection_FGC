// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class StartMenu extends StatelessWidget {
  List<bool> startDataGiven;
  final Function(String?, String?, String?, int) updateState;
  List<String> lineItems;
  List<String> startStationItems;
  List<String> directionItems;
  List<String?> selectedChoices;

  StartMenu({
    required this.startDataGiven,
    required this.updateState,
    required this.lineItems,
    required this.startStationItems,
    required this.directionItems,
    required this.selectedChoices,
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
                value: selectedChoices[0],
                items: lineItems.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? choice) {
                  updateState(
                      choice, selectedChoices[1], selectedChoices[2], 0);
                }),
          ),
          SizedBox(
            width: 300, // Set the width of the button
            height: 50,
            child: DropdownButton<String>(
                value: selectedChoices[1],
                items: startStationItems.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? choice) {
                  updateState(
                      selectedChoices[0], choice, selectedChoices[2], 1);
                }),
          ),
          SizedBox(
            width: 300, // Set the width of the button
            height: 50,
            child: DropdownButton<String>(
                value: selectedChoices[2],
                items: directionItems.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? choice) {
                  updateState(
                      selectedChoices[0], selectedChoices[1], choice, 2);
                }),
          ),
        ],
      )),
    );
  }
}
