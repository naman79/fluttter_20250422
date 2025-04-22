import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '계산기',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _output = "0";
  String _currentNumber = "";
  String _operation = "";
  double _num1 = 0;
  bool _newNumber = true;
  final NumberFormat _formatter = NumberFormat('#,###.##########');

  String _formatNumber(String number) {
    if (number == "0") return "0";
    try {
      double? value = double.tryParse(number);
      if (value == null) return number;

      return _formatter.format(value);
    } catch (e) {
      return number;
    }
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _currentNumber = "";
        _operation = "";
        _num1 = 0;
        _newNumber = true;
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        if (_currentNumber.isNotEmpty) {
          _num1 = double.parse(_currentNumber.replaceAll(',', ''));
          _operation = buttonText;
          _newNumber = true;
        }
      } else if (buttonText == "=") {
        if (_currentNumber.isNotEmpty && _operation.isNotEmpty) {
          double num2 = double.parse(_currentNumber.replaceAll(',', ''));
          double result = 0;

          switch (_operation) {
            case "+":
              result = _num1 + num2;
              break;
            case "-":
              result = _num1 - num2;
              break;
            case "×":
              result = _num1 * num2;
              break;
            case "÷":
              result = _num1 / num2;
              break;
          }

          _output = result.toString();
          if (_output.endsWith(".0")) {
            _output = _output.substring(0, _output.length - 2);
          }
          _output = _formatNumber(_output);
          _currentNumber = _output.replaceAll(',', '');
          _operation = "";
        }
      } else {
        if (_newNumber) {
          _currentNumber = buttonText;
          _newNumber = false;
        } else {
          _currentNumber += buttonText;
        }
        _output = _formatNumber(_currentNumber);
      }
    });
  }

  Widget _buildButton(String buttonText, {Color? color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[300],
            padding: const EdgeInsets.all(24),
          ),
          onPressed: () => _onButtonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계산기'),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 12,
            ),
            child: Text(
              _output,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Divider(),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildButton("7"),
                  _buildButton("8"),
                  _buildButton("9"),
                  _buildButton("÷", color: Colors.orange),
                ],
              ),
              Row(
                children: [
                  _buildButton("4"),
                  _buildButton("5"),
                  _buildButton("6"),
                  _buildButton("×", color: Colors.orange),
                ],
              ),
              Row(
                children: [
                  _buildButton("1"),
                  _buildButton("2"),
                  _buildButton("3"),
                  _buildButton("-", color: Colors.orange),
                ],
              ),
              Row(
                children: [
                  _buildButton("0"),
                  _buildButton("C", color: Colors.red),
                  _buildButton("=", color: Colors.green),
                  _buildButton("+", color: Colors.orange),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
