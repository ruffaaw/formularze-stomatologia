import 'package:flutter/material.dart';
import 'package:formularze/screens/zadatek_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Zadatek",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ZadatekScreen(),
    );
  }
}
