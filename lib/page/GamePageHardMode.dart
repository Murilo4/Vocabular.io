import 'package:flutter/material.dart';
import 'dart:math';

// Definição das palavras por nível
const palavras = {
  'level1': [
    {'word': 'casa', 'fullWord': 'casa'},
    {'word': 'chao', 'fullWord': 'chão'},
  ],
  'level2': [
    {'word': 'casco', 'fullWord': 'casco'},
    {'word': 'visao', 'fullWord': 'visão'},
  ],
  // Adicione outros níveis conforme necessário
};

class GamePageHardMode extends StatefulWidget {
  final String difficulty;

  const GamePageHardMode({super.key, required this.difficulty});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePageHardMode> {
  String _word = '';
  String _fullWord = '';
  int _wordLength = 4;
  int _selectedFieldIndex = 0;

  // Cada linha é uma tentativa, cada tentativa é uma lista de controllers
  List<List<TextEditingController>> _attemptControllers = [];
  List<List<Color>> _attemptColors = [];
  int _currentAttempt = 0;
  static const int maxAttempts = 6;

  // Novo: letras já tentadas
  Set<String> _usedLetters = {};

  @override
  void initState() {
    super.initState();
    _initializeWord();
  }

  void _initializeWord() {
    // Seleciona o nível baseado no tamanho da palavra
    String level = 'level${_wordLength - 3}';
    final levelWords = palavras[level] ?? [];
    if (levelWords.isNotEmpty) {
      final random = Random();
      final wordObj = levelWords[random.nextInt(levelWords.length)];
      _word = wordObj['word']!;
      _fullWord = wordObj['fullWord']!;
    } else {
      _word = '';
      _fullWord = '';
    }
    _attemptControllers = List.generate(
      maxAttempts,
      (_) => List.generate(_wordLength, (index) => TextEditingController()),
    );
    _attemptColors = List.generate(
      maxAttempts,
      (_) => List.generate(_wordLength, (index) => Colors.transparent),
    );
    _selectedFieldIndex = 0;
    _currentAttempt = 0;
    _usedLetters
        .clear(); // <-- Limpa as letras tentadas ao iniciar nova palavra
  }

  // Função utilitária para remover acentuação de uma string
  String _removeDiacritics(String str) {
    return str
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ÁÀÃÂÄ]'), 'A')
        .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
        .replaceAll(RegExp(r'[ÍÌÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ÓÒÕÔÖ]'), 'O')
        .replaceAll(RegExp(r'[ÚÙÛÜ]'), 'U')
        .replaceAll(RegExp(r'[Ç]'), 'C');
  }

  void _checkWord() {
    String guessedWord =
        _attemptControllers[_currentAttempt]
            .map((c) => _removeDiacritics(c.text.toLowerCase()))
            .join();
    String targetWord = _removeDiacritics(_word.toLowerCase());

    if (guessedWord.length < _wordLength) return;

    // Marcar letras tentadas
    setState(() {
      for (var c in guessedWord.characters) {
        _usedLetters.add(c.toUpperCase());
      }
    });

    // Avaliação das letras
    List<Color> colors = List.filled(
      _wordLength,
      const Color(0xFF8B8991),
    ); // cinza para erro
    List<bool> used = List.filled(_wordLength, false);

    // Verde: letra correta na posição correta
    for (int i = 0; i < _wordLength; i++) {
      if (guessedWord[i] == targetWord[i]) {
        colors[i] = const Color(0xFF4FB356); // verde customizado
        used[i] = true;
      }
    }
    // Amarelo: letra existe, mas fora de posição
    for (int i = 0; i < _wordLength; i++) {
      if (colors[i] == const Color(0xFF4FB356)) continue;
      for (int j = 0; j < _wordLength; j++) {
        if (!used[j] &&
            guessedWord[i] == targetWord[j] &&
            guessedWord[j] != targetWord[j]) {
          colors[i] = const Color(0xFFCFCF35); // amarelo customizado
          used[j] = true;
          break;
        }
      }
    }

    setState(() {
      _attemptColors[_currentAttempt] = colors;
      if (guessedWord == targetWord) {
        _showSuccessModal();
      } else if (_currentAttempt < maxAttempts - 1) {
        _currentAttempt++;
        _selectedFieldIndex = 0;
      } else {
        // Fim de tentativas, mostra modal de derrota
        _showFailModal();
      }
    });
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          children: [
            // Gif no canto inferior esquerdo
            Positioned(
              bottom: 30,
              left: 0,
              child: Image.asset(
                'assets/fireworks-putukan.gif',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            // Gif no canto inferior direito
            Positioned(
              bottom: 30,
              right: 0,
              child: Image.asset(
                'assets/fireworks-putukan.gif',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            // Modal central
            Center(
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Center(
                  child: Text(
                    'Parabéns!',
                    style: TextStyle(
                      color: Color(0xFF4FB356), // verde
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Você acertou a palavra!'),
                    const SizedBox(height: 12),
                    Text(
                      _fullWord.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF6591B5), // azul
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            child: const Text('Início'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6591B5),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Fecha o modal
                              setState(() {
                                if (_wordLength < 7) {
                                  _wordLength++;
                                }
                                _initializeWord();
                              });
                            },
                            child: const Text('Próxima'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFailModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          children: [
            // 4 gifs em posições diferentes (substitua os nomes pelos seus arquivos)
            Positioned(
              top: 20,
              left: 20,
              child: Image.asset(
                'assets/sad-gif.gif',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Image.asset(
                'assets/sad-gif.gif',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 40,
              child: Image.asset(
                'assets/sad-gif.gif',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 20,
              right: 40,
              child: Image.asset(
                'assets/sad-gif.gif',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            // Modal central
            Center(
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Center(
                  child: Text(
                    'Poxa!',
                    style: TextStyle(
                      color: Color(0xFFD02020), // vermelho
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('A palavra correta era'),
                    const SizedBox(height: 12),
                    Text(
                      _fullWord.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF6591B5), // azul
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: const Text('Início'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _onKeyPressed(String letter) {
    setState(() {
      if (_selectedFieldIndex < _wordLength) {
        if (_attemptControllers[_currentAttempt][_selectedFieldIndex]
            .text
            .isEmpty) {
          final idx = _selectedFieldIndex;
          final expectedLetter = _word.length > idx ? _word[idx] : '';
          final fullLetter = _fullWord.length > idx ? _fullWord[idx] : '';
          // Se a letra digitada for igual à letra sem acento e existe acento, já coloca a acentuada no campo (em maiúsculo)
          if (letter.toLowerCase() == expectedLetter &&
              fullLetter != expectedLetter) {
            _attemptControllers[_currentAttempt][idx].text =
                fullLetter.toUpperCase();
          } else {
            _attemptControllers[_currentAttempt][idx].text =
                letter.toUpperCase();
          }
          _attemptControllers[_currentAttempt][idx]
              .selection = TextSelection.fromPosition(
            TextPosition(
              offset: _attemptControllers[_currentAttempt][idx].text.length,
            ),
          );
          if (_selectedFieldIndex < _wordLength - 1) {
            _selectedFieldIndex++;
          }
        }
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_attemptControllers[_currentAttempt][_selectedFieldIndex]
          .text
          .isNotEmpty) {
        _attemptControllers[_currentAttempt][_selectedFieldIndex].text = '';
      } else if (_selectedFieldIndex > 0) {
        _selectedFieldIndex--;
        _attemptControllers[_currentAttempt][_selectedFieldIndex].text = '';
      }
    });
  }

  String _getDisplayLetter(int attempt, int index) {
    final text = _attemptControllers[attempt][index].text;
    if (text.isEmpty) return '';
    // O texto já está uppercase e, se necessário, com acento
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isSmallScreen = screenWidth < 600;
          // Ajuste: teclado sempre cabe na tela, teclas menores em telas pequenas
          final keyboardAreaWidth = screenWidth * 1.5;
          final keyGap = isSmallScreen ? 2.0 : 6.0;
          final keyboardButtonFontSize = isSmallScreen ? 13.0 : 19.0;

          // Layout do teclado conforme a imagem
          const row1 = 'Q W E R T Y U I O P';
          const row2 = ' A S D F G H J K L DEL';
          const row3 = '  Z X C V B N M ENTER';

          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight * 0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 8 : 16,
                      ),
                      child: Text(
                        'level ${_wordLength - 3}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Linhas de tentativas
                    Column(
                      children: List.generate(
                        maxAttempts,
                        (attempt) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_wordLength, (index) {
                              bool isActive = attempt == _currentAttempt;
                              // Use um tamanho base para os campos de tentativa
                              final double textFieldSize = min(
                                screenWidth * 0.15,
                                60,
                              );
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: textFieldSize,
                                  height: textFieldSize,
                                  child: TextField(
                                    controller:
                                        _attemptControllers[attempt][index],
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    readOnly: true,
                                    enabled: isActive,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: _attemptColors[attempt][index],
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              isActive &&
                                                      _selectedFieldIndex ==
                                                          index
                                                  ? Colors.blue
                                                  : Colors.grey,
                                        ),
                                      ),
                                      counterText: '',
                                    ),
                                    onTap:
                                        isActive
                                            ? () {
                                              setState(() {
                                                _selectedFieldIndex = index;
                                              });
                                            }
                                            : null,
                                    style: TextStyle(
                                      fontSize: textFieldSize * 0.6,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 16),
                    // Teclado
                    Container(
                      width: keyboardAreaWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Primeira linha do teclado
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildKeyboardRow(
                                row1.split(' '),
                                keyboardButtonFontSize,
                                keyGap,
                                screenWidth,
                                isSmallScreen,
                              ),
                            ),
                          ),
                          SizedBox(height: keyGap),
                          // Segunda linha do teclado
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildKeyboardRow(
                                row2.split(' '),
                                keyboardButtonFontSize,
                                keyGap,
                                screenWidth,
                                isSmallScreen,
                              ),
                            ),
                          ),
                          SizedBox(height: keyGap),
                          // Terceira linha do teclado
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: isSmallScreen ? 45.0 : 70.0),
                                ..._buildKeyboardRow(
                                  row3.split(' '),
                                  keyboardButtonFontSize,
                                  keyGap,
                                  screenWidth,
                                  isSmallScreen,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Refatore _buildKeyboardRow para colorir teclas já tentadas
  List<Widget> _buildKeyboardRow(
    List<String> keys,
    double fontSize,
    double keyGap,
    double screenWidth,
    bool isSmallScreen,
  ) {
    final double maxKeyWidth = isSmallScreen ? 32.0 : 50.0;
    final double maxKeyWidthDel = isSmallScreen ? 45.0 : 70.0;
    final double maxKeyWidthEnter = isSmallScreen ? 55.0 : 80.0;
    final double maxKeyHeight = isSmallScreen ? 32.0 : 50.0;

    return keys.map((key) {
      if (key.isEmpty) {
        return SizedBox(width: screenWidth * 0.001);
      }
      double keyWidth = min(screenWidth * 0.1, maxKeyWidth);
      if (key == 'DEL') {
        keyWidth = min(screenWidth * 0.15, maxKeyWidthDel);
      }
      if (key == 'ENTER') {
        keyWidth = min(screenWidth * 0.15, maxKeyWidthEnter);
      } else if (key == ' ') {
        keyWidth = min(screenWidth * 0.15, maxKeyWidth);
      }

      // Cor da tecla: azul se já tentada, senão padrão
      Color keyColor = const Color(0xFF8B8B8D);
      if (_usedLetters.contains(key.toUpperCase()) &&
          key != 'DEL' &&
          key != 'ENTER' &&
          key != ' ') {
        keyColor = const Color(0xFF6591B5);
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: keyGap / 1.2),
        child: SizedBox(
          width: keyWidth,
          height: maxKeyHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: keyColor,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (key == 'DEL') {
                _onBackspacePressed();
              } else if (key == 'ENTER') {
                _checkWord();
              } else if (key != ' ') {
                _onKeyPressed(key);
              }
            },
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
