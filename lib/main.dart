import 'package:flutter/material.dart';
import 'package:vocabular_io/page/HomePage.dart';
import 'package:vocabular_io/page/GamePageEasyMode.dart';
import 'package:vocabular_io/page/GamePageHardMode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocabular.io',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabular.io - Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            GamePage(difficulty: 'Fácil'), // GamePageEasyMode
                  ),
                );
              },
              child: const Text('Jogo Fácil'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GamePageHardMode(difficulty: 'Difícil'),
                  ),
                );
              },
              child: const Text('Jogo Difícil'),
            ),
          ],
        ),
      ),
    );
  }
}
