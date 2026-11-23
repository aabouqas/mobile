import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: TableCalendar(
                firstDay: DateTime.utc(2026, 1, 1),
                lastDay: DateTime.now(),
                focusedDay: DateTime.now(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
