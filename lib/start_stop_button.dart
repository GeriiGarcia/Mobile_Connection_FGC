// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class StartStopButton extends StatelessWidget {
  bool startPressed;
  final Function() updateStart;

  StartStopButton({required this.startPressed, required this.updateStart});

  String changeButtonText() {
    if (startPressed) return 'Stop recording';
    return 'Start recording';
  }

  Color changeButtonColor() {
    if (startPressed) return Colors.red.shade200;
    return Colors.green;
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
              updateStart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: changeButtonColor(),
            ),
            child:
                Text(changeButtonText(), style: const TextStyle(fontSize: 15)),
          ),
        ),
      ),
    );
  }
}
