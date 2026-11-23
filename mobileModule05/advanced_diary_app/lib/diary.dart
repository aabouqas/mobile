import 'package:advanced_diary_app/utils.dart';
import 'package:flutter/material.dart';

class Diary {
  final int? id;
  final String? title;
  final String? text;
  final int? feeling;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Diary({
    this.id,
    required this.title,
    required this.text,
    required this.feeling,
    this.createdAt,
    this.updatedAt,
  });

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      title: map['title'],
      text: map['text'],
      feeling: map['icon'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'text': text, 'icon': feeling};
  }

  IconData getIcon() => FeelingType.fromIndex(feeling).icon;

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
    int? feeling,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diary(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      feeling: feeling ?? this.feeling,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
