import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class TreatmentPlanScreen extends StatefulWidget {
  const TreatmentPlanScreen({super.key});

  @override
  State<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _controllers[controllerKey],
            decoration: InputDecoration(
              hintText: _selectedLanguage == 'pl'
                  ? 'Wprowadź $label...'
                  : 'Enter $label...',
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: maxLines,
            validator: required
                ? (value) => value?.trim().isEmpty ?? true
                      ? _selectedLanguage == 'pl'
                            ? 'Pole wymagane'
                            : "Required field"
                      : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String option) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t(option),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  value: '1',
                  groupValue: _treatmentOptions[option],
                  onChanged: (value) =>
                      setState(() => _treatmentOptions[option] = value),
                  title: Text(_t('yes')),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  value: '0',
                  groupValue: _treatmentOptions[option],
                  onChanged: (value) =>
                      setState(() => _treatmentOptions[option] = value),
                  title: Text(_t('no')),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controllers['${option}_attention'],
            decoration: InputDecoration(
              hintText: _t('attention'),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            maxLines: 2,
          ),
        ],
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

  Widget _buildSignatureSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          _t('place_for_signature'),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 80),
        const Divider(),
        const SizedBox(height: 16),
        Text(_t('doctor_signature')),
        const SizedBox(height: 40),
        Text(_t('patient_signature')),
        const SizedBox(height: 40),
      ],
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

              //TODO
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
              _buildSignatureSection(),

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

              _buildSignatureSection(),

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

              _buildSignatureSection(),

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
