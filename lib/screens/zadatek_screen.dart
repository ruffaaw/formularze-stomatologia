import 'package:flutter/material.dart';
import 'package:formularze/components/header.dart';

class ZadatekScreen extends StatefulWidget {
  const ZadatekScreen({super.key});

  @override
  State<ZadatekScreen> createState() => _ZadatekScreenState();
}

class _ZadatekScreenState extends State<ZadatekScreen> {
  String? selectedService;
  TextEditingController paymentController = TextEditingController(text: "500");

  final List<Map<String, String>> services = [
    {'value': 'zakladanie_aparatu', 'label': 'zakładanie aparatu'},
    {'value': 'odbior_aparatu', 'label': 'odbiór aparatu'},
    {'value': 'wybielanie_zebow', 'label': 'wybielanie zębów'},
    {'value': 'higienizacja', 'label': 'higienizację'},
  ];

  final double baseFontSize = 16;
  final EdgeInsets basePadding = EdgeInsets.symmetric(horizontal: 40.0);
  final TextStyle baseTextStyle = TextStyle(fontSize: 16, color: Colors.black);

  @override
  void dispose() {
    paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(40.0), child: const Header()),
            Container(
              alignment: Alignment.centerLeft,
              padding: basePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Szanowni Państwo,", style: baseTextStyle),
                  const SizedBox(height: 8),

                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "W celu rezerwacji terminu na ",
                        style: baseTextStyle,
                      ),
                      DropdownButton<String>(
                        value: selectedService,
                        underline: const SizedBox(),
                        style: baseTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        items: services.map((service) {
                          return DropdownMenuItem(
                            value: service["value"],
                            child: Text(service["label"]!),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedService = newValue;
                          });
                        },
                      ),
                      Text(
                        " potwierdzam wpłatę zadatku w wysokości ",
                        style: baseTextStyle,
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: paymentController,
                          keyboardType: TextInputType.number,
                          style: baseTextStyle,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Text(" zł w recepcji ", style: baseTextStyle),
                      Text("Gabinetu Ortodontycznego ", style: baseTextStyle),
                      Text("Agnieszka ", style: baseTextStyle),
                      Text("Golarz-Nosek.", style: baseTextStyle),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
