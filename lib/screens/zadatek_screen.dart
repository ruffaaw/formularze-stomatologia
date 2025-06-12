import 'package:flutter/material.dart';
import 'package:formularze/components/header.dart';

class ZadatekScreen extends StatefulWidget {
  const ZadatekScreen({super.key});

  @override
  State<ZadatekScreen> createState() => _ZadatekScreenState();
}

class _ZadatekScreenState extends State<ZadatekScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [Padding(padding: EdgeInsets.all(16.00), child: Header())],
        ),
      ),
    );
  }
}
