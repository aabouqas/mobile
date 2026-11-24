import 'package:advanced_diary_app/diary.dart';
import 'package:advanced_diary_app/diary_details_page.dart';
import 'package:advanced_diary_app/supabase_service.dart';
import 'package:advanced_diary_app/shared.dart';
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
  Future<List<Diary>>? _futureDiaries;
  Future<Map<FeelingType, int>>? _feelingsRate;
  int _diaryLength = 0;

  @override
  void initState() {
    super.initState();
    _futureDiaries = _fetchDiaries();
    _feelingsRate = _fetchFeelingsRate();
    SupabaseService.refreshNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    SupabaseService.refreshNotifier.removeListener(_loadData);
    super.dispose();
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

  Future<Map<FeelingType, int>> _fetchFeelingsRate() async =>
      await SupabaseService.getFeelingRates() ?? {};

  void _loadData() {
    setState(() {
      _futureDiaries = _fetchDiaries();
      _feelingsRate = _fetchFeelingsRate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // scrolledUnderElevation: 0,
        toolbarHeight: 100,
        title: _buildProfileHeader(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
            spacing: 12,
            children: [
              DiariesList(
                futureDiaries: _futureDiaries,
                title: "Your last diary entries",
              ),
              _buildWeeklyFeelingsSection(),
              SizedBox(height: 80),
            ],
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
          _loadData();
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildWeeklyFeelingsSection() {
    return Container(
      padding: .all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: .15),
        borderRadius: .circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const .only(bottom: 16),
            child: Text(
              "Your feel for your last $_diaryLength entries",
              textAlign: .center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: .bold,
                color: Colors.blue,
              ),
            ),
          ),
          FutureBuilder(
            future: _feelingsRate,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingIndicator();
              } else if (snapshot.hasError) {
                return EmptyState(
                  title: 'Error loading feelings',
                  description: 'Something went wrong.',
                  icon: Icons.sentiment_neutral_rounded,
                );
              } else {
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return EmptyState(
                    title: 'No Feelings',
                    description: 'You have no feelings yet.',
                    icon: Icons.sentiment_satisfied_rounded,
                  );
                }
                return Column(
                  spacing: 6,
                  children: FeelingType.values.map((feeling) {
                    return Material(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: .circular(12),
                      child: Container(
                        padding: .all(10),
                        decoration: BoxDecoration(
                          color: feeling.color.withValues(alpha: .2),
                        ),
                        child: Row(
                          spacing: 8,
                          children: [
                            Container(
                              padding: .all(4),
                              decoration: BoxDecoration(
                                color: feeling.color.withValues(alpha: .3),
                                shape: .circle,
                              ),
                              child: Icon(feeling.icon, color: feeling.color),
                            ),
                            Text(
                              '${data[feeling] ?? '0'}%',
                              maxLines: 2,
                              overflow: .ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
