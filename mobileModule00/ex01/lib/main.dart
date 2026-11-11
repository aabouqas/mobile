import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
        theme: ThemeData(
            colorSchemeSeed: const Color(0xFF6B7B3E)
        ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {

  bool switcher = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7B3E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                switcher ?
                'A simple text' : 'Hello World!',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Click me'),
              onPressed: () {
                setState(() {
                  switcher = !switcher;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}