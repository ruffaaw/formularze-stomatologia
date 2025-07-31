import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:email_validator/email_validator.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final numberFormat = NumberFormat('#,##0.00', 'pl_PL');

  final uuid = Uuid();

  final List<Map<String, dynamic>> estimateOptions = [
    {"name": "estimate_1", "price": 5800},
    {"name": "estimate_2", "price": 6900},
    {"name": "estimate_3", "price": 9000},
    {"name": "estimate_6", "price": 1950},
    {"name": "estimate_7", "price": 950},
    {"name": "estimate_8", "price": 850},
    {"name": "estimate_9", "price": 1930},
    {"name": "estimate_10", "price": 1930},
    {"name": "estimate_11", "price": 4800},
    {"name": "estimate_12", "price": 5400},
    {"name": "estimate_13", "price": 6500},
    {"name": "estimate_14", "price": 1200},
    {"name": "estimate_15", "price": 1950},
    {"name": "estimate_16", "price": 1050},
    {"name": "estimate_17", "price": 250},
    {"name": "estimate_18", "price": 200},
    {"name": "estimate_19", "price": 480},
    {"name": "estimate_20", "price": 1800},
    {"name": "estimate_21", "price": 150},
    {"name": "estimate_22", "price": 280},
    {"name": "estimate_24", "price": 280},
    {"name": "estimate_25", "price": 250},
    {"name": "estimate_26", "price": 350},
    {"name": "estimate_27", "price": 120},
    {"name": "estimate_28", "price": 150},
    {"name": "estimate_29", "price": 400},
    {"name": "estimate_30", "price": 250},
    {"name": "estimate_31", "price": 250},
    {"name": "estimate_32", "price": 500},
    {"name": "estimate_33", "price": 480},
    {"name": "estimate_34", "price": 380},
    {"name": "estimate_35", "price": 250},
    {"name": "estimate_36", "price": 700},
    {"name": "estimate_37", "price": 300},
    {"name": "estimate_38", "price": 550},
    {"name": "estimate_39", "price": 150},
    {"name": "estimate_40", "price": 50},
    {"name": "estimate_41", "price": 50},
    {"name": "estimate_42", "price": 80},
    {"name": "estimate_43", "price": 7500},
    {"name": "estimate_44", "price": 250},
  ];

  List<Map<String, dynamic>> selectedEstimates = [];

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
          'Uwaga! Plan leczenia może ulec zmianie w zależności od sytuacji klinicznej.',
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
      'estimate_43': 'Pułapka na myszy (miejsce po Hyrax Hybrydowy)',
      'estimate_44': 'Usunięcie miniimplantu',
      'added': 'Dodano do cennika: ',
      'sum': 'Cena całkowita',
      'save': 'Zapisz',
      'selected_items': 'Wybrane pozycje',
      'designation': 'Nazwa',
      'price': 'Cena (zł)',
      'select_items': 'Wybierz pozycje z listy',
      'zl': "zł",
      'price_information':
          "Pozostałe ceny usług wycenione indywidualnie. Ceny usług mogą ulec zmianie.",
      'other_information':
          "W przypadku trudności w osiągnięciu celów leczenia, a także przyspieszenia ruchu grup zębowych oraz eliminacji niepotrzebnych przesunięć, wzięte pod uwagę zostanie wspomaganie leczenia ortodontycznego za pomocą  implantów ortodontycznych. Koszty miniimplantow według aktualnego cennika.",
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
          'Warning! Treatment plan may change depending on clinical situation.',
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
      'estimate_1': 'Upper and lower metal appliances',
      'estimate_2': 'Upper and lower self-ligating appliances',
      'estimate_3': 'Upper and lower cosmetic appliance',
      'estimate_6': 'GMD appliance',
      'estimate_7': 'Lip-Bumper appliance',
      'estimate_8': 'Palatal arch',
      'estimate_9': 'Hyrax appliance',
      'estimate_10': 'Hass appliance',
      'estimate_11': 'Beneslider appliance',
      'estimate_12': 'Hyrax hybrid appliance',
      'estimate_13': 'Hybrid Hyrax + Beneslider appliance',
      'estimate_14': 'Orthodontic implant',
      'estimate_15': 'Relaxation splint',
      'estimate_16': 'Hickham mask',
      'estimate_17': 'Control visit with fixed braces',
      'estimate_18': 'Control visit with relaxation splint',
      'estimate_19': 'Removal of upper and lower fixed braces',
      'estimate_20': 'Upper and lower retention splint',
      'estimate_21': 'Control visit with retention braces',
      'estimate_22': 'Intraoral scan',
      'estimate_24': 'Hygienization (scaling, polishing, fluoridation)',
      'estimate_25': 'Varnishing',
      'estimate_26': 'Attachment with gold chain for pulling retained teeth',
      'estimate_27': 'Pantomographic X-ray',
      'estimate_28': 'Cephelometric X-ray',
      'estimate_29': 'CT of maxilla and mandible',
      'estimate_30': 'CT of the maxilla',
      'estimate_31': 'CT of the mandible',
      'estimate_32': 'CT of face',
      'estimate_33': 'Face scan',
      'estimate_34': 'Diagnostic models for orthognathic surgery',
      'estimate_35': 'Measurements for orthognathic surgery',
      'estimate_36': 'Preparation of documentation for orthognathic surgery',
      'estimate_37': 'Hooks for orthognathic surgery',
      'estimate_38': 'Removal of palatal plate',
      'estimate_39': 'Braces repair From',
      'estimate_40': 'Bone drilling',
      'estimate_41': 'Palatal suture drilling',
      'estimate_42': 'Anesthesia',
      'estimate_43': 'Mousetrap (place of the Hybrid Hyrax)',
      'estimate_44': 'Mini-implant removal',
      'sum': 'Total sum:',
      'save': 'Save',
      'selected_items': 'Selected items',
      'designation': 'Name',
      'price': 'Price (PLN)',
      'select_items': 'Select items from the list',
      'zl': "PLN",
      'price_information':
          "Other services are priced individually. Prices are subject to change.",
      'other_information':
          "W przypadku trudności w osiągnięciu celów leczenia, a także przyspieszenia ruchu grup zębowych oraz eliminacji niepotrzebnych przesunięć, wzięte pod uwagę zostanie wspomaganie leczenia ortodontycznego za pomocą  implantów ortodontycznych. Koszty miniimplantow według aktualnego cennika.",
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

  double get totalEstimatePrice {
    return selectedEstimates.fold(0.0, (sum, item) => sum + (item['price']));
  }

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
          const SizedBox(width: 32),
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

  void _showEstimateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Text(
                    _t('select_items'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: estimateOptions.length,
                      itemBuilder: (context, index) {
                        final option = estimateOptions[index];
                        final isSelected = selectedEstimates.any(
                          (e) => e['name'] == option['name'],
                        );

                        return Card(
                          color: isSelected ? Colors.grey[200] : null,
                          child: ListTile(
                            title: Text(_t(option['name'])),
                            subtitle: Text('od ${option['price']} ${_t('zl')}'),
                            onTap: () {
                              setState(() {
                                if (!isSelected) {
                                  final newItem = {
                                    'id': uuid.v4(),
                                    'name': option['name'],
                                    'price': option['price'],
                                  };

                                  setState(() {
                                    selectedEstimates.add(newItem);
                                    _controllers[newItem['id']] =
                                        TextEditingController(
                                          text: newItem['price'].toString(),
                                        );
                                  });
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red[100],
                child: Text(
                  _t('other_information'),
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

              ElevatedButton.icon(
                onPressed: () => _showEstimateModal(context),
                icon: const Icon(Icons.add),
                label: Text(_t('add_estimate')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (selectedEstimates.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  _t('selected_items'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          _t('designation'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _t('price'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(flex: 1, child: SizedBox()),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                ...selectedEstimates.map((item) {
                  final controller = _controllers[item['id']]!;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Text(_t(item['name']))),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                            ),
                            onChanged: (value) {
                              final newPrice = double.tryParse(
                                value.replaceAll(',', '.'),
                              );
                              if (newPrice != null) {
                                setState(() {
                                  item['price'] = newPrice;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedEstimates.removeWhere(
                                  (e) => e['id'] == item['id'],
                                );
                                _controllers.remove(item['id']);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          _t('sum'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Text(
                        "${numberFormat.format(totalEstimatePrice)} ${_t('zl')}",
                        key: ValueKey(totalEstimatePrice.toString()),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red[100],
                child: Text(
                  _t('price_information'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
                  onPressed: () async {
                    _saveForm(context);
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
                    _t('save'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> generateAndSavePDF(BuildContext context) async {
    try {
      final doc = pw.Document();
      final pdfTheme = pw.ThemeData.withFont(
        base: pw.Font.ttf(await rootBundle.load('assets/fonts/archivo.ttf')),
        bold: pw.Font.ttf(
          await rootBundle.load('assets/fonts/archivo-bold.ttf'),
        ),
      );

      final signatureBytes = await _getSignatureImageBytes();

      final doctorImage = await _signaturePadKeyDoctor.currentState!.toImage();
      final doctorByteData = await doctorImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List doctorSignatureBytes = doctorByteData!.buffer
          .asUint8List();

      final patientImage = await _signaturePadKeyPatient.currentState!
          .toImage();
      final patientByteData = await patientImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List patientSignatureBytes = patientByteData!.buffer
          .asUint8List();

      final doctorComplicationsImage = await _signaturePadKeyDoctorComplications
          .currentState!
          .toImage();
      final doctorComplicationsByteData = await doctorComplicationsImage
          .toByteData(format: ui.ImageByteFormat.png);
      final Uint8List doctorComplicationsSignatureBytes =
          doctorComplicationsByteData!.buffer.asUint8List();

      final patientComplicationsImage =
          await _signaturePadKeyPatientComplications.currentState!.toImage();
      final patientComplicationsByteData = await patientComplicationsImage
          .toByteData(format: ui.ImageByteFormat.png);
      final Uint8List patientComplicationsSignatureBytes =
          patientComplicationsByteData!.buffer.asUint8List();

      final doctorTreatmentAgreeImage =
          await _signaturePadKeyDoctorTreatmentAgree.currentState!.toImage();
      final doctorTreatmentAgreeByteData = await doctorTreatmentAgreeImage
          .toByteData(format: ui.ImageByteFormat.png);
      final Uint8List doctorTreatmentAgreeSignatureBytes =
          doctorTreatmentAgreeByteData!.buffer.asUint8List();

      final patientTreatmentAgreeImage =
          await _signaturePadKeyPatientTreatmentAgree.currentState!.toImage();
      final patientTreatmentAgreeByteData = await patientTreatmentAgreeImage
          .toByteData(format: ui.ImageByteFormat.png);
      final Uint8List patientTreatmentAgreeSignatureBytes =
          patientTreatmentAgreeByteData!.buffer.asUint8List();
      final now = DateTime.now();
      final formattedDateTime =
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      doc.addPage(
        pw.MultiPage(
          theme: pdfTheme,
          pageFormat: PdfPageFormat.a4,
          footer: (context) {
            return pw.Container(
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
            );
          },
          build: (pw.Context context) {
            return [
              pw.Center(child: pw.Header(level: 0, text: 'PLAN LECZENIA')),
              pw.SizedBox(height: 10),

              // Dane osobowe
              _buildPdfSectionTitle('DANE KLIENTA'),
              _buildPdfTextField(
                'Imię i nazwisko:',
                _controllers['patient_name']!.text,
              ),
              _buildPdfTextField(
                'Rozpoznanie:',
                _controllers['recognition']!.text,
              ),
              _buildPdfSectionTitle('PLAN LECZENIA'),
              buildTreatmentPlanSection(
                _treatmentPlanOptions,
                _treatmentOptions,
                _controllers,
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                color: PdfColors.red100,
                child: pw.Text(
                  _translations['pl']!['treatment_plan_attention']!,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                color: PdfColors.red100,
                child: pw.Text(
                  _translations[_selectedLanguage]!['other_information']!,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Akceptuje proponowany plan leczenia',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildSignatureColumnPdf(
                    label: 'Podpis lekarza:',
                    signatureImage: doctorSignatureBytes,
                  ),
                  _buildSignatureColumnPdf(
                    label: 'Podpis pacjenta lub opiekuna prawnego:',
                    signatureImage: patientSignatureBytes,
                  ),
                ],
              ),
            ];
          },
        ),
      );

      doc.addPage(
        pw.Page(
          theme: pdfTheme,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'INFORMACJE DLA PACJENTA I ŚWIADOMA ZGODA NA LECZENIE ORTODONTYCZNE wg zaleceń Polskiego Towarzystwa Ortodontycznego',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  _translations['pl']!['complications_section_title']!,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  _translations['pl']!['complications_section_content']!,
                  style: pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.justify,
                ),
                pw.SizedBox(height: 10),
                for (int i = 1; i <= 4; i++) _buildComplicationSectionPdf(i),
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
            );
          },
        ),
      );

      doc.addPage(
        pw.Page(
          theme: pdfTheme,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                for (int i = 5; i <= 8; i++) _buildComplicationSectionPdf(i),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSignatureColumnPdf(
                      label: 'Podpis lekarza:',
                      signatureImage: doctorComplicationsSignatureBytes,
                    ),
                    _buildSignatureColumnPdf(
                      label: 'Podpis pacjenta lub opiekuna prawnego:',
                      signatureImage: patientComplicationsSignatureBytes,
                    ),
                  ],
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
            );
          },
        ),
      );

      doc.addPage(
        pw.Page(
          theme: pdfTheme,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [
                _buildPdfSectionTitle('ZGODA NA LECZENIE ORTODONTYCZNE'),
                _buildPdfTextField(
                  'Imię i nazwisko:',
                  _controllers['patient_name']!.text,
                ),
                _buildPdfTextField(
                  'PESEL:',
                  _controllers['patient_pesel']!.text,
                ),
                for (int i = 1; i <= 5; i++) _buildAgreementSectionPdf(i),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSignatureColumnPdf(
                      label: 'Podpis lekarza:',
                      signatureImage: doctorTreatmentAgreeSignatureBytes,
                    ),
                    _buildSignatureColumnPdf(
                      label: 'Podpis pacjenta lub opiekuna prawnego:',
                      signatureImage: patientTreatmentAgreeSignatureBytes,
                    ),
                  ],
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
            );
          },
        ),
      );

      doc.addPage(
        pw.Page(
          theme: pdfTheme,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [
                _buildPdfSectionTitle('CENNIK'),
                buildEstimateSectionPdf(selectedEstimates, totalEstimatePrice),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  color: PdfColors.red100,
                  child: pw.Text(
                    _translations['pl']!['price_information']!,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfTextField2(
                  'Dodatkowe informacje:',
                  _controllers['estimate_attention']!.text,
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
            );
          },
        ),
      );
      // Zapis PDF
      await _saveAndSharePdf(doc);
    } catch (e) {
      showValidationError('Błąd podczas generowania PDF: ${e.toString()}');
    }
  }

  Future<void> _saveAndSharePdf(pw.Document doc) async {
    // 1. Sprawdź i poproś o wymagane uprawnienia
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Brak uprawnień do zapisu pliku');
    }
    final name = _controllers['patient_name']!.text.trim();
    final fileName =
        '${name}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.pdf'
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
  }

  void _saveForm(context) async {
    if (await validateForm()) {
      // Formularz jest poprawny, można kontynuować zapis
      generateAndSavePDF(context);
    }
  }

  void showValidationError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<ByteData?> _getSignatureImageBytes() async {
    try {
      final signatureState = _signaturePadKeyDoctor.currentState;
      if (signatureState == null) return null;

      final image = await signatureState.toImage();
      return await image.toByteData(format: ImageByteFormat.png);
    } catch (e) {
      return null;
    }
  }

  pw.Widget _buildSignatureColumnPdf({
    required String label,
    required Uint8List? signatureImage,
  }) {
    return pw.Column(
      children: [
        pw.Text(label),
        pw.SizedBox(height: 10),
        signatureImage != null
            ? pw.Image(pw.MemoryImage(signatureImage), width: 200, height: 80)
            : pw.Container(
                width: 200,
                height: 80,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text('---'),
              ),
        pw.SizedBox(height: 10),
        pw.Text('Data: ${DateFormat('dd.MM.yyyy').format(DateTime.now())}'),
      ],
    );
  }

  pw.Widget _buildAgreementSectionPdf(int index) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16.0),
      child: pw.Text(
        _translations['pl']!['treatment_agree_section_${index}_content']!,
        style: const pw.TextStyle(fontSize: 11),
        textAlign: pw.TextAlign.justify,
      ),
    );
  }

  pw.Widget buildEstimateSectionPdf(
    List<Map<String, dynamic>> selectedEstimates,
    double totalEstimatePrice,
  ) {
    final numberFormat = NumberFormat('#,##0.00', 'pl_PL');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Lista pozycji
        if (selectedEstimates.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            _t('selected_items'),
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),

          // Nagłówki tabeli
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            color: PdfColors.grey200,
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    _t('designation'),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    _t('price'),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 4),

          // Lista pozycji
          ...selectedEstimates.map((item) {
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 4,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              margin: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 4, child: pw.Text(_t(item['name']))),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      // "${numberFormat.format(totalEstimatePrice)} ${_t('zl')}",
                      "${numberFormat.format(item['price'])} ${_t('zl')}",
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          pw.SizedBox(height: 12),

          // Suma
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  _t('sum'),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "${numberFormat.format(totalEstimatePrice)} ${_t('zl')}",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildComplicationSectionPdf(int index) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _translations['pl']!['complications_section_${index}_title']!,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          _translations['pl']!['complications_section_${index}_content']!,
          style: const pw.TextStyle(fontSize: 11),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _buildPdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildPdfTextField(String label, String value, {int maxLines = 1}) {
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

  pw.Widget _buildPdfTextField2(
    String label,
    String value, {
    int maxLines = 1,
    bool isRequired = false,
    double labelSize = 12,
    double valueSize = 11,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: label,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: labelSize,
                ),
              ),
              if (isRequired)
                pw.TextSpan(
                  text: ' *',
                  style: pw.TextStyle(
                    color: PdfColors.red,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: labelSize,
                  ),
                ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Text(
            value.isNotEmpty ? value : '-',
            style: pw.TextStyle(
              fontSize: valueSize,
              color: value.isNotEmpty ? PdfColors.black : PdfColors.grey,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  pw.Widget buildTreatmentPlanSection(
    List<String> options,
    Map<String, String?> answers,
    Map<String, TextEditingController> controllers,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(0.8),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            // Nagłówek tabeli
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Plan leczenia',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Odpowiedź',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Dodatkowe informacje',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Dane z opcji
            for (final option in options)
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(_translations['pl']![option]!),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      answers[option] == '1'
                          ? 'tak'
                          : answers[option] == '0'
                          ? 'nie'
                          : '-',
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      controllers['${option}_attention']?.text ?? '',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildConsentPdfRow(String label, bool isChecked) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Text('${isChecked ? '[X]' : '[ ]'} '),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Text(label)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfCheckbox(bool isChecked, {bool isCentered = false}) {
    final checkbox = pw.Container(
      width: 12,
      height: 12,
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: isChecked
          ? pw.Center(
              child: pw.Text('X', style: const pw.TextStyle(fontSize: 10)),
            )
          : null,
    );

    return isCentered ? pw.Center(child: checkbox) : checkbox;
  }

  // Walidacja wymaganych pól
  Future<bool> validateForm() async {
    // Dane osobowe - wymagane
    if (_controllers['patient_name']!.text.isEmpty) {
      showValidationError('Proszę wprowadzić imię pacjenta');
      return false;
    }

    if (_controllers['recognition']!.text.isEmpty) {
      showValidationError('Proszę wprowadzić rozpoznanie');
      return false;
    }

    if (_controllers['patient_pesel']!.text.isEmpty ||
        _controllers['patient_pesel']!.text.length != 11 ||
        !_controllers['patient_pesel']!.text.isNumeric()) {
      showValidationError('Proszę wprowadzić poprawny PESEL (11 cyfr)');
      return false;
    }

    Future<bool> isSignatureNotEmpty(GlobalKey<SfSignaturePadState> key) async {
      try {
        final signatureState = key.currentState;
        if (signatureState == null) return false;

        final image = await signatureState.toImage();
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData == null) return false;

        final bytes = byteData.buffer.asUint8List();

        // Sprawdzenie czy każdy bajt to 0 (czyli obraz pusty)
        return !bytes.every((byte) => byte == 0);
      } catch (e) {
        return false;
      }
    }

    if (!await isSignatureNotEmpty(_signaturePadKeyDoctor)) {
      showValidationError('Proszę złożyć podpis lekarza');
      return false;
    }

    if (!await isSignatureNotEmpty(_signaturePadKeyPatient)) {
      showValidationError('Proszę złożyć podpis pacjenta');
      return false;
    }

    if (!await isSignatureNotEmpty(_signaturePadKeyDoctorComplications)) {
      showValidationError('Proszę złożyć podpis lekarza');
      return false;
    }

    if (!await isSignatureNotEmpty(_signaturePadKeyPatientComplications)) {
      showValidationError('Proszę złożyć podpis pacjenta');
      return false;
    }

    if (!await isSignatureNotEmpty(_signaturePadKeyDoctorTreatmentAgree)) {
      showValidationError('Proszę złożyć podpis lekarza');
      return false;
    }

    if (!await isSignatureNotEmpty(_signaturePadKeyPatientTreatmentAgree)) {
      showValidationError('Proszę złożyć podpis pacjenta');
      return false;
    }

    return true;
  }
}

extension Numeric on String {
  bool isNumeric() {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }
}
