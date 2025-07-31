import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class StatementWithADentistScreen extends StatefulWidget {
  const StatementWithADentistScreen({super.key});

  @override
  State<StatementWithADentistScreen> createState() =>
      _StatementWithADentistScreenState();
}

class _StatementWithADentistScreenState
    extends State<StatementWithADentistScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  TextEditingController patientNameController = TextEditingController();

  static const double baseFontSize = 16;
  static const double sectionSpacing = 16;
  static const EdgeInsets basePadding = EdgeInsets.symmetric(horizontal: 40.0);

  final TextStyle baseTextStyle = const TextStyle(
    fontSize: baseFontSize,
    color: Colors.black,
  );

  @override
  void dispose() {
    patientNameController.dispose();
    super.dispose();
  }

  Widget _buildSingleSignatureColumn({
    required GlobalKey<SfSignaturePadState> key,
    required String label,
    required String buttonLabel,
  }) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: SfSignaturePad(
              key: key,
              minimumStrokeWidth: 2,
              maximumStrokeWidth: 3,
              strokeColor: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => key.currentState?.clear(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.red[900],
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: patientNameController,
        decoration: InputDecoration(
          hintText: 'Wprowadź $label...',
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        style: const TextStyle(fontSize: 16),
        maxLines: maxLines,
        validator: required
            ? (value) => value?.trim().isEmpty ?? true ? 'Pole wymagane' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Oświadczenie ze stomatologiem')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 300, // dopasuj szerokość
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: basePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Imię i nazwisko',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextFormField(label: 'Imię i nazwisko', required: true),
                  const SizedBox(height: 10),
                  Wrap(
                    children: [
                      Text(
                        "Zostałem/Zostałam poinformowany/poinformowana o konieczności wykonania przeglądu stomatologicznego u swojego stomatologa po zabiegu higienizacji.",
                        style: baseTextStyle,
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionSpacing),
            _buildSingleSignatureColumn(
              key: _signaturePadKey,
              label: 'Data i podpis pacjenta',
              buttonLabel: 'Wyczyść',
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await generateAndSavePDF(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.green[900],
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                child: Text('Zapisz', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> generateAndSavePDF(BuildContext context) async {
    Future<bool> _isSignatureEmpty() async {
      if (_signaturePadKey.currentState == null) return true;

      // Nowa metoda sprawdzania czy podpis istnieje
      final image = await _signaturePadKey.currentState!.toImage();
      final byteData = await image.toByteData();
      return byteData == null ||
          byteData.buffer.asUint8List().every((byte) => byte == 0);
    }

    // Walidacja pól formularza
    if (patientNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proszę wprowadzić imię i nazwisko pacjenta'),
        ),
      );
      return;
    }

    if (await _isSignatureEmpty()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Proszę złożyć podpis')));
      return;
    }

    // Tworzenie PDF
    final doc = pw.Document();
    final pdfTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load('assets/fonts/archivo.ttf')),
      bold: pw.Font.ttf(await rootBundle.load('assets/fonts/archivo-bold.ttf')),
    );
    final signatureImage = await _signaturePadKey.currentState!.toImage();
    final signatureBytes = await signatureImage.toByteData(
      format: ImageByteFormat.png,
    );

    final now = DateTime.now();
    final formattedDateTime =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final ByteData imageData = await rootBundle.load('assets/images/logo.png');
    final logo = pw.MemoryImage(imageData.buffer.asUint8List());

    doc.addPage(
      pw.Page(
        theme: pdfTheme,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Image(logo, width: 200, height: 80)),
                pw.SizedBox(height: 50),
                pw.Center(
                  child: pw.Header(
                    level: 0,
                    text: 'Oświadczenie ze stomatologiem',
                  ),
                ),
                _buildPdfTextField(
                  'Imię i nazwisko:',
                  patientNameController.text,
                ),
                pw.Text(
                  "Zostałem/Zostałam poinformowany/poinformowana o konieczności wykonania przeglądu stomatologicznego u swojego stomatologa po zabiegu higienizacji.",
                  style: pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.justify,
                ),
                pw.SizedBox(height: 50),

                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    children: [
                      pw.Text('Data i podpis pacjenta'),
                      pw.SizedBox(height: 10),
                      pw.Image(
                        pw.MemoryImage(signatureBytes!.buffer.asUint8List()),
                        width: 200,
                        height: 80,
                      ),
                      pw.SizedBox(height: 20),
                      pw.Text(
                        'Data: ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(top: 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        formattedDateTime,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Strona ${context.pageNumber} z ${context.pagesCount}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Zapis na dysk
    try {
      // Sprawdź uprawnienia
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Brak uprawnień do zapisu pliku');
      }
      final name = patientNameController.text.trim();
      final fileName =
          '${name}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}_oswiadczenie_ze_stomatologiem.pdf'
              .replaceAll(' ', '_')
              .replaceAll(RegExp(r'[^a-zA-Z0-9_.]'), '');
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/$fileName');

      try {
        final pdfBytes = await doc.save();
        await file.writeAsBytes(pdfBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plik zapisano w: ${file.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        throw Exception('Błąd podczas zapisywania pliku: $e');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas zapisywania PDF: $e')),
      );
    }
  }

  pw.Widget _buildPdfTextField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value.isNotEmpty ? value : 'brak'),
          ],
        ),
      ),
    );
  }
}
