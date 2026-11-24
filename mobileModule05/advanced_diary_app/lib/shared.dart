import 'package:advanced_diary_app/diary.dart';
import 'package:advanced_diary_app/diary_details_page.dart';
import 'package:advanced_diary_app/supabase_service.dart';
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

class DiariesList extends StatelessWidget {
  // final List<Diary> _diaries;
  final Future<List<Diary>>? _futureDiaries;
  final bool dateEnabled;
  final String? title;

  const DiariesList({
    super.key,
    required this._futureDiaries,
    this.title,
    this.dateEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: .15),
        borderRadius: .circular(12),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          if (title != null)
            Padding(
              padding: const .only(bottom: 16),
              child: Text(
                "$title",
                textAlign: .center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: Colors.blue,
                ),
              ),
            ),
          FutureBuilder(
            future: _futureDiaries,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              } else if (snapshot.hasError) {
                return EmptyState(
                  title: 'Error',
                  description: 'Something went wrong.',
                  icon: Symbols.error,
                );
              }
              final diaries = snapshot.data ?? [];
              if (diaries.isEmpty) {
                return EmptyState(
                  title: 'No Diaries',
                  description: 'You have no diaries yet.',
                  icon: Icons.list_rounded,
                );
              }
              return ListView.separated(
                separatorBuilder: (ctx, index) => SizedBox(height: 8),
                itemCount: diaries.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final diary = diaries[index];
                  return Material(
                    clipBehavior: .antiAlias,
                    borderRadius: .circular(12),
                    child: ListTile(
                      leading: Container(
                        padding: .all(2),
                        decoration: BoxDecoration(
                          color: FeelingType.fromIndex(diary.feeling).color
                              .withValues(alpha: .2),
                          shape: .circle,
                        ),
                        child: Icon(
                          diary.getIcon(),
                          color: FeelingType.fromIndex(diary.feeling).color,
                        ),
                      ),
                      trailing: dateEnabled
                          ? Text(diary.getFormattedDate())
                          : SizedBox.shrink(),
                      title: Text(
                        diary.title ?? 'No Title',
                        style: TextStyle(fontWeight: .bold, fontSize: 14),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DiaryDetailsPage(diary: diary),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: .bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: .all(12),
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
