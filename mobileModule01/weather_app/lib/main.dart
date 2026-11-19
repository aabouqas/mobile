import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum TabType {
  currently,
  today,
  weekly;

  String stringValue() {
    switch (this) {
      case TabType.currently:
        return "Currently";
      case TabType.today:
        return "Today";
      case TabType.weekly:
        return "Weekly";
    }
  }

  IconData getIcon() {
    switch (this) {
      case TabType.currently:
        return Icons.sunny;
      case TabType.today:
        return Icons.today_rounded;
      case TabType.weekly:
        return Icons.calendar_month_rounded;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _displayText = "";
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              border: .none,
              focusedBorder: .none,
              hint: Text(
                'Search location...',
                maxLines: 1,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            onSubmitted: (text) {
              setState(() {
                _displayText = text;
              });
            },
          ),
          actions: [
            IconButton(
              onPressed: () => setState(() {
                _textEditingController.clear();
                _displayText = "Geolocation";
              }),
              icon: const Icon(Icons.gps_fixed),
            ),
          ],
        ),
        body: TabBarView(
          children: TabType.values
              .map(
                (tab) => Center(
                  child: Text(
                    '${tab.stringValue()}\n$_displayText'.trim(),
                    textAlign: .center,
                    style: const TextStyle(fontSize: 30, fontWeight: .bold),
                  ),
                ),
              )
              .toList(),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: .zero,
          child: TabBar(
            tabs: TabType.values
                .map(
                  (tab) =>
                      Tab(icon: Icon(tab.getIcon()), text: tab.stringValue()),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
