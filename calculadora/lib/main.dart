import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PressStart2P', // 🔹 Fonte estilo pixelada (adicione ao projeto)
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _input = "";
  bool _showAdvanced = false;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _output = "0";
        _input = "";
      } else if (value == "⌫") {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
          _output = _input.isEmpty ? "0" : _input;
        }
      } else if (value == "=") {
        try {
          _output = _calculateResult(_input);
        } catch (e) {
          _output = "Erro";
        }
      } else {
        if (value == "√") {
          _input += "sqrt(";
        } else if (value == "!") {
          _input += "!";
        } else {
          _input += value;
        }
        _output = _input;
      }
    });
  }

  String _calculateResult(String input) {
    try {
      input = input.replaceAllMapped(RegExp(r'log\(([^)]+)\)'), (match) {
        return "(${match.group(1)})/ln(10)";
      });
      input = input.replaceAll("√", "sqrt");
      input = _handleFactorial(input);
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval.toString();
    } catch (e) {
      return "Erro";
    }
  }

  String _handleFactorial(String input) {
    RegExp regex = RegExp(r'(\d+)!');
    return input.replaceAllMapped(regex, (match) {
      int num = int.parse(match.group(1)!);
      return _factorial(num).toString();
    });
  }

  int _factorial(int n) {
    if (n == 0 || n == 1) return 1;
    return n * _factorial(n - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 99, 99, 99), // 🔹 Fundo preto estilo computador antigo
      appBar: AppBar(
        title: Text("Calculadora"),
        backgroundColor: const Color.fromARGB(255, 99, 99, 99), // 🔹 Fundo preto estilo computador antigo
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(16),
            color: const Color.fromARGB(255, 218, 218, 218), // 🔹 Fundo da tela da calculadora (verde escuro)
            child: Text(
              _output,
              style: TextStyle(
                fontSize: 24, // 🔹 Reduzi o tamanho para melhor encaixe
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0), // 🔹 Cor do texto estilo monitor antigo
              ),
            ),
          ),
          GestureDetector(
  onTap: () {
    setState(() {
      _showAdvanced = !_showAdvanced;
    });
  },
  child: Container(
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(vertical: 5),
    child: Text(
      _showAdvanced ? "∨" : "∧",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255)),
    ),
  ),
),

          if (_showAdvanced) _buildAdvancedButtons(),
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              padding: EdgeInsets.all(8),
              children: _buttons.map((label) => _buildButton(label)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // 🔹 Botões quadrados
        backgroundColor: const Color.fromARGB(255, 214, 214, 214), // 🔹 Cor verde escura
        elevation: 5,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16, // 🔹 Tamanho menor para parecer mais retrô
          color: const Color.fromARGB(255, 7, 7, 7), // 🔹 Cor do texto em verde claro
        ),
      ),
    );
  }

  Widget _buildAdvancedButtons() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      padding: EdgeInsets.all(8),
      itemCount: _advancedButtons.length,
      itemBuilder: (context, index) {
        return _buildButton(_advancedButtons[index]);
      },
    );
  }

  bool _isOperator(String label) {
    return [
      "+", "-", "*", "/", "log", "^", "√", "(", ")", "!", "%", "⌫", "C", "=",
    ].contains(label);
  }

  final List<String> _buttons = [
    "log", "√", "⌫", "/",
    "7", "8", "9", "*",
    "4", "5", "6", "-",
    "1", "2", "3", "+",
    "C", "0", ",", "="
  ];

  final List<String> _advancedButtons = ["(", ")", "^", "!"];
}
