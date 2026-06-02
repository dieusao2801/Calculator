import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';

class ConverterTab extends StatelessWidget {
  const ConverterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        t.calculator.tab_converter,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}