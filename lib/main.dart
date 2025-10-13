import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'config/app_config.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(() {
    AppConfig.testMode = true; // Infinite coins & relaxed constraints
    return true;
  }());
  // Add audio logging
  AudioLogger.logLevel = AudioLogLevel.info;
  print('APP: Starting with audio logging enabled');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Pet Companion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
