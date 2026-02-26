import 'package:flutter/material.dart';
import 'game_page.dart';
import 'home_page.dart';

/// LevelsPage allows the player to choose a difficulty level (Easy/Hard)
/// and navigate to the GamePage. It supports both vs Computer and vs Player modes.
class LevelsPage extends StatefulWidget {
  final bool vsComputer; // True if the player is playing against the computer
  const LevelsPage({super.key, required this.vsComputer});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  // -------------------- Music Control --------------------
  /// Stops/pause background music when navigating to the game.
  Future<void> stopMusic() async {
    await HomePage.musicPlayer.pause();
  }

  // -------------------- Button Press States --------------------
  bool backPressed = false;   // Tracks the visual press state of the back button
  bool easyPressed = false;   // Tracks the visual press state of the Easy button
  bool hardPressed = false;   // Tracks the visual press state of the Hard button

  // -------------------- Navigation Methods --------------------
  /// Navigate to GamePage with Hard difficulty
  void startGame2(bool isHard) async {
    stopMusic(); // Pause background music before starting the game
    if (!mounted) return; // Ensure widget is still mounted

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(
          vsComputer: isHard,          // True if vs computer
          vsPlayer: !widget.vsComputer, // True if vs another player
          isHard: true,                // Hard difficulty
        ),
      ),
    );
  }

  /// Navigate to GamePage with Easy difficulty
  void startGame(bool isEasy) async {
    stopMusic();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(
          vsComputer: isEasy,
          vsPlayer: !widget.vsComputer,
          isHard: false,               // Easy difficulty
        ),
      ),
    );
  }

  // -------------------- UI Build Method --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------------------- AppBar --------------------
      appBar: AppBar(
        toolbarHeight: 0,            // Hide the default AppBar
        backgroundColor: Colors.blueGrey[900],
      ),

      // -------------------- Main Body --------------------
      body: Stack(
        children: [
          // -------------------- Background Image --------------------
          Positioned.fill(
            child: Image.asset(
              'assets/images/levels.png',
              fit: BoxFit.fill,       // Fill the whole screen
            ),
          ),

          // -------------------- Easy Level Button --------------------
          Positioned(
            top: 250,
            left: 40,
            right: 40,
            child: GestureDetector(
              // Press-down animation
              onTapDown: (_) => setState(() => easyPressed = true),
              // Release and navigate to Easy game
              onTapUp: (_) {
                setState(() => easyPressed = false);
                startGame(true);
              },
              onTapCancel: () => setState(() => easyPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                height: 100,
                decoration: BoxDecoration(
                  color: easyPressed
                      ? Colors.black.withOpacity(0.25) // Highlight when pressed
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // -------------------- Hard Level Button --------------------
          Positioned(
            top: 390,
            left: 40,
            right: 40,
            child: GestureDetector(
              onTapDown: (_) => setState(() => hardPressed = true),
              onTapUp: (_) {
                setState(() => hardPressed = false);
                startGame2(true); // Navigate to Hard game
              },
              onTapCancel: () => setState(() => hardPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                height: 100,
                decoration: BoxDecoration(
                  color: hardPressed
                      ? Colors.black.withOpacity(0.25) // Highlight on press
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // -------------------- Back Button --------------------
          Positioned(
            top: 45,
            left: 15,
            child: GestureDetector(
              onTapDown: (_) => setState(() => backPressed = true), // Press effect
              onTapUp: (_) {
                setState(() => backPressed = false);
                Navigator.pop(context); // Navigate back to previous page
              },
              onTapCancel: () => setState(() => backPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backPressed
                      ? Colors.black.withOpacity(0.6) // Highlight on press
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.transparent, // Hidden icon to increase tap area
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}