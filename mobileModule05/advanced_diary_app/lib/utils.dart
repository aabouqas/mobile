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

enum FeelingType {
  verySatisfied,
  satisfied,
  neutral,
  dissatisfied,
  veryDissatisfied,
  angry;

  IconData get icon => switch (this) {
    .verySatisfied => Icons.sentiment_very_satisfied,
    .satisfied => Icons.sentiment_satisfied,
    .neutral => Icons.sentiment_neutral,
    .dissatisfied => Icons.sentiment_dissatisfied,
    .veryDissatisfied => Icons.sentiment_very_dissatisfied,
    .angry => Symbols.sentiment_extremely_dissatisfied,
  };

  Color get color => switch (this) {
    .verySatisfied => Colors.green,
    .satisfied => Colors.lightGreen,
    .neutral => Colors.grey,
    .dissatisfied => Colors.orange,
    .veryDissatisfied => Colors.deepOrange,
    .angry => Colors.red,
  };

  static FeelingType fromIndex(int? index) {
    if (index == null || index < 0 || index >= FeelingType.values.length) {
      return .neutral;
    }
    return .values[index];
  }
}
