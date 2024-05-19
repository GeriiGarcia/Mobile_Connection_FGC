// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';

import 'package:flutter/material.dart';

class RunningMenu extends StatelessWidget {
  List<int> dataConnection;

  // Posar aquí els requeriments, variables i tal quan toqui

  RunningMenu({required this.dataConnection, });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dataConnection.toString()),
        ],
      ),
    );
  }
}
