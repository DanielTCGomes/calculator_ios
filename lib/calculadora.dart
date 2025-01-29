import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora iOS',
      home: CalculadoraHomePage(),
    );
  }
}

class CalculadoraHomePage extends StatefulWidget {
  const CalculadoraHomePage({Key? key}) : super(key: key);

  @override
  CalculadoraHomePageState createState() => CalculadoraHomePageState();
}

class CalculadoraHomePageState extends State<CalculadoraHomePage> {
  String _output = "0";
  String _input = "";

  void _onPressed(String value) {
    setState(() {
      if (value == "AC") {
        _input = "";
        _output = "0";
      } else if (value == "=") {
        try {
          _output = _calculate(_input);
        } catch (e) {
          _output = "Erro";
        }
        _input = "";
      } else if (value == "+/-") {
        if (_input.isNotEmpty) {
          if (_input.startsWith("-")) {
            _input = _input.substring(1);
          } else {
            _input = "-$_input";
          }
        }
      } else {
        _input += value;
      }
    });
  }

  String _calculate(String expression) {
    try {
      expression = expression.replaceAll("×", "*").replaceAll("÷", "/");
      final percentageRegex = RegExp(r'(\d+(\.\d+)?)%\s*(\d+(\.\d+)?)');
      expression = expression.replaceAllMapped(percentageRegex, (match) {
        final percentValue = match.group(1);
        final baseValue = match.group(3);
        return '($baseValue * ($percentValue / 100))';
      });

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval == eval.toInt()) {
        return eval.toInt().toString();
      } else {
        return eval.toString();
      }
    } catch (e) {
      return "Erro";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Text(
                _input.isEmpty ? "0" : _input,
                style: const TextStyle(fontSize: 60, color: Colors.white),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(20),
            child: Text(
              _output,
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final buttons = [
      ['AC', '+/-', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return Column(
      children: buttons.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((text) {
            if (text == "0") {
              return _buildButtonZero();
            }
            return Expanded(child: _buildButton(text));
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String text) {
    final isOperator = ['÷', '×', '-', '+', '='].contains(text);
    final isSpecial = ['AC', '+/-', '%'].contains(text);

    return Container(
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: () => _onPressed(text),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          minimumSize: const Size(80, 80),
          maximumSize: const Size(80, 80),
          padding: const EdgeInsets.all(20),
          backgroundColor: isOperator
              ? Colors.orange
              : isSpecial
                  ? Colors.grey
                  : const Color(0xFF333333),
          textStyle: const TextStyle(fontSize: 30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isOperator ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonZero() {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: ElevatedButton(
          onPressed: () => _onPressed("0"),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: const Color(0xFF333333),
            textStyle: const TextStyle(fontSize: 30),
          ),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30),
              child: Text(
                "0",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
