import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formularze/components/header.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class ZadatekScreen extends StatefulWidget {
  const ZadatekScreen({super.key});

  @override
  State<ZadatekScreen> createState() => _ZadatekScreenState();
}

class _ZadatekScreenState extends State<ZadatekScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  String? selectedService;
  String? selectedApplianceType;

  final TextEditingController paymentController = TextEditingController();
  final TextEditingController penaltyPriceController = TextEditingController();
  TextEditingController patientNameController = TextEditingController();

  static const double baseFontSize = 16;
  static const double inputFieldWidth = 100;
  static const double sectionSpacing = 16;
  static const EdgeInsets basePadding = EdgeInsets.symmetric(horizontal: 40.0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 5,
  );

  final TextStyle baseTextStyle = const TextStyle(
    fontSize: baseFontSize,
    color: Colors.black,
  );

  final List<Map<String, String>> serviceTypes = [
    {'value': 'zakladanie_aparatu', 'label': 'zakładanie aparatu'},
    {'value': 'odbior_aparatu', 'label': 'odbiór aparatu'},
    {'value': 'wybielanie_zebow', 'label': 'wybielanie zębów'},
    {'value': 'higienizacja', 'label': 'higienizację'},
  ];

  final List<Map<String, String>> applianceTypes = [
    {"value": "aparat_stały", "label": "aparat stały"},
    {"value": "aparat_ruchomy", "label": "aparat ruchomy"},
    {"value": "wybielanie_zębów", "label": "wybielanie zębów"},
    {"value": "higienizację", "label": "higienizację"},
  ];

  @override
  void dispose() {
    paymentController.dispose();
    penaltyPriceController.dispose();
    patientNameController.dispose();
    super.dispose();
  }

  Widget _buildAmountField({
    required TextEditingController? controller,
    required String price,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 120, // Możesz dostosować szerokość
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: price,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          validator: required
              ? (value) =>
                    value?.trim().isEmpty ?? true ? 'Pole wymagane' : null
              : null,
        ),
      ),
    );
  }

  Widget _buildPatientNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: patientNameController,
        decoration: InputDecoration(
          labelText: "Imię i nazwisko",
          hintText: "Wprowadź imię i nazwisko",
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1.5,
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
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'To pole jest wymagane';
          }
          return null;
        },
        autofocus: false,
        textCapitalization: TextCapitalization.words,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    String hintText = 'wybierz opcję',
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 200,
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            isDense: true,
          ),
          hint: Text(
            hintText,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          dropdownColor: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item["value"],
              child: Text(item["label"]!, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: required
              ? (value) => value == null ? 'Wymagane' : null
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(40.0), child: Header()),

            Container(
              alignment: Alignment.centerLeft,
              padding: basePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientNameField(),
                  Text("Szanowni Państwo,", style: baseTextStyle),
                  SizedBox(height: sectionSpacing),

                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "W celu rezerwacji terminu na ",
                        style: baseTextStyle,
                      ),
                      _buildDropdown(
                        value: selectedService,
                        items: serviceTypes,
                        onChanged: (newValue) =>
                            setState(() => selectedService = newValue),
                      ),
                      Text(
                        " potwierdzam wpłatę zadatku w wysokości ",
                        style: baseTextStyle,
                      ),
                      _buildAmountField(
                        controller: paymentController,
                        price: "500",
                      ),
                      Text(" zł w recepcji ", style: baseTextStyle),
                      Text("Gabinetu Ortodontycznego ", style: baseTextStyle),
                      Text("Agnieszka ", style: baseTextStyle),
                      Text("Golarz-Nosek.", style: baseTextStyle),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),

                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "W przypadku rezygnacji z leczenia lub nie przybycia na wizytę zadatek na ",
                        style: baseTextStyle,
                      ),
                      _buildDropdown(
                        value: selectedApplianceType,
                        items: applianceTypes,
                        onChanged: (newValue) =>
                            setState(() => selectedApplianceType = newValue),
                      ),
                      Text(" nie podlega zwrotowi.", style: baseTextStyle),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ważność skanu wewnątrzustego wynosi na:",
                        style: baseTextStyle,
                      ),
                      SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "- aparat stały - 6 miesięcy",
                              style: baseTextStyle,
                            ),
                            Text(
                              "- aparat ruchomy - 2 miesiące",
                              style: baseTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),

                  Wrap(
                    children: [
                      Text(
                        "W przypadku zmiany terminu wizyty ze strony pacjenta prosimy o informację "
                        "o odwołaniu wizyty telefonicznie na nr 601 949 752 lub e-mailem na "
                        "gabinet@golarz.pl, najpóźniej 24 godziny przed planową wizytą. Brak "
                        "powiadomienia skutkuje obciążeniem pacjenta kwotą za rezerwację wizyty "
                        "w wysokości ",
                        style: baseTextStyle,
                        textAlign: TextAlign.justify,
                      ),
                      _buildAmountField(
                        controller: penaltyPriceController,
                        price: "250",
                      ),
                      Text(" zł.", style: baseTextStyle),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),

                  Text(
                    "W razie problemów z odbiorem aparatu w wyznaczonym terminie, należy "
                    "odebrać go w terminie nie dłuższym niż 7 dni od początkowo ustalonej daty. "
                    "Jest to uwarunkowane migracją zębów i wystąpieniem trudności w założeniu aparatu.",
                    style: baseTextStyle,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionSpacing),
            Container(
              alignment: Alignment.center,
              padding: basePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "miejsce na podpis",
                    style: baseTextStyle.copyWith(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 200,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: SfSignaturePad(
                      key: _signaturePadKey,
                      minimumStrokeWidth: 2,
                      maximumStrokeWidth: 3,
                      strokeColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  ElevatedButton(
                    onPressed: () {
                      _signaturePadKey.currentState?.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                      "Wyczyść",
                      style: baseTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  Text(
                    "Podpis pacjenta lub opiekuna prawnego",
                    style: baseTextStyle,
                  ),
                  SizedBox(height: sectionSpacing),
                  ElevatedButton(
                    onPressed: () {
                      _signaturePadKey.currentState?.clear();
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

                    child: Text(
                      "Zapisz",
                      style: baseTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
