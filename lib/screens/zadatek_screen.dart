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

  final TextEditingController paymentController = TextEditingController(
    text: "500",
  );
  final TextEditingController penaltyPriceController = TextEditingController(
    text: "250",
  );

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
    super.dispose();
  }

  Widget _buildAmountField(TextEditingController controller) {
    return SizedBox(
      width: inputFieldWidth,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d{0,2}')),
        ],
        style: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: inputPadding,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    String hintText = 'wybierz opcję',
  }) {
    return DropdownButton<String>(
      value: value,
      hint: Text(hintText, style: baseTextStyle.copyWith(color: Colors.grey)),
      underline: const SizedBox(),
      style: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item["value"],
          child: Text(item["label"]!),
        );
      }).toList(),
      onChanged: onChanged,
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
                      _buildAmountField(paymentController),
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
                      _buildAmountField(penaltyPriceController),
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
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: SfSignaturePad(
                      key: _signaturePadKey,
                      minimumStrokeWidth: 4,
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
