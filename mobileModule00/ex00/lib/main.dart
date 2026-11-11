import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
              child: const Text('A simple text',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Click me',
                  style: TextStyle(
                    color: Color(0xFF6B7B3E),
                  )
              ),
              onPressed: () {
                debugPrint('Button Pressed');
              },
            )
          ],
        ),
      ),
    );
  }
}