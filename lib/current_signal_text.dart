// current signal container containing text t
import 'package:flutter/material.dart';
import 'dart:math';

// ignore: use_key_in_widget_constructors
class CurrentSignalText extends StatelessWidget {
  // ignore: non_constant_identifier_names
  String _get_connectivity() {
    final random = Random();

    return random.nextInt(100).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 30.0),
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
                _get_connectivity(),
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
