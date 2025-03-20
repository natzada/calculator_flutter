import 'package:flutter/material.dart'; // Importa o pacote Material do Flutter para criar a interface do usuário.
import 'package:math_expressions/math_expressions.dart'; // Importa o pacote para avaliar expressões matemáticas.
import 'dart:math'; // Importa o pacote para usar funções matemáticas, como logaritmos e potências.

void main() {
  runApp(CalculatorApp()); // Inicia o aplicativo com o widget CalculatorApp.
}

class CalculatorApp extends StatelessWidget { // Classe do aplicativo da calculadora.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Define o MaterialApp como o widget raiz.
      debugShowCheckedModeBanner: false, // Desativa a faixa de depuração.
      theme: ThemeData( // Define o tema do aplicativo.
        primarySwatch: Colors.blue, // Define a cor principal como azul.
        fontFamily: 'Roboto', // Define a fonte como Roboto.
        scaffoldBackgroundColor: Colors.blueGrey[50], // Define a cor de fundo do Scaffold.
      ),
      home: CalculatorScreen(), // Define a tela inicial como CalculatorScreen.
    );
  }
}

class CalculatorScreen extends StatefulWidget { // Tela principal da calculadora, que é um StatefulWidget.
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState(); // Cria o estado da tela.
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0"; // Armazena o resultado ou a saída da calculadora.
  String _input = ""; // Armazena a entrada do usuário.
  bool _showAdvanced = false; // Controla a visibilidade dos botões avançados.

  void _onButtonPressed(String value) { // Função chamada quando um botão é pressionado.
    setState(() { // Atualiza o estado da interface após pressionar um botão.
      if (value == "C") { // Se o botão for 'C', limpa a tela.
        _output = "0";
        _input = "";
      } else if (value == "⌫") { // Se o botão for '⌫', remove o último caractere da entrada.
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
          _output = _input.isEmpty ? "0" : _input;
        }
      } else if (value == "=") { // Se o botão for '=', calcula o resultado da expressão.
        _output = _calculateResult(_input); // Calcula e exibe o resultado.
        _input = _output; // Mantém o resultado na entrada para exibição.
      } else { // Se o botão for outro, adiciona o valor à entrada.
        _input += value;
        _output = _input;  // Atualiza a saída com o valor da entrada.
      }
    });
  }

  String _calculateResult(String input) { // Função para calcular o resultado da expressão.
    try {
      input = input.replaceAll(",", "."); // Substitui a vírgula por ponto, para compatibilidade.
      input = input.replaceAll("√", "sqrt"); // Substitui "√" por "sqrt" para ser reconhecido.

      // Substitui '^' por uma expressão que o Dart possa entender diretamente.
      input = input.replaceAllMapped(RegExp(r'(\d+)\^(\d+)'), (match) {
        double base = double.parse(match.group(1)!);
        double exponent = double.parse(match.group(2)!);
        return pow(base, exponent).toString(); // Calcula a potência e substitui.
      });

      // Depuração: Mostra a entrada antes de calcular
      print("Entrada modificada: $input");

      // Substitui logaritmos na base 10 na expressão.
      input = input.replaceAllMapped(RegExp(r'log\(([^)]+)\)'), (match) {
        String innerExpression = match.group(1)!;
        return "(${_calculateLog(innerExpression)})"; // Substitui por cálculo de logaritmo.
      });

      input = _handleFactorial(input); // Lida com o cálculo de fatorial.

      // Cria um Parser para analisar a expressão e calcular seu resultado.
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm); // Avalia a expressão.

      // Depuração: Mostra o resultado calculado
      print("Resultado calculado: $eval");

      return eval.toString(); // Retorna o resultado da expressão.
    } catch (e) {
      print("Erro ao calcular a expressão: $e");
      return "Erro"; // Retorna "Erro" em caso de falha no cálculo.
    }
  }

  // Função para calcular logaritmo base 10.
  String _calculateLog(String expression) {
    try {
      double value = double.parse(expression);
      if (value <= 0) {
        return "Erro"; // Logaritmo de números negativos ou zero não é definido.
      }
      double logValue = log(value) / log(10); // Calcula o logaritmo na base 10.
      return logValue.toString(); // Retorna o valor calculado.
    } catch (e) {
      return "Erro"; // Retorna "Erro" em caso de falha.
    }
  }

  // Função para lidar com o fatorial na expressão.
  String _handleFactorial(String input) {
    RegExp regex = RegExp(r'(\d+)!'); // Encontra números seguidos de '!'.

    return input.replaceAllMapped(regex, (match) {
      int num = int.parse(match.group(1)!); // Obtém o número antes de '!'
      return _factorial(num).toString(); // Substitui pelo resultado do fatorial.
    });
  }

  // Função para calcular o fatorial de um número.
  int _factorial(int n) {
    if (n == 0 || n == 1) return 1; // Fatorial de 0 ou 1 é 1.
    return n * _factorial(n - 1); // Recursivamente calcula o fatorial.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Cria a estrutura básica da tela.
      appBar: AppBar(
        title: Text("Calculadora", style: TextStyle(fontSize: 30)), // Título da barra de app.
        backgroundColor: Colors.blue[600], // Cor de fundo da barra de app.
        centerTitle: true,
        elevation: 0,
      ),
      body: Column( // Organiza os elementos na tela em uma coluna.
        children: [
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(20),
            color: Colors.blueGrey[100],
            child: Text( // Exibe o resultado ou a entrada.
              _output,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showAdvanced = !_showAdvanced; // Alterna a visibilidade dos botões avançados.
              });
            },
            child: Container( // Botão para mostrar ou esconder os botões avançados.
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.blueGrey[200],
              child: Icon(
                _showAdvanced ? Icons.expand_less : Icons.expand_more,
                color: Colors.blue[600],
                size: 30,
              ),
            ),
          ),
          if (_showAdvanced) _buildAdvancedButtons(), // Exibe os botões avançados, se for o caso.
          Expanded(
            flex: 2,
            child: GridView.count( // Exibe os botões principais da calculadora.
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: EdgeInsets.all(15),
              children: _buttons.map((label) => _buildButton(label)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label) {
    bool isOperator = _isOperator(label); // Verifica se o botão é um operador.

    return AnimatedContainer( // Cria um botão com animação.
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isOperator
            ? const Color.fromARGB(255, 0, 19, 163)
            : Colors.blue[400],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(label), // Chama a função ao pressionar o botão.
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(22),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedButtons() {
    return GridView.builder( // Cria os botões avançados em uma grade.
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      padding: EdgeInsets.all(15),
      itemCount: _advancedButtons.length,
      itemBuilder: (context, index) {
        return _buildButton(_advancedButtons[index]); // Cria os botões avançados.
      },
    );
  }

  bool _isOperator(String label) {
    return [
      "+", "-", "*", "/", "log", "√", "(", ")", "!", "⌫", "C", "^", "=",
    ].contains(label); // Verifica se o rótulo é um operador.
  }

  final List<String> _buttons = [ // Lista de botões principais.
    "log", "√", "⌫", "/",
    "7", "8", "9", "*",
    "4", "5", "6", "-",
    "1", "2", "3", "+",
    "C", "0", ",", "=",  // Adicionando o botão de potência
  ];

  final List<String> _advancedButtons = [ // Lista de botões avançados.
    "!", "(", ")", "^",
  ];
}
