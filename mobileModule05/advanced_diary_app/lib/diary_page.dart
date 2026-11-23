import 'package:advanced_diary_app/diary.dart';
import 'package:advanced_diary_app/diary_details_page.dart';
import 'package:advanced_diary_app/supabase_service.dart';
import 'package:advanced_diary_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final user = Supabase.instance.client.auth.currentUser;
  bool isLogouting = false;
  Future<List<Diary>>? futureDiaries;
  Future<Map<String, int>>? weeklyFeelings;
  int _diaryLength = 0;

  @override
  void initState() {
    super.initState();
    futureDiaries = _fetchDiaries();
    weeklyFeelings = _fetchWeeklyFeelings();
  }

  Future<List<Diary>> _fetchDiaries() async {
    return await SupabaseService.getUserDiaries().then((result) {
      if (mounted) {
        setState(() {
          _diaryLength = result.length;
        });
      }
      return result.take(2).toList();
    });
  }

  Future<Map<String, int>> _fetchWeeklyFeelings() async =>
      await SupabaseService.getUserWeeklyFeelings() ?? {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: _buildProfileHeader(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 12,
              children: [_buildDiriesList(), _buildWeeklyFeelingsSection()],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Diary"),
        icon: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryDetailsPage(diary: null),
            ),
          );
          setState(() {
            futureDiaries = _fetchDiaries();
            weeklyFeelings = _fetchWeeklyFeelings();
          });
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      mainAxisAlignment: .center,
      spacing: 12,
      children: [
        Container(
          padding: .all(2),
          decoration: BoxDecoration(color: Colors.blue, shape: .circle),
          child: CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(
              user?.userMetadata?['avatar_url'] ?? "",
            ),
          ),
        ),
        Expanded(
          child: Text(
            user?.userMetadata?['name'] ?? '',
            maxLines: 3,
            softWrap: true,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: IconButton(
            onPressed: () async {
              _setLogouting(true);
              await SupabaseService.logout();
              _setLogouting(false);
            },
            icon: isLogouting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Icon(Icons.logout, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildDiriesList() {
    return Container(
      padding: .all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: .1),
        borderRadius: .circular(12),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const .only(bottom: 16),
            child: Text(
              "Your last diary entries",
              style: TextStyle(
                fontSize: 20,
                fontWeight: .bold,
                color: Colors.blue,
              ),
            ),
          ),
          FutureBuilder(
            future: futureDiaries,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading diaries'));
              } else {
                final diaries = snapshot.data!;
                if (diaries.isEmpty) {
                  return Center(child: Text('No diaries found'));
                }
                return ListView.separated(
                  separatorBuilder: (ctx, index) => SizedBox(height: 8),
                  itemCount: diaries.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final diary = diaries[index];
                    return Material(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: .circular(12),
                      child: ListTile(
                        leading: Container(
                          padding: .all(4),
                          decoration: BoxDecoration(
                            color: getIconColor(diary.icon)
                                .withValues(alpha: .2),
                            shape: .circle,
                          ),
                          child: Icon(
                            diary.getIcon(),
                            color: getIconColor(diary.icon),
                          ),
                        ),
                        trailing: Text(diary.getFormattedDate()),
                        title: Text(
                          diary.title ?? 'No Title',
                          style: TextStyle(fontWeight: .bold),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DiaryDetailsPage(diary: diary),
                            ),
                          );
                          setState(() {
                            futureDiaries = _fetchDiaries();
                            weeklyFeelings = _fetchWeeklyFeelings();
                          });
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyFeelingsSection() {
    return Container(
      padding: .all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: .1),
        borderRadius: .circular(12),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const .only(bottom: 16),
            child: Text(
              "Your feel for your last $_diaryLength entries",
              style: TextStyle(
                fontSize: 20,
                fontWeight: .bold,
                color: Colors.blue,
              ),
            ),
          ),
          FutureBuilder(
            future: weeklyFeelings,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading diaries'));
              } else {
                final feelings = snapshot.data!;
                if (feelings.isEmpty) {
                  return Center(child: Text('No diaries found'));
                }
                return ListView.separated(
                  separatorBuilder: (ctx, index) => SizedBox(height: 6),
                  itemCount: 6,
                  shrinkWrap: true,
                  padding: .only(bottom: 80),
                  itemBuilder: (context, index) {
                    final iconEntry = feelingIcons.entries.elementAt(index);
                    return Material(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: .circular(12),
                      child: Container(
                        padding: .all(10),
                        decoration: BoxDecoration(
                          color: getIconColor(iconEntry.key)
                              .withValues(alpha: .1),
                        ),
                        child: Row(
                          spacing: 8,
                          children: [
                            Container(
                              padding: .all(4),
                              decoration: BoxDecoration(
                                color: getIconColor(iconEntry.key)
                                    .withValues(alpha: .2),
                                shape: .circle,
                              ),
                              child: Icon(
                                iconEntry.value,
                                color: getIconColor(iconEntry.key),
                              ),
                            ),
                            Text(
                              '${feelings[iconEntry.key.toLowerCase()]}%',
                              maxLines: 2,
                              overflow: .ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _setLogouting(bool value) => setState(() => isLogouting = value);
}
