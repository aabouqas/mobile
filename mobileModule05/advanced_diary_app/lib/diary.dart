import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class Diary {
  final int? id;
  final String? title;
  final String? text;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Diary({
    this.id,
    required this.title,
    required this.text,
    required this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      title: map['title'],
      text: map['text'],
      icon: map['icon'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'text': text, 'icon': icon};
  }

  IconData getIcon() {
    switch (icon) {
      case 'very_satisfied':
        return Icons.sentiment_very_satisfied;
      case 'satisfied':
        return Icons.sentiment_satisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'dissatisfied':
        return Icons.sentiment_dissatisfied;
      case 'very_dissatisfied':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Symbols.sentiment_extremely_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String getFormattedDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    var date = updatedAt ?? createdAt;
    if (date == null) return '';
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Diary copyWith({
    int? id,
    String? title,
    String? text,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diary(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
