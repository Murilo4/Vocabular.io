import 'package:flutter/material.dart';

class MessageButton extends StatelessWidget {
  final String messageToDisplay; // A String que o botão receberá
  final String buttonText; // O texto que aparecerá no botão
  final double? width; // Tamanho da largura do botão
  final double? height; // Tamanho da altura do botão
  final Color? backgroundColor; // Cor de fundo do botão
  final Color? textColor; // Cor do texto do botão
  final double? fontSize; // Tamanho da fonte do texto
  final VoidCallback? onPressed;

  const MessageButton({
    super.key,
    required this.messageToDisplay,
    required this.buttonText,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = this.backgroundColor ?? Theme.of(context).colorScheme.primary;
    final Color textColor = this.textColor ?? Theme.of(context).colorScheme.onPrimary;
    final double width = this.width ?? 200;
    final double height = this.height ?? 50;
    final double fontSize = this.fontSize ?? 16;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
        ).copyWith(),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Text(
                buttonText,
                style: TextStyle(fontSize: fontSize),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}