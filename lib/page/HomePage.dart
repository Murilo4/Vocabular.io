import "package:flutter/material.dart";
import "package:vocabular_io/component/MessageButton.dart";
// Importe a tela do jogo
import 'package:vocabular_io/page/GamePage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateToGame(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(difficulty: difficulty)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double titleFontSize = size.width * 0.25; // ainda mais destaque
    final double buttonWidth = size.width * 0.90; // botões bem largos
    final double buttonHeight = size.height * 0.18; // botões bem altos
    final double buttonFontSize = size.width * 0.15; // fonte maior

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Garante centralização
              children: [
                // Nome do app estilizado centralizado acima dos botões
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 40.0),
                  child: Text(
                    "Vocabular.io",
                    style: TextStyle(
                      fontSize: titleFontSize.clamp(44, 70),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6591B5),
                      letterSpacing: 3,
                      fontFamily: 'Montserrat',
                      shadows: [
                        Shadow(
                          color: const Color(
                            0xFF000000,
                          ).withAlpha((0.18 * 255).toInt()),
                          offset: const Offset(2, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                MessageButton(
                  messageToDisplay: 'Fácil',
                  buttonText: 'Fácil',
                  width: buttonWidth,
                  height: buttonHeight,
                  backgroundColor: Colors.amber,
                  textColor: Colors.black,
                  fontSize: buttonFontSize.clamp(26, 44),
                  onPressed: () => _navigateToGame(context, 'facil'),
                ),
                const SizedBox(
                  height: 128,
                ), // Espaçamento maior entre os botões
              ],
            ),
          ),
        ),
      ),
    );
  }
}
