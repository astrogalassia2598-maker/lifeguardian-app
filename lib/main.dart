import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LifeGuardianApp());
}

class LifeGuardianApp extends StatelessWidget {
  const LifeGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeGuardian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
