

import 'package:intl/intl.dart';
import 'package:advanced_diary_app/diary.dart';
import 'package:advanced_diary_app/shared.dart';
import 'package:advanced_diary_app/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  late Future<List<Diary>> _futureDiaries;

  @override
  void initState() {
    super.initState();
    SupabaseService.refreshNotifier.addListener(_fetchDiaries);
    _fetchDiaries();
  }

  void _fetchDiaries() {
    if (!mounted) return;
    setState(() {
      _futureDiaries = SupabaseService.getUserDiaries(date: _selectedDay);
    });
  }

  @override
  void dispose() {
    SupabaseService.refreshNotifier.removeListener(_fetchDiaries);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 20,
            children: [
              TableCalendar(
                availableGestures: AvailableGestures.horizontalSwipe,
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: .circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: .5),
                    shape: .circle,
                  ),
                ),
                firstDay: DateTime.utc(2026, 1, 1),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _fetchDiaries();
                  });
                },
              ),
              DiariesList(
                futureDiaries: _futureDiaries,
                dateEnabled: false,
                title: DateFormat.yMMMd().format(_selectedDay),
              ),

              // _buildDiariesListSection(),
            ],
          ),
        ),
      ),
    );
  }
}
