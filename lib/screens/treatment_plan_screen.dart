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
  final GlobalKey<SfSignaturePadState> _signaturePadKeyDoctorComplications =
      GlobalKey();
  final GlobalKey<SfSignaturePadState> _signaturePadKeyPatientComplications =
      GlobalKey();
  final GlobalKey<SfSignaturePadState> _signaturePadKeyDoctorTreatmentAgree =
      GlobalKey();
  final GlobalKey<SfSignaturePadState> _signaturePadKeyPatientTreatmentAgree =
      GlobalKey();
  String _selectedLanguage = 'pl';
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _treatmentOptions = {};
  final Map<String, String?> _estimateItems = {};
  double _totalPrice = 0.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> selectedEstimates = [];

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
          'INFORMACJE DLA PACJENTA I ŚWIADOMA ZGODA NA LECZENIE ORTODONTYCZNE wg zaleceń Polskiego Towarzystwa Ortodontycznego',
      'complications_section_title':
          'Powikłania w trakcie i po leczeniu ortodontycznym',
      'complications_section_content':
          'Ortodoncja nie jest nauką ścisłą i nie sposób przewidzieć wszystkich następstw leczenia aparatem stałym. Nawet standardowe i sprawdzone procedury mogą u niektórych pacjentów wywołać nieprzewidziane reakcje. Ortodonta prowadzi leczenie według planu zaakceptowanego przez pacjenta i zakładającego najlepszy możliwy wynik jednak nie można zagwarantować  pełnej satysfakcji z osiągniętego rezultatu i braku powikłań. Poniżej przedstawiamy najczęściej zdarzające się powikłania',
      'complications_section_1_title': '1. Próchnica zębów i odwapnienia.',
      'complications_section_1_content':
          'Aparaty ortodontyczne nie powodują próchnicy są jednak miejscem dodatkowego osadzania  resztek pokarmu i płytki nazębnej. Nieprawidłowa higiena może powodować zwiększone ryzyko próchnicy i odwapnieni. Najbardziej charakterystyczne są białe plamy w kształcie półksiężyca powstające pomiędzy linią dziąsła a zamkiem ortodontycznym. Są one trudne do zlikwidowania i w przypadku ich pojawienia się lekarz może zalecić zdjęcie aparatu. Należy również podkreślić że noszenie aparatu stałego nie zwalnia pacjenta z profilaktycznych wizyt i przeglądów u stomatologa co najmniej co 6 miesięcy.',
      'complications_section_2_title': '2. Obrzęk dziąseł i choroby przyzębia.',
      'complications_section_2_content':
          'Problemy z przyzębiem mogą pojawić się na każdym etapie leczenia ortodontycznego a najczęściej spowodowane są niedostateczną higieną. Może je wywołać również specyficzna flora bakteryjna i obciążenie genetyczne. W takim wypadku konieczna jest wizyta u specjalisty periodontologa i kontrole co 3-6 miesięcy. Pacjent z chorym przyzębiem może być leczony aparatem stałym lecz powinno się to odbywać wyłącznie w okresie remisji choroby. Aktywna choroba przyzębia jest bezwzględnym przeciwwskazaniem do leczenia ortodontycznego. Warto też podkreślić że choroba przyzębia pojawia się bardzo rzadko. Najczęściej występuje proste zapalenie dziąsła (obrzęk i krwawienie) które mija natychmiast po wdrożeniu prawidłowej higieny. Pacjenci z cukrzycą chorobami tarczycy i kobiety w ciąży są szczególnie narażeni na choroby dziąseł i resorpcje korzeni i dlatego będą objęci szczególną opieką lekarza.',
      'complications_section_3_title': '3. Skrócenie korzeni zębów.',
      'complications_section_3_content':
          'Podczas leczenia ortodontycznego u pacjentów może dochodzić do skrócenia korzeni zębów o różnym nasileniu. Niestety nie można przewidzieć których pacjentów może dotyczyć ten problem. Proces ten jest uwarunkowany genetycznie. Nieznaczne skrócenie długości korzeni nie powoduje żadnych negatywnych następstw. Wyłącznie agresywne skracanie się korzenia zęba jest wskazaniem do przerwania leczenia. Należy wiedzieć że w pojedynczych przypadkach może dochodzić do samoistnego skrócenia korzeni zębów u osób nie leczonych ortodontycznie. Do kontroli postępów leczenia może być konieczne powtórne wykonanie zdjęć radiologicznych.',
      'complications_section_4_title': '4. Czas leczenia.',
      'complications_section_4_content':
          'Czas leczenia zależy od wielu czynników: nasilenia wady potencjału wzrostu  pacjenta oraz jego współpracy. Średni czas aktywnego leczenia  ortodontycznego wynosi 2 lata i może ulec wydłużeniu jeśli wystąpi nieprzewidziany niekorzystny wzrost jeśli sprowadzone są zęby zatrzymane lub leczone są ciężkie wady morfologiczne. Modyfikacje czasu leczenia może spowodować również indywidualna różna podatność tkanek pacjenta (kości i tkanek miękkich) na zastosowane siły ortodontyczne. Podany czas obejmuje wyłącznie leczenie aktywne. Następnie wymagany jest okres retencji (często wieloletni). Znaczne wydłużenie czasu leczenia następuje w przypadku braku współpracy ze strony pacjenta tj. nieterminowego zgłaszania się na wizyty odklejania zamków i innych mechanicznych uszkodzeń aparatu nie stosowania się do indywidualnych zaleceń.',
      'complications_section_5_title': '5. Stawy skroniowo-żuchwowe.',
      'complications_section_5_content':
          'Bóle w stawie skroniowo-żuchwowym mogą wystąpić bez lub podczas leczenia ortodontycznego. Najczęściej wywołuje nadmierne zaciskanie i zgrzytanie zębami. Dolegliwości mogą spowodować również stany pourazowe reumatoidalne zapalenie stawów wrodzone skłonności do zaburzeń w stawach. Częściej dotyczą płci żeńskiej. Dolegliwości ze strony s.s.ż. występują u pacjentów w wieku 9-30 lat co pokrywa się z okresem leczenia ortodontycznego. Pojawiające się dolegliwości należy natychmiast zgłosić ortodoncie gdyż mogą wymagać konsultacji ze specjalistą.',
      'complications_section_6_title':
          '6. Urazy spowodowane aparatami ortodontycznymi.',
      'complications_section_6_content':
          'W trakcie leczenia ortodontycznego mogą wystąpić uszkodzenia tkanek twardych i miękkich jamy ustnej. Szczególnie w pierwszych dobach po założeniu aparatu na języku i policzkach pojawiają się drobne otarcia (dolegliwości może zmniejszyć użycie wosku ortodontycznego). Dolegliwości te znikają po okresie adaptacji i nie mają znaczenia praktycznego.',
      'complications_section_7_title': '7. Nawroty',
      'complications_section_7_content':
          'Zakończone leczenie ortodontyczne nie gwarantuje idealnie prostych zębów do końca życia. W celu utrzymania pozycji zębów wymagane jest noszenie indywidualnie dobranych retejnerów zgodnie z zaleceniami ortodonty. Pomimo wszystko zmiany ustawienia zębów mogą wystąpić z przyczyn naturalnych jak nawyki: tłoczenie języka oddychanie przez usta oraz wzrost i starzenie się. Niewielkie stłoczenia szczególnie siekaczy dolnych pojawiają się z czasem i często muszą być zaakceptowane.',
      'complications_section_8_title': '8. Alergia',
      'complications_section_8_content':
          'U pacjentów z uczuleniami objawy alergiczne mogą ujawnić się podczas leczenia ortodontycznego w odpowiedzi na wzrost stężenia jonów niklu chromu miedzi pochodzących z aparatu ortodontycznego. Reakcje alergiczne mogą wystąpić również po kontakcie z akrylem lub lateksem. Z reguły w/w reakcje objawiają się w postaci miejscowego odczynu alergicznego: zapalenie jamy ustnej utrata smaku lub metaliczny posmak uczucie drętwienia uczucie pieczenia różnego stopnia przerostowe zapalenie dziąseł przy braku obecności płytki nazębnej. W przypadku wystąpienia w/w objawów należy poinformować lekarza prowadzącego.',
      'treatment_agree': 'Zgoda na leczenie ortodontyczne',
      'treatment_agree_section_1_content':
          'Zgodnie z art. 32-35 ustawy z dnia 5 grudnia 1996 r. o zawodach lekarza i lekarza dentysty (tekst jednolity Dz. U. z 2005 nr 226 poz. 1943 z późniejszymi zmianami) wyrażam zgodę na wykonanie wyżej opisanego planowanego świadczenia zdrowotnego przez lek.stom. Agnieszkę Golarz-Nosek specjalistę ortodontę w Gabinet Ortodontycznym Agnieszka Golarz-Nosek.',
      'treatment_agree_section_2_content':
          'Oświadczam że udzieliłem(-am) wyczerpujących i prawdziwych informacji co do mojego stanu zdrowia – zgodnie z ankietą osobową stanowiącą załącznik do niniejszego oświadczenia. O wszelkich zmianach stanu mojego zdrowia zobowiązuję się powiadomić lekarza prowadzącego. Przyjmuję do wiadomości że w/w są danymi poufnymi.',
      'treatment_agree_section_3_content':
          'Wyrażam zgodę na wykonanie dokumentacji radiologicznej oraz fotograficznej przed podczas i po leczeniu ortodontycznym',
      'treatment_agree_section_4_content':
          'Zobowiązuję się do przestrzegania zaleceń lekarskich w szczególności dotyczących higieny jamy ustnej  noszenia elementów dodatkowych zaleconych na wizycie oraz do zgłaszania się na wizyty kontrolne w wyznaczonych terminach. W przypadku zmiany terminu wizyty z mojej strony zobowiązuje się odwołać ją z minimum jednodniowym wyprzedzeniem.',
      'treatment_agree_section_5_content':
          'Oświadczam że przeczytałem (-am) i zrozumiałem (-am) powyższe zasady a ponadto uzyskałem (-am) również wszelkie wyjaśnienia od lek. stom. Agnieszki Golarz-Nosek dotyczące mojego planowanego leczenia. Miałem (-am) możliwość swobodnego zadawania pytań i uzyskałem (-am) dodatkowe wyjaśnienia.',
      'estimate': 'Cennik',
      'add_estimate': 'Dodaj do cennika',
      'estimate_1': 'Aparat metalowy górny i dolny',
      'estimate_2': 'Aparat samoligaturujący metalowy górny i dolny',
      'estimate_3': 'Aparat kosmetyczny górny i dolny',
      'estimate_4': 'Aparat INCOGNITO górny i dolny',
      'estimate_5': 'Przesyłka Incognito',
      'estimate_6': 'Aparat GMD',
      'estimate_7': 'Aparat Lip-Bumper',
      'estimate_8': 'Łuk podniebienny',
      'estimate_9': 'Aparat Hyrax',
      'estimate_10': 'Aparat Hass',
      'estimate_11': 'Aparat Beneslider',
      'estimate_12': 'Aparat hybrydowy Hyrax',
      'estimate_13': 'Aparat hybrydowy Hyrax + Beneslider',
      'estimate_14': 'Implant ortodontyczny',
      'estimate_15': 'Szyna relaksacyjna',
      'estimate_16': 'Maska Hickhama',
      'estimate_17': 'Wizyta kontrolna z aparatem stałym',
      'estimate_18': 'Wizyta kontrolna z szyną relaksacyjną',
      'estimate_19': 'Zdjęcie aparatu stałego górnego i dolnego',
      'estimate_20': 'Szyna retencyjna górna i dolna',
      'estimate_21': 'Wizyta kontrolna z aparatem retencyjnym',
      'estimate_22': 'Skan wewnątrzustny',
      'estimate_23': 'Płytka NANCE`A',
      'estimate_24': 'Higienizacja (scaling polerowanie fluoryzacja)',
      'estimate_25': 'Lakierowanie',
      'estimate_26':
          'Zaczep ze złotym łańcuszkiem do ściągania zatrzymanych zębów',
      'estimate_27': 'RTG pantomograficzne',
      'estimate_28': 'RTG cefalometryczne',
      'estimate_29': 'CT stawów SŻ/CT szczęki i żuchwy',
      'estimate_30': 'CT żuchwy',
      'estimate_31': 'CT szczęki',
      'estimate_32': 'CT twarzoczaszki',
      'estimate_33': 'Skan twarzy',
      'estimate_34': 'Modele diagnostyczne do operacji ortognatycznej',
      'estimate_35': 'Pomiary do operacji ortognatycznej',
      'estimate_36': 'Przygotowanie dokumentacji do operacji ortognatycznej',
      'estimate_37': 'Haczyki do operacji ortognatycznej na jeden łuk',
      'estimate_38': 'Zdjęcie płytki podniebiennej',
      'estimate_39':
          'Naprawa aparatu/przyklejenie nowego zamka w zależności od rodzaju systemu',
      'estimate_40': 'Nawiercanie kości',
      'estimate_41': 'Nawiercanie szwu podniebiennego',
      'estimate_42': 'Znieczulenie',
      'added': 'Dodano do cennika: ',
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
          'PATIENT INFORMATION AND INFORMED CONSENT FOR TREATMENT OF ORTHODONTIC recommended by the Polish Orthodontic Society',
      'complications_section_title':
          'Complications during and after orthodontic treatment',
      'complications_section_content':
          'Orthodontics is not an exact science. It is impossible to foresee all the consequences of treatment with using fixed appliances. Even standard and proven procedures may in some patients lead to unexpected reactions. Orthodontist leading treatment according to the plan approved by the patient and assuming the best possible result, but can not guarantee full satisfaction with the result and the absence of complications. Below are the most frequently occurring complications:',
      'complications_section_1_title': '1. Dental caries and decalcification.',
      'complications_section_1_content':
          'Othodontic appliances do not cause tooth decay, but there are additional retention place food debris and plaque. Improper hygiene (see recommendations for the orthodontic patient) may cause an increased risk of tooth decay and decalcification. The most characteristic are the white spots in the shape of a crescent formed between the gum line and orthodontic lock. They are difficult to remove and, if they occur, your doctor may prescribe a photo camera. It should also be noted that wearing a fixed appliance does not relieve the patient of preventive visits and inspections to the dentist at least every six months.',
      'complications_section_2_title':
          '2. Swollen gums and periodontal disease.',
      'complications_section_2_content':
          'Problems with the periodontium may occur at any stage of orthodontic treatment, and in most cases are caused by poor hygiene. It can also cause them specific bacterial flora and genetic load. In this case, it is necessary to visit a specialist periodontologist and checks every 3-6 months. A patient with a sick periodontium can be treated with fixed appliances, but it should be done only in remission of the disease. Active periodontal disease is an absolute contraindication for orthodontic treatment. It should be noted that periodontal disease occurs very rarely. Frequently there is a simple gum inflammation (swelling and bleeding), which passes immediately after the implementation of proper hygiene. Patients with diabetes, thyroid disease and pregnant women are particularly at risk of gum disease and root resorption and, therefore, special care will be covered by your doctor.',
      'complications_section_3_title': '3. Shortening the roots of the teeth.',
      'complications_section_3_content':
          'During orthodontic treatment patients can seek to shorten the roots of the teeth of varying severity. Unfortunately, you can not predict which patients may relate to the problem. This process is genetically determined. A slight shortening of the length of the root causes no negative consequences. Only aggressive shortening the root of the tooth is an indication for discontinuation of treatment. You should know that in individual cases can occur spontaneously shorten the roots of the teeth, if not treated orthodontically. To monitor the progress of treatment may be necessary to repeat the radiographs.',
      'complications_section_4_title': '4. Duration of treatment.',
      'complications_section_4_content':
          "The duration of treatment depends on many factors: the severity of the defect, the potential for growth and the age of the patient and his cooperation. Average duration of active orthodontic treatment is two years and may be extended if unexpected adverse growth occurs when teeth are imported or detained are treated severe morphological defects. Modification of the treatment may also result in different susceptibility to an individual patient's tissues (bone and soft tissues) for orthodontic forces applied. This time will include only active treatment. Then the retention period is required (often many years). Significant prolongation of the treatment in the absence of cooperation from the patient, ie untimely reporting on the visit, detachment braces and other mechanical damage to barces.",
      'complications_section_5_title': '5. Temporomandibular joints.',
      'complications_section_5_content':
          'Pain in the may occur without or during orthodontic treatment. Most causes excessive clenching and grinding of teeth. Symptoms may also cause post -traumatic conditions, rheumatoid arthritis, susceptibility to congenital disorders of the joints. Frequent in females. Complaints from the temporomandibular joint occur in patients aged 9-30 years, which coincides with the period of orthodontic treatment. Emerging problems should be reported immediately orthodontist, as may require consultation with a specialist.',
      'complications_section_6_title': '6. Injuries caused by braces.',
      'complications_section_6_content':
          'In the course of orthodontic treatment can cause damage soft and hard tissues of the oral cavity. Especially in the first days after the founding of the barces on the tongue and cheeks appear minor abrasions (disorders can prevent the use of orthodontic wax). These problems disappear after a period of adaptation and have no practical significance. When removing the braces can cause damage to the enamel and all kinds of additions. This applies particularly to aesthetic braces.',
      'complications_section_7_title': '7. Relapse',
      'complications_section_7_content':
          'Completed orthodontic treatment does not guarantee perfectly straight teeth for life. To maintain tooth position, wearing individually tailored retainers according to the orthodontist\'s recommendations is necessary. Despite that, changes in tooth alignment can occur due to natural causes such as habits like tongue thrusting, mouth breathing, as well as growth and aging. Minor relapse, especially in the lower incisors, may occur over time and often needs to be accepted.',
      'complications_section_8_title': '8. Allergy',
      'complications_section_8_content':
          'In patients with allergies, allergic symptoms may manifest during orthodontic treatment in response to increased concentration of nickel, chromium, copper ions originating from the orthodontic appliance. Allergic reactions can also occur after contact with acrylic or latex. Typically, these reactions manifest as local allergic reactions: oral inflammation, loss of taste or metallic taste, tingling sensation, burning sensation, varying degrees of gingival overgrowth in the absence of plaque. If these symptoms occur, it is important to inform the attending doctor.',
      'treatment_agree':
          'Patient Informed Consent for providing orthodontic treatments and Patient Declaration',
      'treatment_agree_section_1_content':
          'In accordance with Article 32-35 of the Act of 5 December 1996. the professions of doctor and dentist (consolidated text. Laws of 2008 No. 136, item. 857 with later. d.) I do hereby consent to the  proposed treatment described above and performed by orthodontist Agnieszka Golarz-Nosek in Agnieszka Golarz-Nosek Orthodontic Clinic.',
      'treatment_agree_section_2_content':
          'I have given thorough and true answers to the questions the doctor asked me during the medical interview about my state of health, medication, and completed treatment as well as in the questionary, which is an annex to this document. I understand it is my responsibility to notify the healthcare provider of any changes in my health condition. The medical record is confidential and is protected from unauthorized disclosure by law. ',
      'treatment_agree_section_3_content':
          'I hereby grant permission to perform routine diagnostic procedures including the necessary capture/use of radiographs (x-rays), photographs and models for the purpose of treatment planning, case documentation and insurance claims processing at any stage before, during and/or following orthodontic treatment. I understand that reproduction of radiographs, photographs and/or models for purposes other than noted above require an additional consent/release for any publication. ',
      'treatment_agree_section_4_content':
          'To help achieve the most successful results, the patient must: keep regularly scheduled appointments, practice good oral hygiene, including brushing, flossing etc. wear orthodontic appliances as instructed, eat appropriate foods so as not to dislodge the braces (brackets, bands). Failure to adhere to instructions can lengthen the treatment time and can adversely affect the treatment results. In extreme circumstances, it could be necessary to discontinue orthodontic treatment, as a result of non-compliance with instructions.',
      'treatment_agree_section_5_content':
          'I agree to keep all scheduled appointments unless I notify the office at least 24 hours prior to the appointment. I was informed of possible use of alternative methods of treatment, risks and complications that may occur during or because of treatment, as well as about the consequences of failure. I have been informed about the associated risks of the proposed treatment and other methods and consequences of discontinuing treatment. I understand that, as with all medical procedures and dental positive effects of treatment can not be guaranteed in spite of conduct in accordance with the medical art. I have obtained comprehensive,   clear and understandable answers to all the questions, I have been explained all activities regarding the proposed procedure / methods of diagnosis / treatment, the risks and complications that may occur during or  as a result of treatment. During the consultation with the doctor, I was able to ask questions about the proposed medical procedure. I have been informed  of the possibility of unforeseen situations, which may require modification of the state of the scope of the treatment. I agree to make adjustments in this situation. I have read and accept the costs related to treatment. I do understand, that the price of the services may change. The published price list does not constitute an offer within the meaning of the Civil Code. ',
      'estimate': 'Estimate',
      'add_estimate': 'Add to estimate',
      'added': 'Added to estimate: ',

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

  void _showModernEstimateModal(BuildContext context) {
    final List<String> estimateKeys = List.generate(
      42,
      (i) => 'estimate_${i + 1}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('add_estimate'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: estimateKeys.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final key = estimateKeys[index];
                      return ListTile(
                        title: Text(_t(key)),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () {
                          setState(() {
                            selectedEstimates.add(_t(key));
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${_t('added')}${_t(key)}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
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

              _buildSignatureSection(
                _signaturePadKeyDoctorComplications,
                _signaturePadKeyPatientComplications,
              ),
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

              for (int i = 1; i <= 5; i++) _buildAgreementSection(i),

              _buildSignatureSection(
                _signaturePadKeyDoctorTreatmentAgree,
                _signaturePadKeyPatientTreatmentAgree,
              ),
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
              ElevatedButton.icon(
                onPressed: () => _showModernEstimateModal(context),
                icon: const Icon(Icons.add),
                label: Text(_t('add_estimate')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // style: ElevatedButton.styleFrom(
                //   // backgroundColor: Colors.blueAccent,
                //   // foregroundColor: Colors.white,
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 24,
                //     vertical: 14,
                //   ),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                // ),
              ),

              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: selectedEstimates
                    .map((item) => Text('• $item'))
                    .toList(),
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
