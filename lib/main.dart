import 'package:flutter/material.dart';
import 'package:formularze/screens/statement_with_a_dentist.dart';
import 'package:formularze/screens/statement_with_varnish.dart';
import 'package:formularze/screens/statement_with_varnish_and_dentist.dart';
import 'package:formularze/screens/treatment_plan_screen.dart';
import 'package:formularze/screens/zadatek_screen.dart';
import 'package:formularze/screens/patient_questionnaire_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Formularze",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade800),
      ),
      home: const FormSelectionScreen(), // Ekran wyboru jako główny
    );
  }
}

class FormSelectionScreen extends StatelessWidget {
  const FormSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wybierz formularz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFormCard(
              context,
              icon: Icons.medical_services,
              title: 'Plan leczenia',
              description: 'Formularz planu leczenia ortodontycznego',
              screen: const TreatmentPlanScreen(),
            ),
            const SizedBox(height: 20),
            _buildFormCard(
              context,
              icon: Icons.note_add,
              title: 'Zadatek',
              description: 'Formularz przyjmowania zadatku',
              screen: const ZadatekScreen(),
            ),
            const SizedBox(height: 20),
            _buildFormCard(
              context,
              icon: Icons.person,
              title: 'Ankieta pacjenta',
              description: 'Formularz ankietowy dla pacjenta',
              screen: const PatientQuestionnaireScreen(),
            ),
            const SizedBox(height: 20),
            _buildFormCard(
              context,
              icon: Icons.assignment,
              title: 'Oświadczenie ze stomatologiem',
              description: 'Oświadczenie ze stomatologiem',
              screen: const StatementWithADentistScreen(),
            ),
            const SizedBox(height: 20),
            _buildFormCard(
              context,
              icon: Icons.assignment,
              title: 'Oświadczenie z lakierowaniem',
              description: 'Oświadczenie z lakierowaniem',
              screen: const StatementWithVarnishScreen(),
            ),
            const SizedBox(height: 20),
            _buildFormCard(
              context,
              icon: Icons.assignment,
              title: 'Oświadczenie z lakierowaniem i stomatologiem',
              description: 'Oświadczenie z lakierowaniem i stomatologiem',
              screen: const StatementWithVarnishAndDentistScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Widget screen,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
