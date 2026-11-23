import 'package:flutter/material.dart';

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
      return Colors.red;
    default:
      return Colors.grey;
  }
}
