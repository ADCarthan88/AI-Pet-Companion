import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable test mode automatically in debug builds (assert only executes in debug)
  assert(() {
    AppConfig.testMode = true; // Infinite coins & relaxed constraints
    return true;
  }());
  // In release, testMode remains false giving production starting coins.
  // Initialize app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Pet Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
