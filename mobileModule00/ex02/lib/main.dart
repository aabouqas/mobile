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
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const List<String> btns = [
    '7', '8', '9', 'C', 'AC',
    '4', '5', '6', '+', '-',
    '1', '2', '3', '*', '/',
    '0', '.', '00', '=', ''];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: .end,
            spacing: 4,
            children: [
              Expanded(
                child: Column(
                  spacing: 4,
                  children: [
                    _txt('0'),
                    _txt('0'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    for (int r = 0; r < 4; r++)
                      Expanded(
                        child: Row(
                          children: [
                            for (int c = 0; c < 5; c++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: _btn(btns[r * 5 + c]),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _txt(String txt) => Text(txt, style: const TextStyle(fontSize: 28),);
  Widget _btn(String txt) => TextButton( onPressed: txt.isEmpty ? null : () => debugPrint('button pressed :$txt'), child: _txt(txt),);
}