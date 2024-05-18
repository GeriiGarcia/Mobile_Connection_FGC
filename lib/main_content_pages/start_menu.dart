// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class StartMenu extends StatelessWidget {
  List<bool> startDataGiven;

  StartMenu({
    required this.startDataGiven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      color: Colors.blue,
      child: Center(
          child: Column(
        children: [],
      )),
    );
  }
}
