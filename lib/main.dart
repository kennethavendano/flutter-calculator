import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator by Kenneth Avendano',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const CalculatorHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _expression = '';
  String _result = '';
  bool _hasError = false;

  final List<String> _buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    'C', '0', '=', '+',
    'x²', '%',
  ];

  void _onButtonPressed(String value) {
    setState(() {
      _hasError = false;
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '=') {
        _evaluateExpression();
      } else if (value == 'x²') {
        _applySquare();
      } else if (value == '%') {
        if (_expression.isNotEmpty && !_isOperator(_expression[_expression.length - 1])) {
          _expression += '%';
        }
      } else {
        if (_result.isNotEmpty && _expression.endsWith('=')) {
          // Start new expression after result
          _expression = '';
          _result = '';
        }
        _expression += value;
      }
    });
  }

  void _applySquare() {
    // Find the last number in the expression and square it
    final reg = RegExp(r'(\d+\.?\d*)$');
    final match = reg.firstMatch(_expression);
    if (match != null) {
      final number = match.group(0)!;
      final squared = '(${number}*${number})';
      _expression = _expression.replaceRange(match.start, match.end, squared);
    }
  }

  void _evaluateExpression() {
    try {
      // Replace % with /100 for percentage calculation
      String exp = _expression.replaceAllMapped(
        RegExp(r'(\d+\.?\d*)%'),
        (m) => '(${m[1]}/100)',
      );
      // Remove trailing operators
      while (exp.isNotEmpty && _isOperator(exp[exp.length - 1])) {
        exp = exp.substring(0, exp.length - 1);
      }
      if (exp.isEmpty) return;
      final expression = Expression.parse(exp);
      final evaluator = const ExpressionEvaluator();
      final context = <String, dynamic>{};
      final evalResult = evaluator.eval(expression, context);
      _result = evalResult.toString();
      _expression += '=';
    } catch (e) {
      _result = 'Error';
      _hasError = true;
    }
  }

  bool _isOperator(String ch) {
    return ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == '%';
  }

  Widget _buildButton(String value) {
    Color bgColor;
    Color fgColor = Colors.white;
    if (value == 'C') {
      bgColor = Colors.redAccent;
    } else if (value == '=') {
      bgColor = Colors.green;
    } else if (_isOperator(value) || value == 'x²') {
      bgColor = Colors.blueGrey;
    } else {
      bgColor = Colors.grey[800]!;
    }
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          minimumSize: const Size(64, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _onButtonPressed(value),
        child: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _expression.isEmpty
        ? '0'
        : _expression + (_result.isNotEmpty && !_expression.endsWith('=') ? '' : (_result.isNotEmpty ? ' $_result' : ''));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Calculator by Kenneth Avendano',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _expression.isEmpty ? '0' : _expression,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _result,
                      style: TextStyle(
                        fontSize: 40,
                        color: _hasError ? Colors.redAccent : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.grey[900],
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return _buildButton(_buttons[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

