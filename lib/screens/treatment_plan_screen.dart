import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class TreatmentPlanScreen extends StatefulWidget {
  const TreatmentPlanScreen({super.key});

  @override
  State<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKeyDoctor = GlobalKey();
  final GlobalKey<SfSignaturePadState> _signaturePadKeyPatient = GlobalKey();
  String _selectedLanguage = 'pl';
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _treatmentOptions = {};
  final Map<String, String?> _estimateItems = {};
  double _totalPrice = 0.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Translations
  final Map<String, Map<String, String>> _translations = {
    'pl': {
      'title': 'Plan leczenia',
      'yes': 'tak',
      'no': 'nie',
      'attention': 'Dodatkowe informacje',
      'page_header':
          'Plan leczenia - gabinet ortodontyczny Agnieszka Golarz-Nosek',
      'name': 'Imię i nazwisko',
      'recognition': 'Rozpoznanie',
      'non-extraction_treatment': 'Leczenie nieekstrakcyjne',
      'teeth_extraction': 'Ekstrakcje zębów',
      'mobile_denture_teeth': 'Aparat zdejmowany',
      'fixed_top_denture_teeth': 'Aparat stały górny',
      'fixed_bottom_denture_teeth': 'Aparat stały dolny',
      'additional_denture_teeth': 'Aparaty dodatkowe',
      'surgery': 'Zabiegi chirurgiczne',
      'treatment_plan_attention':
          'Uwaga! Plan leczenia może ulec zmianie w zależności od sytuacji klinicznej',
      'treatment_plan_accept': 'Akceptuje proponowany plan leczenia',
      'signature_doctor': 'Pieczątka i podpis lekarza',
      'signature_patient': 'Podpis pacjenta lub opiekuna prawnego',
      'concent_for_treatment_title':
          'INFORMACJE DLA PACJENTA I ŚWIADOMA ZGODA NA LECZENIE ORTODONTYCZNE',
      'complications_section_title':
          'Powikłania w trakcie i po leczeniu ortodontycznym',
      // ... wszystkie inne tłumaczenia po polsku
    },
    'en': {
      'title': 'Treatment plan',
      'yes': 'yes',
      'no': 'no',
      'attention': 'Additional information',
      'page_header':
          'Treatment plan - Agnieszka Golarz-Nosek Orthodontic Office',
      'name': 'Name',
      'recognition': 'Recognition',
      'non-extraction_treatment': 'Non-extractive treatment',
      'teeth_extraction': 'Extraction of teeth',
      'mobile_denture_teeth': 'Removable appliances',
      'fixed_top_denture_teeth': 'Fixed upper appliances',
      'fixed_bottom_denture_teeth': 'Fixed lower appliances',
      'additional_denture_teeth': 'Additional appliances',
      'surgery': 'Surgical procedures',
      'treatment_plan_attention':
          'Warning! Treatment plan may change depending on clinical situation',
      'treatment_plan_accept': 'I accept the proposed treatment plan',
      'signature_doctor': 'Signature of the doctor',
      'signature_patient': 'Signature of the patient / guardian',
      'concent_for_treatment_title':
          'PATIENT INFORMATION AND INFORMED CONSENT FOR ORTHODONTIC TREATMENT',
      'complications_section_title':
          'Complications during and after orthodontic treatment',
      // ... wszystkie inne tłumaczenia po angielsku
    },
  };

  final List<String> _treatmentPlanOptions = [
    'non-extraction_treatment',
    'teeth_extraction',
    'mobile_denture_teeth',
    'fixed_top_denture_teeth',
    'fixed_bottom_denture_teeth',
    'additional_denture_teeth',
    'surgery',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _controllers['patient_name'] = TextEditingController();
    _controllers['patient_pesel'] = TextEditingController();
    _controllers['recognition'] = TextEditingController();
    _controllers['estimate_attention'] = TextEditingController();

    for (var option in _treatmentPlanOptions) {
      _controllers['${option}_attention'] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _t(String key) {
    return _translations[_selectedLanguage]![key] ?? key;
  }

  Widget _buildTextFormField({
    required String label,
    required String controllerKey,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[controllerKey],
        decoration: InputDecoration(
          hintText: _selectedLanguage == 'pl'
              ? 'Wprowadź $label...'
              : 'Enter $label...',
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
            ? (value) => value?.trim().isEmpty ?? true
                  ? _selectedLanguage == 'pl'
                        ? 'Pole wymagane'
                        : "Required field"
                  : null
            : null,
      ),
    );
  }

  Widget _buildRadioOption(String option) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t(option),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            /// POZIOMY układ YES / NO z obramowaniem
            Row(
              children: [
                Expanded(
                  child: _buildRadioBox(
                    label: _t('yes'),
                    value: '1',
                    groupValue: _treatmentOptions[option],
                    onChanged: (value) =>
                        setState(() => _treatmentOptions[option] = value),
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRadioBox(
                    label: _t('no'),
                    value: '0',
                    groupValue: _treatmentOptions[option],
                    onChanged: (value) =>
                        setState(() => _treatmentOptions[option] = value),
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            TextFormField(
              controller: _controllers['${option}_attention'],
              decoration: InputDecoration(
                hintText: _t('attention'),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioBox({
    required String label,
    required String value,
    required String? groupValue,
    required void Function(String?) onChanged,
    required ColorScheme colorScheme,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: colorScheme.primary,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplicationSection(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('complications_section_${index}_title'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _t('complications_section_${index}_content'),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAgreementSection(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        _t('treatment_agree_section_${index}_content'),
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildSignatureSection(
    GlobalKey<SfSignaturePadState> doctorSignatureKey,
    GlobalKey<SfSignaturePadState> patientSignatureKey,
  ) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSingleSignatureColumn(
            key: doctorSignatureKey,
            label: _selectedLanguage == 'pl'
                ? 'miejsce na podpis lekarza'
                : 'place for doctor signature',
            buttonLabel: _selectedLanguage == 'pl' ? 'Wyczyść' : 'Clear',
            signatureText: _t('signature_doctor'),
          ),
          const SizedBox(width: 32), // Odstęp między podpisami
          _buildSingleSignatureColumn(
            key: patientSignatureKey,
            label: _selectedLanguage == 'pl'
                ? 'miejsce na podpis pacjenta lub opiekuna'
                : 'place for patient or guardian signature',
            buttonLabel: _selectedLanguage == 'pl' ? 'Wyczyść' : 'Clear',
            signatureText: _t('signature_patient'),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSignatureColumn({
    required GlobalKey<SfSignaturePadState> key,
    required String label,
    required String buttonLabel,
    required String signatureText,
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
          Text(signatureText),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('page_header')),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/pl.png', width: 24),
            onPressed: () => setState(() => _selectedLanguage = 'pl'),
          ),
          IconButton(
            icon: Image.asset('assets/images/en.png', width: 24),
            onPressed: () => setState(() => _selectedLanguage = 'en'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sekcja 1 - Dane pacjenta
              Center(
                child: Text(
                  _t('title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _t('name'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                label: _t('name'),
                controllerKey: 'patient_name',
                required: true,
              ),
              const SizedBox(height: 16),

              // Sekcja 2 - Rozpoznanie i plan leczenia
              Text(
                _t('recognition'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                label: _t('recognition'),
                controllerKey: 'recognition',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              Text(
                _t('title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              for (var option in _treatmentPlanOptions)
                _buildRadioOption(option),

              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red[100],
                child: Text(
                  _t('treatment_plan_attention'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _t('treatment_plan_accept'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              _buildSignatureSection(
                _signaturePadKeyDoctor,
                _signaturePadKeyPatient,
              ),
              // Sekcja 3 - Powikłania
              Center(
                child: Text(
                  _t('concent_for_treatment_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _t('complications_section_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t('complications_section_content'),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),

              for (int i = 1; i <= 8; i++) _buildComplicationSection(i),

              // _buildSignatureSection(),

              // Sekcja 4 - Zgoda na leczenie
              Text(
                _t('treatment_agree'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                label: _t('name'),
                controllerKey: 'patient_name',
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                label: 'PESEL',
                controllerKey: 'patient_pesel',
                required: true,
              ),
              const SizedBox(height: 24),

              for (int i = 1; i <= 8; i++) _buildAgreementSection(i),

              // _buildSignatureSection(),

              // Sekcja 5 - Cennik
              Text(
                _t('estimate'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Tutaj dodać listę pozycji z cennika
              // ...
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Otwórz modal z cennikiem
                },
                child: Text(_t('add_estimate')),
              ),
              const SizedBox(height: 24),
              Text(_t('attention')),
              _buildTextFormField(
                label: '',
                controllerKey: 'estimate_attention',
                maxLines: 3,
              ),
              const SizedBox(height: 40),

              // Przycisk zapisz
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Zapisz formularz
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                  child: Text(_t('save')),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
