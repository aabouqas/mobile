import 'package:diary_app/diary.dart';
import 'package:diary_app/diary_details_page.dart';
import 'package:diary_app/supabase_service.dart';
import 'package:diary_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  bool isLogouting = false;
  Future<List<Diary>>? futureDiaries;

  @override
  void initState() {
    super.initState();
    futureDiaries = _fetchDiaries();
  }

  Future<List<Diary>> _fetchDiaries() async {
    return await SupabaseService.getUserDiaries() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: _buildProfileHeader(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Divider(),
            Expanded(child: _buildDiriesList()),
          ],
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
    return FutureBuilder(
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
          return ListView.builder(
            itemCount: diaries.length,
            padding: .only(bottom: 80),
            itemBuilder: (context, index) {
              final diary = diaries[index];
              return Material(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Container(
                    padding: .all(4),
                    decoration: BoxDecoration(
                      color: getIconColor(diary.icon).withValues(alpha: .2),
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
                  subtitle: Text(
                    diary.text ?? 'No Content',
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryDetailsPage(diary: diary),
                      ),
                    );
                    setState(() {
                      futureDiaries = _fetchDiaries();
                    });
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  void _setLogouting(bool value) => setState(() => isLogouting = value);
}
