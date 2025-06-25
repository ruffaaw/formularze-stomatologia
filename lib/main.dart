import 'package:flutter/material.dart';
// import 'package:formularze/screens/zadatek_screen.dart';
// import 'package:formularze/screens/ankieta_screen.dart';
import 'package:formularze/screens/treatment_plan_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Zadatek",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade800),
      ),

      home: const TreatmentPlanScreen(),
    );
  }
}
