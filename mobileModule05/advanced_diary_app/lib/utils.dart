import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

Color getIconColor(String? icon) {
  switch (icon) {
    case 'very_satisfied':
      return Colors.green;
    case 'satisfied':
      return Colors.lightGreen;
    case 'neutral':
      return Colors.grey;
    case 'dissatisfied':
      return Colors.orange;
    case 'very_dissatisfied':
      return Colors.deepOrange;
    case 'angry':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

const Map<String, IconData> feelingIcons = {
  'very_satisfied': Icons.sentiment_very_satisfied,
  'satisfied': Icons.sentiment_satisfied,
  'neutral': Icons.sentiment_neutral,
  'dissatisfied': Icons.sentiment_dissatisfied,
  'very_dissatisfied': Icons.sentiment_very_dissatisfied,
  'angry': Symbols.sentiment_extremely_dissatisfied,
};
