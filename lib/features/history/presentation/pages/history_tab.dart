import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(t.calculator.tab_ai_tour, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
