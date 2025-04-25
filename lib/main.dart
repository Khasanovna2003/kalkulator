import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(MyCalculatorApp());

class MyCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String displayText = '';
  bool isResult = false; // Natija ko'rsatilganligini aniqlash

  void buttonPressed(String value) {
    setState(() {
      // Agar 'C' bosilsa, ekran tozalanadi
      if (value == 'C') {
        displayText = '';
        isResult = false;
      }
      // Agar '=' bosilsa, hisoblash amalga oshiriladi
      else if (value == '=') {
        try {
          displayText = _evaluate(displayText);
          isResult = true; // Natija hisoblandi
        } catch (e) {
          displayText = 'Error';
          isResult = false;
        }
      } else {
        // Agar natija ko'rsatilgan bo'lsa va yangi raqam yoki amal bosilsa, eski natija o'chiriladi
        if (isResult) {
          displayText = value;
          isResult = false;
        } else {
          // Agar ekranda amallar ketma-ket bo'lsa, faqat oxirgi amalni saqlash
          if (displayText.isNotEmpty && ['+', '-', '*', '/'].contains(value) && ['+', '-', '*', '/'].contains(displayText[displayText.length - 1])) {
            displayText = displayText.substring(0, displayText.length - 1); // Oxirgi amalni olib tashlash
          }

          // Agar 0 bo'lsa va yangi raqam bosilsa, 0 ni o'chirish
          if (displayText == '0' && value != '.') {
            displayText = value;
          } else {
            // Agar ekranda nuqta bo'lsa, yangi nuqta kiritishga ruxsat berilmasin
            if (value == '.' && displayText.isEmpty) {
              // Ekranda hech narsa yo'q bo'lsa, nuqta qo'yishga ruxsat bermaymiz
              return;
            }

            // Agar oxirgi yozilgan raqam yoki amal nuqta bo'lsa, yangi nuqta qo'shishga ruxsat bermaymiz
            if (value == '.' && displayText.contains('.')) {
              return;
            }

            // Agar amal bo'lsa va undan keyin nuqta qo'shilsa, uni qabul qilamiz
            displayText += value;
          }
        }
      }
    });
  }

  String _evaluate(String expression) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      return result.toString();
    } catch (e) {
      return 'Error';
    }
  }

  Widget buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AspectRatio(
          aspectRatio: 1,
          child: ElevatedButton(
            onPressed: () => buttonPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: ['C', '+', '-', '=', '*', '/'].contains(text) ? Colors.red : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              elevation: 2,
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['1', '2', '3', 'C'],
      ['4', '5', '6', '+'],
      ['7', '8', '9', '-'],
      ['', '0', '.', '='],
    ];

    return Scaffold(
      backgroundColor: Color(0xFFB3E5FC),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 100),
            // Ekran
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                height: 80,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  displayText,
                  style: TextStyle(fontSize: 32),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(height: 100),
            // Tugmalar gridi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, bottom: 100),
                child: Column(
                  children: buttons.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((text) {
                          return text.isEmpty
                              ? Expanded(child: SizedBox())
                              : buildButton(text);
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
