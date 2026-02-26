import 'package:flutter/material.dart'; // Flutter UI framework
import 'home_page.dart'; // Import HomePage and shared settings

// Application entry point
void main() async {
  // Ensures Flutter binding is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved settings from storage service
  Map<String, dynamic> settings = await SettingsService.loadAllSettings();

  // Apply loaded settings to global HomePage variables
  HomePage.musicVolume = settings['volume'];   // Music volume level
  HomePage.musicOn = settings['musicOn'];      // Background music state
  HomePage.gameOn = settings['gameOn'];        // Game sounds state
  HomePage.buttonOn = settings['buttonOn'];    // Button sounds state

  // Launch the application
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: HomePage(), // First screen shown when app starts
    );
  }
}