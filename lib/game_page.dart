import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'home_page.dart';

// Main Game Screen Widget
class GamePage extends StatefulWidget {
  final bool vsComputer;
  final bool vsPlayer;
  final bool isHard;

  const GamePage({
    super.key,
    required this.vsComputer,
    required this.vsPlayer,
    required this.isHard,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

// Game logic + UI controller
class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  Timer? computerTimer; // Timer for AI turn delay

  bool backPressed3 = false;
  bool resetPressed = false;

  int score1 = 0;
  int score2 = 0;
  int imgLeft = 1;
  int imgRight = 2;

  String result = '';
  bool isPlayer1Turn = true;

  // Game ends when one player reaches 5 points
  bool get isGameOver => score1 >= 5 || score2 >= 5;

  @override
  void initState() {
    super.initState();
    // Observe app lifecycle (pause/resume)
    WidgetsBinding.instance.addObserver(this);
  }

  // Prepare an audio player with a file
  Future<void> setupAudio(AudioPlayer p, String file) async {
    await p.setPlayerMode(PlayerMode.lowLatency);
    await p.setSource(AssetSource('musicz/$file'));
    await p.setReleaseMode(ReleaseMode.stop);
  }

  // Play background music if enabled
  Future<void> playMusic() async {
    if (!HomePage.musicOn) return;

    await HomePage.musicPlayer.setReleaseMode(ReleaseMode.loop);
    await HomePage.musicPlayer.setVolume(HomePage.musicVolume);
    await HomePage.musicPlayer.play(AssetSource('musicz/bg_music.mp3'));
  }

  // Play short sound effect safely
  void playQuickSound(AudioPlayer p) async {
    try {
      if (p.state == PlayerState.playing) {
        await p.stop();
      }
      await p.resume();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    computerTimer?.cancel(); // Cancel AI timer
    super.dispose();
  }

  // Listen to app state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop AI timer if app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      computerTimer?.cancel();
    }
    // Resume AI turn when app returns
    else if (state == AppLifecycleState.resumed) {
      if (widget.vsComputer && !isPlayer1Turn && !isGameOver) {
        computerThinking();
      }
    }
  }

  // Reset game values
  void resetGame() {
    computerTimer?.cancel();
    setState(() {
      score1 = 0;
      score2 = 0;
      imgLeft = 1;
      imgRight = 2;
      result = '';
      isPlayer1Turn = true;
    });
  }

  // Main game logic for each move
  void playRound(int sideClicked) {
    if (isGameOver) return;

    // Prevent player input during AI turn
    if (widget.vsComputer && !isPlayer1Turn && sideClicked != -1) return;

    if (sideClicked != -1) {
      computerTimer?.cancel();
    }

    // Play button sound
    if (sideClicked != -1) {
      if (HomePage.buttonOn) {
        HomePage.buttonPlayer.setVolume(HomePage.buttonVolume);
        HomePage.buttonPlayer.play(AssetSource('musicz/button2.wav'));
      }
    }

    setState(() {
      // Player clicked left image
      if (sideClicked == 1) {
        imgLeft = Random().nextInt(9) + 1;
      }
      // Player clicked right image
      else if (sideClicked == 2) {
        imgRight = Random().nextInt(9) + 1;
      }
      // AI EASY MODE
      else if (!widget.isHard) {
        bool winMove = Random().nextInt(100) < 10; // 10% chance to match

        if (winMove) {
          // Force match
          if (Random().nextBool()) {
            imgLeft = imgRight;
          } else {
            imgRight = imgLeft;
          }
        } else {
          // Random move
          if (Random().nextBool()) {
            imgLeft = Random().nextInt(9) + 1;
          } else {
            imgRight = Random().nextInt(9) + 1;
          }
        }
      }
      // AI HARD MODE
      else {
        bool winMove = Random().nextInt(100) < 20; // 20% chance to match

        if (winMove) {
          // Smart match
          if (Random().nextBool()) {
            imgLeft = imgRight;
          } else {
            imgRight = imgLeft;
          }
        } else {
          // Logical random move
          if (Random().nextBool()) {
            imgLeft = Random().nextInt(9) + 1;
          } else {
            imgRight = Random().nextInt(9) + 1;
          }
        }
      }

      // If both images match → score point
      if (imgLeft == imgRight) {
        if (HomePage.gameOn) {
          HomePage.gamePlayer.setVolume(HomePage.gameVolume);
          HomePage.gamePlayer.play(AssetSource('musicz/point.mp3'));
        }

        if (isPlayer1Turn) {
          score1++;
        } else {
          score2++;
        }

        if (checkIfGameEnded()) return;

        // Continue AI turn if needed
        if (widget.vsComputer && !isPlayer1Turn) {
          computerThinking();
        }
      } else {
        // Switch turn
        isPlayer1Turn = !isPlayer1Turn;

        if (widget.vsComputer && !isPlayer1Turn) {
          computerThinking();
        }
      }
    });
  }

  // Check if someone won
  bool checkIfGameEnded() {
    if (score1 >= 5) {
      if (HomePage.gameOn) {
        HomePage.gamePlayer.setVolume(HomePage.gameVolume);
        HomePage.gamePlayer.play(AssetSource('musicz/win.mp3'));
      }

      setState(() {
        result = 'Player 1 Wins 🏆';
      });
      return true;
    }

    if (score2 >= 5) {
      if (HomePage.gameOn) {
        HomePage.gamePlayer.setVolume(HomePage.gameVolume);
        HomePage.gamePlayer.play(AssetSource('musicz/lose.mp3'));
      }

      setState(() {
        result = widget.vsComputer ? 'Computer Wins 🤖' : 'Player 2 Wins 🏆';
      });
      return true;
    }

    return false;
  }

  // Delay AI move to simulate thinking
  void computerThinking() {
    if (isGameOver) return;

    computerTimer = Timer(const Duration(milliseconds: 1250), () {
      if (mounted && !isGameOver) {
        playRound(-1); // -1 indicates AI move
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------------------- AppBar --------------------
      appBar: AppBar(
        toolbarHeight: 0, // Hides the default AppBar
        backgroundColor:
            Colors.blueGrey[900], // Background color for status bar
      ),

      // -------------------- Body --------------------
      body: Stack(
        children: [
          // -------------------- Background Image --------------------
          Positioned.fill(
            child: Image.asset(
              'assets/images/game.png',
              fit: BoxFit.fill, // Fill entire screen
            ),
          ),

          // -------------------- Back Button --------------------
          Positioned(
            top: 20,
            left: 10,
            child: GestureDetector(
              onTapDown: (_) =>
                  setState(() => backPressed3 = true), // Press animation
              onTapUp: (_) {
                setState(() => backPressed3 = false);
                Navigator.pop(context); // Go back to previous screen
                if (HomePage.musicOn)
                  playMusic(); // Resume background music if enabled
              },
              onTapCancel: () => setState(() => backPressed3 = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backPressed3
                      ? Colors.black.withOpacity(0.6)
                      : Colors.transparent, // Highlight on press
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.transparent, // Hidden icon, just for touch area
                  size: 30,
                ),
              ),
            ),
          ),

          // -------------------- Reset Button --------------------
          Positioned(
            top: 20,
            right: 8,
            child: GestureDetector(
              onTapDown: (_) => setState(() => resetPressed = true),
              onTapUp: (_) {
                setState(() => resetPressed = false);
                resetGame(); // Reset game state
              },
              onTapCancel: () => setState(() => resetPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: resetPressed
                      ? Colors.black.withOpacity(0.6)
                      : Colors.transparent, // Highlight on press
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.transparent, // Hidden icon
                  size: 30,
                ),
              ),
            ),
          ),

          // -------------------- Player 1 Score Display --------------------
          Positioned(
            top: 155,
            left: 35,
            child: Column(
              children: [
                Text(
                  "Player 1",
                  style: TextStyle(
                    color: isPlayer1Turn ? Colors.greenAccent : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "$score1", // Display current score
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // -------------------- Player 2 / Computer Score Display --------------------
          Positioned(
            top: 155,
            right: 30,
            child: Column(
              children: [
                Text(
                  widget.vsComputer ? "Computer" : "Player 2",
                  style: TextStyle(
                    color: !isPlayer1Turn ? Colors.blueAccent : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "$score2",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // -------------------- Game Result Banner --------------------
          if (isGameOver)
            Positioned(
              top: 350,
              right: 45,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 250,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 10, color: Colors.black45),
                  ],
                ),
                child: Text(
                  result, // Display winner message
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // -------------------- Turn Indicator --------------------
          if (!isGameOver)
            Positioned(
              top: 350,
              right: 65,
              child: Container(
                alignment: Alignment.center,
                width: 225,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isPlayer1Turn
                                  ? Colors.greenAccent
                                  : Colors.blueAccent)
                              .withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  isPlayer1Turn
                      ? "Player 1's Turn"
                      : (widget.vsComputer
                            ? "Computer's Turn"
                            : "Player 2's Turn"),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPlayer1Turn
                        ? Colors.greenAccent
                        : Colors.blue[400],
                  ),
                ),
              ),
            ),

          // -------------------- Dice Display & Interaction --------------------
          Positioned(
            top: 500,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Dice
                GestureDetector(
                  onTap: () => playRound(1), // Play left dice
                  child: Container(
                    height: 180,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        image: AssetImage('assets/images/image-$imgLeft.png'),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Right Dice
                GestureDetector(
                  onTap: () => playRound(2), // Play right dice
                  child: Container(
                    height: 180,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        image: AssetImage('assets/images/image-$imgRight.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
