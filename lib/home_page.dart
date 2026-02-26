import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:audioplayers/audioplayers.dart';
import 'game_page.dart';
import 'levels_page.dart';
import 'settings_page.dart';

/// ================= SETTINGS STORAGE SERVICE =================
/// Handles saving and loading all audio settings locally
class SettingsService {

  /// Save all audio settings to local storage
  static Future<void> saveAllSettings(double vol, bool music, bool game, bool button) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', vol);
    await prefs.setBool('musicOn', music);
    await prefs.setBool('gameOn', game);
    await prefs.setBool('buttonOn', button);
  }

  /// Load all saved settings
  /// Returns defaults if nothing stored yet
  static Future<Map<String, dynamic>> loadAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'volume': prefs.getDouble('volume') ?? 0.5,
      'musicOn': prefs.getBool('musicOn') ?? true,
      'gameOn': prefs.getBool('gameOn') ?? true,
      'buttonOn': prefs.getBool('buttonOn') ?? true,
    };
  }
}

/// ================= HOME PAGE =================
/// Main menu screen of the game
class HomePage extends StatefulWidget {

  /// Global audio players used across app
  static final AudioPlayer musicPlayer = AudioPlayer();
  static final AudioPlayer buttonPlayer = AudioPlayer();
  static final AudioPlayer gamePlayer = AudioPlayer();

  /// Global sound toggles
  static bool musicOn = true;
  static bool buttonOn = true;
  static bool gameOn = true;

  /// Volume levels
  static double musicVolume = 0.5;
  static double buttonVolume = 1.0;
  static double gameVolume = 1.0;

  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {

  /// UI press animation flags
  bool isPlaying = false;
  bool isPressed1 = false;
  bool isPressed2 = false;
  bool continu = false;
  bool isPressedsettings = false;

  /// Sound button press animation
  static bool isPressedSound = false;

  /// Stores last played mode for "continue" feature
  static bool? lastVsComputer;
  static bool? lastVsPlayer;

  @override
  void initState() {
    super.initState();

    /// Observe app lifecycle to pause/resume music
    WidgetsBinding.instance.addObserver(this);

    /// Start music automatically if enabled
    if (HomePage.musicOn) {
      playMusic();
    }
  }

  /// ================= MUSIC CONTROL =================

  /// Plays background music in loop
  Future<void> playMusic() async {
    if (!HomePage.musicOn) return;

    await HomePage.musicPlayer.setReleaseMode(ReleaseMode.loop);
    await HomePage.musicPlayer.setVolume(HomePage.musicVolume);
    await HomePage.musicPlayer.play(AssetSource('musicz/bg_music.mp3'));
  }

  /// Pauses background music
  Future<void> stopMusic() async {
    await HomePage.musicPlayer.pause();
  }

  /// ================= NAVIGATION =================

  /// Opens settings page then refreshes UI on return
  void goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    ).then((_) => setState(() {}));
  }

  /// Start game vs computer
  void startGame(bool isVsComputer) async {
    lastVsComputer = isVsComputer;
    lastVsPlayer = false;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LevelsPage(vsComputer: isVsComputer)),
    ).then((_) {
      if (HomePage.musicOn) {
        playMusic();
      }
    });
  }

  /// Start game vs player
  void startGame3(bool isVsplayer) async {
    lastVsPlayer = isVsplayer;
    lastVsComputer = !isVsplayer;

    stopMusic();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(
          vsPlayer: isVsplayer,
          vsComputer: !isVsplayer,
          isHard: false,
        ),
      ),
    ).then((_) {
      if (HomePage.musicOn) playMusic();
    });
  }

  /// Restart last played game mode
  void restartLastGame() {
    if (lastVsComputer == null && lastVsPlayer == null) return;

    stopMusic();

    if (lastVsPlayer == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GamePage(vsPlayer: true, vsComputer: false, isHard: false),
        ),
      ).then((_) {
        if (HomePage.musicOn) playMusic();
      });

    } else if (lastVsComputer != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GamePage(
            vsPlayer: false,
            vsComputer: lastVsComputer!,
            isHard: false,
          ),
        ),
      ).then((_) {
        if (HomePage.musicOn) playMusic();
      });
    }
  }

  /// Remove lifecycle observer
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handle app background/foreground events
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      HomePage.musicPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (HomePage.musicOn) {
        HomePage.musicPlayer.resume();
      }
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Hidden AppBar only for status bar color
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.blueGrey[900]),

      body: Stack(
        children: [

          /// Background image
          Positioned.fill(
            child: Image.asset('assets/images/Bg_image.png', fit: BoxFit.fill),
          ),

          /// Player vs Player button area
          Positioned(
            top: 360,
            left: 40,
            width: 135,
            height: 160,
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressed1 = true),
              onTapUp: (_) {
                setState(() => isPressed1 = false);
                startGame3(true);
              },
              onTapCancel: () => setState(() => isPressed1 = false),

              /// Press animation
              child: AnimatedScale(
                scale: isPressed1 ? 0.95 : 1,
                duration: Duration(milliseconds: 100),

                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    boxShadow: isPressed1
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          /// Player vs Computer button area
          Positioned(
            top: 360,
            right: 30,
            width: 130,
            height: 160,
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressed2 = true),
              onTapUp: (_) {
                setState(() => isPressed2 = false);
                startGame(true);
              },
              onTapCancel: () => setState(() => isPressed2 = false),

              child: AnimatedScale(
                scale: isPressed2 ? 0.95 : 1,
                duration: Duration(milliseconds: 800),

                child: AnimatedContainer(
                  duration: Duration(milliseconds: 800),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isPressed2
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          /// Settings button area
          Positioned(
            top: 670,
            right: 7,
            width: 50,
            height: 70,
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressedsettings = true),
              onTapUp: (_) {
                setState(() => isPressedsettings = false);
                goToSettings();
              },
              onTapCancel: () => setState(() => isPressedSound = false),

              child: AnimatedScale(
                scale: isPressedsettings ? 0.95 : 1,
                duration: Duration(milliseconds: 0),

                child: AnimatedContainer(
                  duration: Duration(milliseconds: 0),
                  decoration: BoxDecoration(
                    boxShadow: isPressedsettings
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 10,
                            ),
                          ]
                        : [],
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          /// Sound toggle button
          Positioned(
            bottom: 38,
            left: 20,
            width: 50,
            height: 60,
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressedSound = true),
              onTapUp: (_) {
                setState(() {
                  isPressedSound = false;
                  HomePage.musicOn = !HomePage.musicOn;
                });

                /// Toggle music
                if (HomePage.musicOn) {
                  playMusic();
                } else {
                  stopMusic();
                }
              },
              onTapCancel: () {
                setState(() => HomePage.musicOn = false);
              },

              child: AnimatedScale(
                scale: isPressedSound ? 0.9 : 1,
                duration: const Duration(milliseconds: 0),

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  decoration: BoxDecoration(
                    boxShadow: isPressedSound
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                    color: const Color.fromARGB(255, 25, 31, 214).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  /// Show mute icon when music disabled
                  child: HomePage.musicOn
                      ? SizedBox()
                      : Image.asset("assets/images/mute.png", fit: BoxFit.fill),
                ),
              ),
            ),
          ),

          /// Continue last game button area
          Positioned(
            bottom: 30,
            right: 90,
            width: 140,
            height: 140,
            child: GestureDetector(onTap: restartLastGame),
          ),
        ],
      ),
    );
  }
}