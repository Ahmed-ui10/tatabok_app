import 'package:flutter/material.dart';
import 'home_page.dart';

class SettingsPage extends StatefulWidget {
  // Static variables to control sound settings across the app
  static bool gameSoundsOn = true;
  static bool buttonSoundsOn = true;

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double volume = 0.5;     // Local volume value (not main controller)
  bool backPressed = false; // Tracks back button press animation
  bool eqPressed = false;   // (Reserved) Equalizer button state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hidden AppBar just to control status bar color
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.blueGrey[900],
      ),

      body: Stack(
        children: [

          /// ===== Background Image =====
          Positioned.fill(
            child: Image.asset(
              'assets/images/Settings_page.png',
              fit: BoxFit.fill,
            ),
          ),

          /// ===== Back Button =====
          Positioned(
            top: 45,
            left: 15,
            child: GestureDetector(
              onTapDown: (_) => setState(() => backPressed = true),
              onTapUp: (_) {
                setState(() => backPressed = false);
                Navigator.pop(context);
              },
              onTapCancel: () => setState(() => backPressed = false),

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: backPressed
                      ? Colors.black.withOpacity(0.6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),

                // Icon hidden because image already contains back button graphic
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.transparent,
                  size: 30,
                ),
              ),
            ),
          ),

          /// ===== Music Toggle =====
          Positioned(
            top: 378,
            right: 30,
            child: Switch(
              value: HomePage.musicOn,
              onChanged: (val) {
                setState(() {
                  HomePage.musicOn = val;

                  // Play or pause music
                  if (val) {
                    HomePage.musicPlayer.resume();
                  } else {
                    HomePage.musicPlayer.pause();
                  }
                });

                // Save settings
                SettingsService.saveAllSettings(
                  HomePage.musicVolume,
                  HomePage.musicOn,
                  HomePage.gameOn,
                  HomePage.buttonOn,
                );
              },
            ),
          ),

          /// ===== Button Sounds Toggle =====
          Positioned(
            top: 275,
            right: 30,
            child: Switch(
              value: HomePage.buttonOn,
              onChanged: (val) {
                setState(() {
                  HomePage.buttonOn = val;
                });

                SettingsService.saveAllSettings(
                  HomePage.musicVolume,
                  HomePage.musicOn,
                  HomePage.gameOn,
                  HomePage.buttonOn,
                );
              },
            ),
          ),

          /// ===== Game Sounds Toggle =====
          Positioned(
            top: 205,
            right: 30,
            child: Switch(
              value: HomePage.gameOn,
              onChanged: (val) {
                setState(() {
                  HomePage.gameOn = val;
                });

                SettingsService.saveAllSettings(
                  HomePage.musicVolume,
                  HomePage.musicOn,
                  HomePage.gameOn,
                  HomePage.buttonOn,
                );
              },
            ),
          ),

          /// ===== Volume Slider =====
          Positioned(
            bottom: 280,
            left: 50,
            right: 50,
            child: Slider(
              value: HomePage.musicVolume,
              min: 0,
              max: 1,

              onChanged: (v) {
                setState(() {
                  HomePage.musicVolume = v;
                  HomePage.musicPlayer.setVolume(v);
                });

                SettingsService.saveAllSettings(
                  HomePage.musicVolume,
                  HomePage.musicOn,
                  HomePage.gameOn,
                  HomePage.buttonOn,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}