import 'package:flutter/material.dart';

class MainContent extends StatelessWidget {
  bool _start_pressed = false;

  MainContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      color: Colors.red,
    );
  }
}
