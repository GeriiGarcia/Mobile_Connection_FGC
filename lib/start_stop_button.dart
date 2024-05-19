// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class StartStopButton extends StatelessWidget {
  int stage;
  List<bool> startDataGiven;
  bool endDataGiven;
  final Function(int) updateStage;
  

  StartStopButton(
      {required this.stage,
      required this.updateStage,
      required this.startDataGiven,
      required this.endDataGiven,});

  String changeButtonText() {
    switch (stage) {
      case 0:
        return 'Start Recording';
      case 1:
        return 'Stop recording';
      case 2:
        return 'End recording';
      default:
        return 'An error has occured';
    }
  }

  Color changeButtonColor() {
    if (startDataGiven[0] &&
        startDataGiven[1] &&
        startDataGiven[2] &&
        stage == 0) {
      return Colors.green; // Podem començar la simulació
    } else if (stage == 0) {
      return Colors.grey.shade300; // Falten emplenar camps
    } else if (stage == 1) {
      return Colors.red.shade300; // Podem acabar la recopilació
    } else if (stage == 2 && endDataGiven) {
      return Colors.green; // Podem finalitzar
    } else {
      return Colors.grey.shade300; // Falten emplenar camps
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      height: MediaQuery.of(context).size.height *
          0.15, // Set the height to 20% of the screen height
      color: Colors.grey.shade100,
      child: Center(
        child: SizedBox(
          width: 200, // Set the width of the button
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Define the action to be taken when the button is pressed
              updateStage(stage);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: changeButtonColor(),
            ),
            child: Text(changeButtonText(),
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
          ),
        ),
      ),
    );
  }
}
