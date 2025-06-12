import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart'; // Importe o pacote

// Definição das palavras por nível
const palavras = {
  'level1': [
    {'word': 'casa', 'fullWord': 'casa'},
    {'word': 'chao', 'fullWord': 'chão'},
    {'word': 'bolo', 'fullWord': 'bolo'},
    {'word': 'pato', 'fullWord': 'pato'},
  ],
  'level2': [
    // 5 letters
    {'word': 'casco', 'fullWord': 'casco'},
    {'word': 'visao', 'fullWord': 'visão'},
    {'word': 'legal', 'fullWord': 'legal'},
    {'word': 'prato', 'fullWord': 'prato'},
  ],
  'level3': [
    // 6 letters
    {'word': 'exceto', 'fullWord': 'exceto'},
    {'word': 'futuro', 'fullWord': 'futuro'},
    {'word': 'grande', 'fullWord': 'grande'},
    {'word': 'melhor', 'fullWord': 'melhor'},
  ],
  'level4': [
    // 7 letters
    {'word': 'tecnico', 'fullWord': 'técnico'},
    {'word': 'esconde', 'fullWord': 'esconde'},
    {'word': 'janelas', 'fullWord': 'janelas'},
    {'word': 'passaro', 'fullWord': 'pássaro'},
  ],
  'level5': [
    // 8 letters
    {'word': 'abstrato', 'fullWord': 'abstrato'},
    {'word': 'brasileiro', 'fullWord': 'brasileiro'},
    {'word': 'chocolate', 'fullWord': 'chocolate'},
    {'word': 'dinheiro', 'fullWord': 'dinheiro'},
  ],
};

class GamePage extends StatefulWidget {
  final String difficulty;

  const GamePage({super.key, required this.difficulty});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String _word = '';
  String _fullWord = '';
  int _wordLength = 4;
  int _selectedFieldIndex = 0;

  // Progresso do nível: quantas palavras já acertou neste nível
  int _levelProgress = 0;
  // Palavras já usadas neste nível (para não repetir)
  final Set<String> _usedWordsInLevel = {};

  // Remover o static const int maxAttempts = 6;
  // Cada linha é uma tentativa, cada tentativa é uma lista de controllers
  List<List<TextEditingController>> _attemptControllers = [];
  List<List<Color>> _attemptColors = [];
  int _currentAttempt = 0;

  // Novo: letras já tentadas
  final Set<String> _usedLetters = {};

  // Novo getter para tentativas máximas
  int get maxAttempts => _wordLength >= 6 ? 7 : 6;

  final AudioPlayer _audioPlayer =
      AudioPlayer(); // Crie uma instância do AudioPlayer

  @override
  void initState() {
    super.initState();
    _initializeWord();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initializeWord({bool resetLevel = false}) {
    if (resetLevel) {
      _levelProgress = 0;
      _usedWordsInLevel.clear();
    }
    // Seleciona o nível baseado no tamanho da palavra
    String level = 'level${_wordLength - 3}';
    final levelWords = palavras[level] ?? [];
    final availableWords =
        levelWords
            .where((w) => !_usedWordsInLevel.contains(w['word']!))
            .toList();
    if (availableWords.isNotEmpty) {
      final random = Random();
      final wordObj = availableWords[random.nextInt(availableWords.length)];
      _word = wordObj['word']!;
      _fullWord = wordObj['fullWord']!;
      _usedWordsInLevel.add(_word);
    } else {
      _usedWordsInLevel.clear();
      final wordObj = levelWords[Random().nextInt(levelWords.length)];
      _word = wordObj['word']!;
      _fullWord = wordObj['fullWord']!;
      _usedWordsInLevel.add(_word);
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
    _usedLetters.clear();
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

  Future<void> _playSound(String soundName) async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/$soundName.mp3'),
        volume: 0.6,
      );
    } catch (e) {
      print("Error playing sound: $e");
    }
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
        _playSound('correct'); // Som de acerto
        _levelProgress++;
        if (_levelProgress >= 3) {
          if (_wordLength >= 7) {
            _playSound('level_completed'); // Som de vitória final
            _showFinalLevelModal();
          } else {
            _showSuccessModal(levelCompleted: true);
          }
        } else {
          _showSuccessModal(levelCompleted: false);
        }
      } else if (_currentAttempt < maxAttempts - 1) {
        _currentAttempt++;
        _selectedFieldIndex = 0;
      } else {
        _playSound('incorrect'); // Som de erro
        _showFailModal();
      }
    });
  }

  void _showSuccessModal({required bool levelCompleted}) {
    // Play sound with a delay to ensure modal is fully presented
    Future.delayed(const Duration(milliseconds: 200), () {
      _playSound('correct');
    });

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
                    if (!levelCompleted)
                      Text(
                        'Falta${3 - _levelProgress == 1 ? '' : 'm'} ${3 - _levelProgress} palavra${3 - _levelProgress == 1 ? '' : 's'} para avançar!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4FB356),
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                              Navigator.of(context).pop();
                              setState(() {
                                if (levelCompleted) {
                                  if (_wordLength < 7) {
                                    _wordLength++;
                                  }
                                  _levelProgress = 0;
                                  _usedWordsInLevel.clear();
                                }
                                _initializeWord(resetLevel: levelCompleted);
                              });
                            },
                            child: Text(
                              levelCompleted
                                  ? 'Próximo nível'
                                  : 'Próxima palavra',
                            ),
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

  void _showFinalLevelModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Play sound with a delay to ensure modal is fully presented
        Future.delayed(const Duration(milliseconds: 200), () {
          _playSound('correct');
          _playSound('game_completed');
        });
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
                    const Text(
                      'E finalizou todos os niveis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4FB356),
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
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
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6591B5),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _levelProgress = 0;
                            _usedWordsInLevel.clear();
                            _initializeWord(resetLevel: true);
                          });
                        },
                        child: const Text('Reiniciar nível'),
                      ),
                    ],
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
    _playSound('keyboard_click'); // Som ao clicar no teclado
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
    _playSound('delete_click'); // Som ao clicar no backspace
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

          // Ajuste para level >= 3 (palavras de 6 letras ou mais)
          final bool isLevel3OrMore = _wordLength >= 6;
          final double keyboardAreaWidth = screenWidth * 1.5;
          final keyGap = isSmallScreen ? 2.0 : 6.0;
          final keyboardButtonFontSize =
              isLevel3OrMore
                  ? (isSmallScreen ? 11.0 : 15.0)
                  : (isSmallScreen ? 13.0 : 19.0);

          // Layout do teclado conforme a imagem
          const row1 = 'Q W E R T Y U I O P';
          const row2 = ' A S D F G H J K L DEL';
          const row3 = ' Z X C V B N M ENTER';

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
                          fontSize:
                              isLevel3OrMore
                                  ? (isSmallScreen ? 13 : 18)
                                  : (isSmallScreen ? 16 : 22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Barra de progresso (3 pontos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Icon(
                              Icons.circle,
                              size: isSmallScreen ? 16 : 22,
                              color:
                                  i < _levelProgress
                                      ? const Color(0xFF4FB356)
                                      : Colors.grey[400],
                            ),
                          );
                        }),
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
                              // Ajuste tamanho dos quadrados e fonte para level 3 e 4
                              double textFieldSize;
                              double textFontSize;
                              if (_wordLength == 6) {
                                textFieldSize = min(screenWidth * 0.12, 44);
                                textFontSize = textFieldSize * 0.48;
                              } else if (_wordLength >= 7) {
                                textFieldSize = min(screenWidth * 0.11, 38);
                                textFontSize =
                                    textFieldSize * 0.38; // menor para level 4+
                              } else {
                                textFieldSize = min(screenWidth * 0.15, 60);
                                textFontSize = textFieldSize * 0.6;
                              }
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
                                      fontSize: textFontSize,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      height: 1.0,
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
                    SizedBox(
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
        }, // This is the correct closing brace for the builder function
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
                _playSound('enter_click');
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
