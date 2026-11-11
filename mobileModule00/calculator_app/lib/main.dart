import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  // debugPaintSizeEnabled = true;
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

  String expression = "0";
  String result = "0";

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
        elevation: .infinity,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 4,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: .end,
                  spacing: 4,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: .horizontal,
                      reverse: true,
                      child: _txt(expression),
                    ),
                    _txt(result),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: .min,
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
    );
  }

  Color getColor(String txt){
    if ('AC'.contains(txt)) {
      return Colors.red;
    } else if ('+-/*='.contains(txt)) {
      return Colors.grey;
    }
    return Colors.black;
  }

  Widget _txt(String txt) => Text(txt, maxLines: 1, style: TextStyle(fontSize: 28, color: getColor(txt)),);

  Widget _btn(String txt) => SizedBox.expand(
    child: TextButton(
      style: TextButton.styleFrom(
        padding: .zero
      ),
      onPressed: txt.isEmpty ? null : () {
      if (txt == '=') {
        setState(() {
          final res = calculate(expression);
          setState(() => result = res);
        });
      } else if (txt == 'C') {
        setState(() {
          expression = expression.substring(0, expression.length - 1);
          if (expression.isEmpty) {
            expression = '0';
          }
        });
      } else if (txt == 'AC') {
        setState(() {
          expression = '0';
          result = '0';
        });
      }
      else {
        setState(() {
          if (expression == '0') {
            expression = txt;
          } else {
            expression += txt;
          }
        });
      }
    }, child: FittedBox(
      fit: BoxFit.scaleDown,
        child: _txt(txt)),),
  );


  String calculate(String expression) {
    try {
      ShuntingYardParser parser = ShuntingYardParser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isInfinite || eval.isNaN) {
        return 'Error';
      }

      return eval.toString().replaceAll(RegExp(r'\.0$'), '');
    } catch (e) {
      return 'Error';
    }
  }
}