// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class CurrentSignalText extends StatelessWidget {
  final String signal;

  const CurrentSignalText({required this.signal});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.10, // Set the height to 20% of the screen height
      color: Colors.grey.shade100,
      //padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 30.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 5.0),
              child: const Text(
                'Current signal: ',
                style: TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 5.0),
              child: Text(
                signal,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 5.0),
              child: const Text(
                '[dBm]',
                style: TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
