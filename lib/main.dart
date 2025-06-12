import 'package:flutter/material.dart';
import 'package:vocabular_io/page/GamePage.dart'; // Make sure this path is correct
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

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

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _videoPlayerController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Flag to track the video controller's initialization state
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
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
        if (_videoPlayerController.value.hasError) {
        }
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
                ElevatedButton(
                  onPressed: () {
                    _playSound('menu_click'); // Play sound on button click
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GamePage(difficulty: 'Fácil'),
                      ),
                    );
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