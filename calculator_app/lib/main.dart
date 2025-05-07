import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'history_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // 플러그인 초기화를 위해 추가
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
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // 베이지색 배경
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

  final FocusNode _focusNode = FocusNode();
  final List<String> _history = [];
  final List<DateTime> _historyTimestamps = [];

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
          _currentNumber = "0";
          _output = "0";
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

          // 계산 히스토리 추가
          _history.add(
              '${_formatter.format(_num1)} $_operation ${_formatter.format(num2)} = ${_formatter.format(result)}');
          _historyTimestamps.add(DateTime.now());

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
            backgroundColor: color ?? const Color(0xFF8B4513), // 갈색 숫자 키
            padding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _onButtonPressed(buttonText),
          child: Text(
            buttonText,
            style: GoogleFonts.robotoMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            // 1. Backspace 우선 처리
            if (event.logicalKey.keyLabel == 'Backspace') {
              setState(() {
                if (_currentNumber.isNotEmpty) {
                  _currentNumber =
                      _currentNumber.substring(0, _currentNumber.length - 1);
                  if (_currentNumber.isEmpty) {
                    _output = '0';
                  } else {
                    _output = _formatNumber(_currentNumber);
                  }
                }
              });
              return;
            }
            // 2. Enter 우선 처리
            if (event.logicalKey.keyLabel == 'Enter' ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              _onButtonPressed('=');
              setState(() {
                _newNumber = true;
              });
              return;
            }
            // 3. 나머지 키 입력 처리
            final key = event.character;
            if (key == null) return;
            print('Pressed key: $key, label: \'${event.logicalKey.keyLabel}\'');
            print('Pressed key label: ${event.logicalKey.keyLabel}');
            if (RegExp(r'^[0-9]$').hasMatch(key)) {
              setState(() {
                if (_newNumber) {
                  _currentNumber = '';
                  _output = '';
                  _newNumber = false;
                }
                _onButtonPressed(key);
              });
            } else if (key == '+' || key == '-' || key == '*' || key == '/') {
              String op = key;
              if (op == '*') op = '×';
              if (op == '/') op = '÷';
              _onButtonPressed(op);
            } else if (key == '=' || key == '\n') {
              _onButtonPressed('=');
            } else if (key.toUpperCase() == 'C') {
              _onButtonPressed('C');
            } else if (key.toUpperCase() == 'C') {
              _onButtonPressed('C');
            }
          }
        },
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _focusNode.requestFocus();
            },
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('계산기'),
                  backgroundColor: const Color(0xFF8B4513), // 진한 갈색 앱바
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryPage(
                              history: _history,
                              timestamps: _historyTimestamps,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // 계산 히스토리 영역
                    if (_history.isNotEmpty)
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _history.reversed
                              .take(3) // 최근 3개만 표시
                              .map((h) => Text(
                                    h,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ))
                              .toList(),
                        ),
                      ),
                    // 입력 상태(수식) 영역
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 12),
                      child: Text(
                        (_operation.isNotEmpty && !_newNumber)
                            ? '${_formatter.format(_num1)} $_operation'
                            : (_operation.isNotEmpty
                                ? '${_formatter.format(_num1)} $_operation'
                                : ''),
                        style: const TextStyle(
                            fontSize: 20, color: Colors.black54),
                      ),
                    ),
                    // 메인 숫자 출력 영역
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      margin: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _output,
                            style: GoogleFonts.robotoMono(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _output));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('결과가 클립보드에 복사되었습니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Divider(),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            _buildButton("7"),
                            _buildButton("8"),
                            _buildButton("9"),
                            _buildButton("÷", color: const Color(0xFFD2B48C)), // 진한 베이지색
                          ],
                        ),
                        Row(
                          children: [
                            _buildButton("4"),
                            _buildButton("5"),
                            _buildButton("6"),
                            _buildButton("×", color: const Color(0xFFD2B48C)),
                          ],
                        ),
                        Row(
                          children: [
                            _buildButton("1"),
                            _buildButton("2"),
                            _buildButton("3"),
                            _buildButton("-", color: const Color(0xFFD2B48C)),
                          ],
                        ),
                        Row(
                          children: [
                            _buildButton("0"),
                            _buildButton("C", color: Colors.red),
                            _buildButton("=", color: Colors.green),
                            _buildButton("+", color: const Color(0xFFD2B48C)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ))));
  }
}
