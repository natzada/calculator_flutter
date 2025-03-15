import 'package:flutter/material.dart'; // Importa o pacote necessário para o uso de componentes da interface gráfica do Flutter
import 'package:math_expressions/math_expressions.dart'; // Importa o pacote necessário para interpretar expressões matemáticas

void main() {
  runApp(CalculatorApp()); // Executa o aplicativo CalculatorApp
}

class CalculatorApp extends StatelessWidget { // Classe principal que representa o aplicativo de calculadora
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Cria o aplicativo com o design material
      debugShowCheckedModeBanner: false, // Desativa a faixa de depuração no topo do app
      theme: ThemeData( // Define o tema global do app
        primarySwatch: Colors.blue, // Define a cor principal do app como azul
        fontFamily: 'Roboto', // Define a fonte padrão do app como 'Roboto'
        scaffoldBackgroundColor: Colors.blueGrey[50], // Define a cor de fundo do app como azul acinzentado claro
      ),
      home: CalculatorScreen(), // Define a tela inicial como CalculatorScreen
    );
  }
} 

class CalculatorScreen extends StatefulWidget { // Classe que define a tela da calculadora
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState(); // Cria o estado mutável da tela
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0"; // Variável que armazena o valor mostrado na tela
  String _input = ""; // Variável que armazena a expressão inserida pelo usuário
  bool _showAdvanced = false; // Flag que controla a exibição de funções avançadas

  // Método chamado quando um botão é pressionado
  void _onButtonPressed(String value) {
    setState(() { // Atualiza o estado da tela após um botão ser pressionado
      if (value == "C") { // Se o botão pressionado for "C" (limpar)
        _output = "0"; // Reseta o valor mostrado na tela para 0
        _input = ""; // Limpa a expressão armazenada
      } else if (value == "⌫") { // Se o botão pressionado for "⌫" (apagar último caractere)
        if (_input.isNotEmpty) { // Se houver algo na expressão
          _input = _input.substring(0, _input.length - 1); // Remove o último caractere
          _output = _input.isEmpty ? "0" : _input; // Atualiza a tela com a nova expressão ou 0 se estiver vazia
        }
      } else if (value == "=") { // Se o botão pressionado for "=" (calcular resultado)
        try {
          _output = _calculateResult(_input); // Calcula o resultado da expressão
        } catch (e) {
          _output = "Erro"; // Caso ocorra um erro, exibe "Erro"
        }
      } else { // Caso contrário, se for um número ou operador
        if (value == "√") { // Se o valor for a raiz quadrada
          if (_input.isEmpty || _isOperator(_input[_input.length - 1])) { // Se a expressão estiver vazia ou terminar em operador
            _input += "sqrt("; // Adiciona "sqrt(" à expressão
          } else { 
            RegExp regex = RegExp(r'(\d+)$'); // Expressão regular para pegar o último número
            Match? match = regex.firstMatch(_input); // Faz a correspondência com o número no final da expressão
            if (match != null) { // Se encontrar um número
              String lastNumber = match.group(1)!; // Pega o último número
              _input = _input.substring(0, _input.length - lastNumber.length) + "sqrt($lastNumber)"; // Substitui o número por "sqrt(<número>)"
            } else {
              _input += "sqrt("; // Caso não encontre número, apenas adiciona "sqrt("
            }
          }
          _output = _input; // Atualiza a tela com a expressão modificada
        } else if (value == "log") { // Se o valor for o logaritmo
          if (_input.isEmpty || _isOperator(_input[_input.length - 1])) { // Se a expressão estiver vazia ou terminar em operador
            _input += "log("; // Adiciona "log(" à expressão
          } else {
            RegExp regex = RegExp(r'(\d+)$'); // Expressão regular para pegar o último número
            Match? match = regex.firstMatch(_input); // Faz a correspondência com o número no final da expressão
            if (match != null) { // Se encontrar um número
              String lastNumber = match.group(1)!; // Pega o último número
              _input = _input.substring(0, _input.length - lastNumber.length) + "log($lastNumber)"; // Substitui o número por "log(<número>)"
            } else {
              _input += "log("; // Caso não encontre número, apenas adiciona "log("
            }
          }
        } else if (value == "!") { // Se o valor for o fatorial
          _input += "!"; // Adiciona "!" à expressão
        } else { // Caso contrário, adiciona o valor diretamente na expressão
          _input += value;
        }
        _output = _input; // Atualiza a tela com a expressão
      }
    });
  }

  // Método que calcula o resultado da expressão matemática
  String _calculateResult(String input) {
    try {
      input = input.replaceAllMapped(RegExp(r'log\(([^)]+)\)'), (match) { // Substitui "log" para "log(10, ...)"
        return "log(10, ${match.group(1)})";
      });

      input = input.replaceAll("√", "sqrt"); // Substitui "√" por "sqrt"
      input = _handleFactorial(input); // Lida com o fatorial na expressão
      Parser p = Parser(); // Cria o parser para interpretar a expressão
      Expression exp = p.parse(input); // Analisa a expressão
      ContextModel cm = ContextModel(); // Cria o modelo de contexto para a avaliação
      double eval = exp.evaluate(EvaluationType.REAL, cm); // Avalia a expressão e calcula o resultado
      return eval.toStringAsFixed(2); // Retorna o resultado com duas casas decimais
    } catch (e) {
      return "Erro"; // Caso ocorra um erro, retorna "Erro"
    }
  }

  // Método que lida com o fatorial na expressão
  String _handleFactorial(String input) {
    RegExp regex = RegExp(r'(\d+)!'); // Expressão regular para encontrar números seguidos de "!"
    return input.replaceAllMapped(regex, (match) { // Substitui o fatorial por seu valor calculado
      int num = int.parse(match.group(1)!); // Pega o número
      return _factorial(num).toString(); // Calcula o fatorial e retorna como string
    });
  }

  // Método que calcula o fatorial de um número
  int _factorial(int n) {
    if (n == 0 || n == 1) return 1; // Se n for 0 ou 1, o fatorial é 1
    return n * _factorial(n - 1); // Caso contrário, calcula o fatorial recursivamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Cria a estrutura da tela da calculadora
      appBar: AppBar( // Cria a barra de navegação no topo
        title: Text("Calculadora", style: TextStyle(fontSize: 30)), // Define o título da app bar
        backgroundColor: Colors.blue[600], // Define a cor de fundo da app bar
        centerTitle: true, // Centraliza o título
        elevation: 0, // Remove a sombra da app bar
      ),
      body: Column( // Define a estrutura do corpo da tela
        children: [
          Container( // Contêiner para mostrar a saída na parte superior da tela
            alignment: Alignment.bottomRight, // Alinha o texto à direita
            padding: EdgeInsets.all(20), // Define o preenchimento ao redor do texto
            color: Colors.blueGrey[100], // Define a cor de fundo do contêiner
            child: Text( // Exibe o valor atual na tela
              _output,
              style: TextStyle(
                fontSize: 50, // Define o tamanho da fonte para o valor da saída
                fontWeight: FontWeight.bold, // Define o peso da fonte como negrito
                color: Colors.black87, // Define a cor do texto
              ),
            ),
          ),
          GestureDetector( // Detecta o toque para expandir ou contrair funções avançadas
            onTap: () {
              setState(() { // Atualiza o estado quando o gesto é detectado
                _showAdvanced = !_showAdvanced; // Alterna a exibição das funções avançadas
              });
            },
            child: Container( // Contêiner para a seta de expandir/contrair
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8), // Define o preenchimento vertical
              color: Colors.blueGrey[200], // Define a cor de fundo do contêiner
              child: Icon(
                _showAdvanced ? Icons.expand_less : Icons.expand_more, // Alterna o ícone dependendo do estado
                color: Colors.blue[600], // Define a cor do ícone
                size: 30, // Define o tamanho do ícone
              ),
            ),
          ),
          if (_showAdvanced) _buildAdvancedButtons(), // Exibe os botões avançados se necessário
          Expanded( // Expande a grade de botões para ocupar o restante da tela
            flex: 2,
            child: GridView.count( // Cria a grade de botões principais
              crossAxisCount: 4, // Define o número de colunas na grade
              mainAxisSpacing: 12, // Define o espaçamento principal entre os botões
              crossAxisSpacing: 12, // Define o espaçamento entre as colunas
              padding: EdgeInsets.all(15), // Define o preenchimento ao redor da grade
              children: _buttons.map((label) => _buildButton(label)).toList(), // Constrói os botões a partir da lista
            ),
          ),
        ],
      ),
    );
  }

  // Método que constrói um botão
  Widget _buildButton(String label) {
    bool isOperator = _isOperator(label); // Verifica se o rótulo é um operador

    return AnimatedContainer( // Cria um contêiner animado para o botão
      duration: Duration(milliseconds: 200), // Define a duração da animação
      curve: Curves.easeInOut, // Define o tipo de curva da animação
      decoration: BoxDecoration( // Define a decoração do botão
        color: isOperator // Se for um operador, a cor será diferente
            ? const Color.fromARGB(255, 0, 19, 163)
            : Colors.blue[400], // Cor azul para botões não operadores
        borderRadius: BorderRadius.circular(20), // Define bordas arredondadas para o botão
        boxShadow: [ // Adiciona sombra ao botão
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: ElevatedButton( // Cria o botão
        onPressed: () => _onButtonPressed(label), // Define a ação ao pressionar o botão
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(22), // Define o preenchimento dentro do botão
          backgroundColor: Colors.transparent, // Fundo transparente para o botão
          shadowColor: Colors.transparent, // Remover a sombra extra
          elevation: 0, // Define a elevação para 0 (sem sombra)
        ),
        child: Text( // Define o texto do botão
          label,
          style: TextStyle(
            fontSize: 24, // Define o tamanho da fonte do texto
            fontWeight: FontWeight.bold, // Define o peso da fonte como negrito
            color: Colors.white, // Define a cor do texto como branco
          ),
        ),
      ),
    );
  }

  // Método que constrói os botões avançados
  Widget _buildAdvancedButtons() {
    return GridView.builder( // Cria uma grade para os botões avançados
      shrinkWrap: true, // Ajusta o tamanho da grade para o conteúdo
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( // Define a quantidade de colunas
        crossAxisCount: 4,
        mainAxisSpacing: 12, // Espaçamento principal entre os botões
        crossAxisSpacing: 12, // Espaçamento entre as colunas
      ),
      padding: EdgeInsets.all(15), // Preenchimento ao redor da grade
      itemCount: _advancedButtons.length, // Define o número de itens
      itemBuilder: (context, index) {
        return _buildButton(_advancedButtons[index]); // Cria o botão para cada função avançada
      },
    );
  }

  // Método que verifica se o valor é um operador
  bool _isOperator(String label) {
    return [ // Lista de operadores suportados
      "+", "-", "*", "/", "log", "^", "√", "(", ")", "!", "%", "⌫", "C", "=",
    ].contains(label); // Retorna verdadeiro se o rótulo for um operador
  }

  final List<String> _buttons = [ // Lista de botões principais
    "log", "√", "⌫", "/", "7", "8", "9", "*", "4", "5", "6", "-", "1", "2", "3", "+", "C", "0", ",", "=",
  ];

  final List<String> _advancedButtons = [ // Lista de botões avançados
    "!", "(", ")", "^", "%", "x²", "x³", "x⁴", "π", "e", "²", "√", "log",
  ];
}
