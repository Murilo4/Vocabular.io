import 'package:flutter/material.dart';
import 'package:vocabular_io/page/GamePage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'dart:math'; // Adicione esta linha

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Flag to track the video controller's initialization state
  bool _isControllerInitialized = false;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Mais rápido
    )..repeat();
  }

  /// Loads, initializes, and configures the background video asset using VideoPlayer.
  Future<void> _loadVideo() async {
    // Define the asset path for the video
    String videoAssetPath = 'assets/videos/background_video.mp4'; // Your video

    // Create the video controller from the asset
    _videoPlayerController = VideoPlayerController.asset(videoAssetPath);
    print('Video controller created for asset: $videoAssetPath');

    try {
      // Initialize the VideoPlayerController and then update state
      await _videoPlayerController.initialize().then((_) async {
        await _videoPlayerController.setVolume(0.0);
        // Set the video to loop
        await _videoPlayerController.setLooping(true);
        // Start playing the video
        await _videoPlayerController.play();

        setState(() {
          _isControllerInitialized = true; // Mark as initialized successfully
        });
      });

      // Add a listener to the videoPlayerController to observe its state changes
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.hasError) {}
        // You can add more detailed logging here if needed, but setState is handled by the .then above
      });
    } catch (e) {
      setState(() {
        _isControllerInitialized = false; // Mark as not initialized on error
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  /// Plays a sound effect from assets.
  Future<void> _playSound(String soundName) async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/$soundName.mp3'),
        volume: 0.2, // Adjust volume as needed
      );
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video background using VideoPlayer
          _isControllerInitialized && _videoPlayerController.value.isInitialized
              ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoPlayerController.value.size.width,
                    height: _videoPlayerController.value.size.height,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                ),
              )
              : const Center(
                // Show a white circular progress indicator for better visibility
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          // Centered content (e.g., "Iniciar Novo Jogo" button)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    final text = 'Vocabular.io';
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(text.length, (i) {
                        final char = text[i];
                        // Onda mais natural e rápida
                        final double offsetY = 8 * sin(-2 * pi * _waveController.value + i * 0.3);
                        return Transform.translate(
                          offset: Offset(0, offsetY),
                          child: Text(
                            char,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.purpleAccent,
                              shadows: [
                                Shadow(offset: Offset(-1, -1), color: Colors.black),
                                Shadow(offset: Offset(1, -1), color: Colors.black),
                                Shadow(offset: Offset(-1, 1), color: Colors.black),
                                Shadow(offset: Offset(1, 1), color: Colors.black),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                SizedBox(height: 40), // Space between title and button
                ElevatedButton(
                  onPressed: () {
                    _playSound('menu_click'); // Play sound on button click
                    Navigator.of(context).push(_createRoute());
                  },
                  child: const Text('Iniciar Novo Jogo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Função para criar a rota com animação de slide
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GamePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Começa da direita
      const end = Offset.zero;
      const curve = Curves.ease;

      final tween = Tween(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.ease));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: Duration(milliseconds: 1200), // Mais lento
  );
}        


