import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class PatientQuestionnaireScreen extends StatefulWidget {
  const PatientQuestionnaireScreen({super.key});

  @override
  State<PatientQuestionnaireScreen> createState() =>
      _PatientQuestionnaireScreenState();
}

class _PatientQuestionnaireScreenState
    extends State<PatientQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  String _selectedLanguage = 'pl';
  String? _selectedGender;
  String? _selectedAuthorization;
  final Map<String, Map<String, String?>> _diseaseResponses = {};
  final Map<String, String?> _diseaseDescriptions = {};
  final Map<String, bool> _consents = {
    'zgoda1': false,
    'zgoda2': false,
    'zgoda3': false,
  };

  // Controllers for all form fields
  final Map<String, TextEditingController> _controllers = {
    'patientName': TextEditingController(),
    'patientSurname': TextEditingController(),
    'patientPesel': TextEditingController(),
    'patientBirthday': TextEditingController(),
    'patientStreet': TextEditingController(),
    'patientCity': TextEditingController(),
    'patientPostCode': TextEditingController(),
    'patientPhone': TextEditingController(),
    'patientEmail': TextEditingController(),
    'patientGuardian': TextEditingController(),
    'patientGuardianStreet': TextEditingController(),
    'patientAuthorizationName': TextEditingController(),
    'patientAuthorizationSurname': TextEditingController(),
    'patientAuthorizationAddress': TextEditingController(),
    'patientAuthorizationPhone': TextEditingController(),
    'patientAuthorizationPesel': TextEditingController(),
    'patientQuestion_new': TextEditingController(),
    'comments': TextEditingController(),
    'heartDiseaseDescription': TextEditingController(),
    'allergyToAnestheticsDescription': TextEditingController(),
    'allergyToMetalsDescription': TextEditingController(),
    'actualCureDescription': TextEditingController(),
    'otherDiseasesDescription': TextEditingController(),
    'psychiatricTreatmentDescription': TextEditingController(),
    'mentalDisableDescription': TextEditingController(),
  };

  // Translations
  final Map<String, Map<String, String>> _translations = {
    'pl': {
      'title': 'Ankieta Osobowa Pacjenta',
      'confidential':
          'Podane przez Państwa informacje są objęte tajemnicą lekarską.',
      'personalData': 'Dane osobowe pacjenta:',
      'name': 'Imię',
      'surname': 'Nazwisko',
      'pesel': 'PESEL',
      'birthDate': 'Data urodzenia',
      'gender': 'Płeć',
      'male': 'mężczyzna',
      'female': 'kobieta',
      'contactData': 'Dane kontaktowe:',
      'street': 'Ulica i numer domu',
      'city': 'Miejscowość',
      'postCode': 'Kod Pocztowy',
      'phone': 'Telefon',
      'email': 'Email',
      'guardianInfo':
          'Imię i nazwisko przedstawiciela ustawowego w przypadku osoby małoletniej, całkowicie ubezwłasnowolnionej lub niezdolnej do wyrażenia zgody:',
      'guardianAddress':
          'Pełny adres zamieszkania przedstawiciela ustawowego w przypadku osoby małoletniej, całkowicie ubezwłasnowolnionej lub niezdolnej do wyrażenia zgody:',
      'declaration': 'Oświadczenie',
      'authorizationQuestion':
          'Upoważniam niżej wymienioną osobę / Nie upoważniam nikogo',
      'authorizationOption1':
          'a) do uzyskiwania informacji o stanie mojego zdrowia i udzielonych świadczeniach zdrowotnych',
      'authorizationOption2':
          'b) do uzyskiwania dokumentacji medycznej dotyczącej mojej osoby',
      'authorizationName': 'Imię (osoby upoważnionej)',
      'authorizationSurname': 'Nazwisko',
      'authorizationAddress': 'Adres:',
      'authorizationPhone': 'Telefon:',
      'authorizationPesel': 'PESEL (osoby upoważnionej)*',
      'peselNote':
          '*podanie numeru PESEL nie jest obowiązkowe jednak w sposób znaczny ułatwia identyfikację osoby upoważnionej i minimalizuje ryzyko udostępnienia danych osobie nieuprawnionej',
      'medicalHistory': 'Historia choroby',
      'diseaseQuestion':
          'Czy stwierdzono kiedykolwiek u Pana/Pani następujące schorzenia:',
      'yes': 'Tak',
      'no': 'Nie',
      'dontKnow': 'Nie wiem',
      'contraindications': 'Przeciwwskazania:',
      'other': 'Inne:',
      'pregnancy': 'Czy jest Pani w ciąży?',
      'treatmentReason':
          'Z jakiego powodu zdecydował się Pan/Pani na leczenie ortodontyczne:',
      'additionalComments': 'Dodatkowe uwagi na temat mojego stanu zdrowia:',
      'declarationText':
          'Oświadczam, że informacje podane powyżej są zgodne ze stanem faktycznym. Wszystkie zmiany mojej sytuacji zdrowotnej, szczególnie mogącej mieć wpływ na przebieg leczenia stomatologicznego w tym ortodontycznego, zobowiązuję się zgłaszać niezwłocznie lekarzowi prowadzącemu.',
      'dataProtectionTitle':
          'INFORMACJA DLA PACJENTA DOTYCZĄCA OCHRONY DANYCH OSOBOWYCH',
      'dataProtectionIntro': 'Przyjmuję do wiadomości, że:',
      'dataProtection1':
          'Administratorem danych osobowych jest Gabinet Ortodontyczny Agnieszka Golarz – Nosek, Kordylewskiego 1/3, 31-542 Kraków',
      'dataProtection2':
          'Pani/Pana dane osobowe są przetwarzane przez Administratora w następującym celu: udzielania świadczeń zdrowotnych służących ochronie zdrowia i życia, zapewnienia bezpieczeństwa i porządku oraz ochrony osób i mienia, przeciwdziałania skutkom pandemii COVID-19 archiwizacji, statystycznym, ustalenia, dochodzenia lub obrony roszczeń, prowadzenia ksiąg rachunkowych i dokumentacji podatkowej.',
      'dataProtection3':
          'Podstawą przetwarzania Państwa danych osobowych są, w szczególności, następujące przepisy prawa: a) Ustawa z dnia 6 listopada 2008 r. o prawach pacjenta i Rzeczniku Praw Pacjenta; b) Rozporządzenia Ministra Zdrowia z dnia 9 listopada 2015 r. w sprawie rodzajów, zakresu i wzorów dokumentacji medycznej oraz sposobu jej przetwarzania; c) Ustawa z dnia 29 września 1994 r. o rachunkowości; d) Ustawa z dnia 16 lipca 2004 r. Prawo telekomunikacyjne; e) Ustawa z dnia 18 lipca 2002 r. o świadczeniu usług drogą elektroniczną; f) Ustawa z dnia 5 grudnia 2008 o zapobieganiu oraz zwalczaniu zakażeń i chorób zakaźnych u ludzi; g) Ustawa z dnia 2 marca 2020 r. o szczególnych rozwiązaniach związanych z zapobieganiem, przeciwdziałaniem i zwalczaniem COVID-19, innych chorób zakaźnych oraz wywołanych nimi sytuacji kryzysowych.',
      'dataProtection4':
          'Pana/Pani dane osobowe będą przechowywane w czasie oraz zakresie niezbędnym do realizacji celów przetwarzania i wynikającym ze szczegółowych przepisów:',
      'dataProtection5':
          'Podanie danych, w zakresie powyżej obowiązujących przepisów jest niezbędne do udzielenia świadczeń leczniczych. Podanie numeru telefonu, adresu poczty elektronicznej jest dobrowolne, lecz w przypadku ich braku nie będzie możliwe potwierdzenie, zmiana terminu wizyty lub weryfikacja prawidłowości zleconych badań.',
      'dataProtection6':
          'W celu zapewnienia bezpieczeństwa oraz ochrony mienia, Administrator prowadzi rejestrację obrazu (monitoring) w obszarze rejestracji pacjenta. Administrator przetwarza nagrania obrazu (monitoringu) wyłącznie do celów dla którego zostały zebrane i przechowuje przez okres nie dłuższy niż 3 miesiące od dnia nagrania. Po upływie tego okresu nagrania obrazu podlegają automatycznemu zniszczeniu.',
      'dataProtection7':
          'Przysługuje Pani/ Panu prawo do: żądania od Administratora dostępu do danych osobowych, prawo do ich sprostowania, prawo do usunięcia, ograniczenia przetwarzania lub prawo do wniesienia sprzeciwu wobec przetwarzania, z zastrzeżeniem jednak zasad gromadzenia i przetwarzania danych w dokumentacji medycznej, o których mowa w szczególnych przepisach prawnych.',
      'dataProtection8':
          'Istnieje możliwość wniesienia skargi do Urzędu Ochrony Danych Osobowych na tryb i sposób przetwarzania danych osobowych przez Administratora, jeśli uzna Pani/Pan za uzasadnione, że Pani/ Pana dane osobowe są przetwarzane niezgodnie z obowiązującymi przepisami prawa.',
      'dataProtection9':
          'Administrator nie będzie przekazywał Pani/Pana danych osobowych odbiorcom w państwach trzecich oraz organizacjom międzynarodowym.',
      'dataProtection10':
          'Pani/Pana dane nie będą przetwarzane w sposób zautomatyzowany, w tym nie będą podlegały profilowaniu.',
      'dataProtection11':
          'Administrator wyznaczył Inspektora Ochrony Danych, z którym można się kontaktować przez e-mail: daneosobowe@golarz.pl, lub na adres: Gabinet Ortodontyczny Agnieszka Golarz – Nosek; ul. Kordylewskiego 1/3; 31-542 Kraków',
      'patientDeclarationTitle': 'Oświadczenie pacjenta',
      'patientDeclarationText':
          'Zgodnie z art. 6 i 7 Rozporządzenia Parlamentu Europejskiego i Rady (UE) 2016/679 z dnia 27 kwietnia 2016 r. o ochronie danych osobowych (RODO) wyrażam zgodę na przetwarzanie moich danych osobowych w zakresie:*',
      'consent1':
          'Kontakt za pośrednictwem telefonii stacjonarnej/komórkowej/SMS w celu realizacji wizyty (w sprawie jej potwierdzenia, przesunięcia odwołania), weryfikacji wyników badań lub innej informacji udzielanej w zakresie ochrony zdrowia',
      'consent2':
          'Kontakt mailowy w celu realizacji wizyty (w sprawie jej potwierdzenia, przesunięcia odwołania), weryfikacji wyników badań lub innej informacji udzielanej w zakresie ochrony zdrowia',
      'consent3':
          'Otrzymywanie informacji marketingowej na temat promocji i zabiegów wykonywanych w Gabinecie Ortodontycznym Agnieszka Golarz – Nosek, 31-542 Kraków',
      'consentNote': '*Prosze zaznaczyc właściwe',
      'submit': 'Zapisz',
      'clear': 'Wyczyść',
    },
    'en': {
      'title': 'Patient Questionnaire',
      'confidential':
          'Any information you have provided are covered by medical secrecy.',
      'personalData': "Patient's personal data:",
      'name': 'Name',
      'surname': 'Surname',
      'pesel': 'Personal Identity Number (patients with Polish ID card only)',
      'birthDate': 'Date of birth',
      'gender': 'Sex',
      'male': 'Male',
      'female': 'Female',
      'contactData': 'Contact details:',
      'street': 'Street and house number',
      'city': 'City',
      'postCode': 'Postal code',
      'phone': 'Phone',
      'email': 'Email',
      'guardianInfo':
          'Name and surname of legal representative in case of a minor, completely incapacitated or unable to give consent:',
      'guardianAddress':
          'Full residential address of the legal representative in case of a minor, completely incapacitated or unable to give consent:',
      'declaration': 'Statement',
      'authorizationQuestion':
          'I authorize the following person / I don\'t authorize anyone',
      'authorizationOption1':
          'a) to obtain information about my health state and provided medical service',
      'authorizationOption2': 'b) to get access to my medical documentation',
      'authorizationName': 'Name (of responsible party)',
      'authorizationSurname': 'Surname ',
      'authorizationAddress': 'Address',
      'authorizationPhone': 'Phone',
      'authorizationPesel': 'Personal Identity Number / Passport number*',
      'peselNote':
          '*providing a Personal Identity Number / Passport number is not obligatory. It significantly simplifies identification of authorized person and minimizes the possibility of sharing data with an unauthorized person',
      'medicalHistory': 'Orthodontic Health Questionnaire',
      'diseaseQuestion': 'Have you ever had any of the following conditions:	',
      'yes': 'Yes',
      'no': 'No',
      'dontKnow': 'I don\'t know',
      'contraindications': 'Contraindications:',
      'other': 'Other:',
      'pregnancy': 'Are you pregnant?',
      'treatmentReason': 'What is the reason for your orthodontic treatment:',
      'additionalComments': 'Additional remarks about my health condition:',
      'declarationText':
          'To the best of my knowledge, all the preceding answers are true and correct. If I have any change in my health or medications, especially one that might have influence on my dental and orthodontic treatment, I will immediately inform the doctor.',
      'dataProtectionTitle':
          'INFORMATION FOR THE PATIENT REGARDING PERSONAL DATA PROTECTION',
      'dataProtectionIntro': 'I acknowledge that:',
      'dataProtection1':
          'The administrator of personal data is the Orthodontic Office of Agnieszka Golarz-Nosek, Kordylewskiego 1/3, 31-542 Kraków',
      'dataProtection2':
          'Your personal data is processed by the Administrator for the following purposes: providing health services aimed at protecting health and life, ensuring safety and order as well as protection of persons and property, counteracting the effects of the COVID-19 pandemic, archiving, statistical purposes, establishing, pursuing or defending claims, keeping accounting books and tax documentation.',
      'dataProtection3':
          'The legal basis for the processing of your personal data are, in particular, the following legal provisions: a) the Act of 6 November 2008 on Patient Rights and the Patient Rights Ombudsman; b) the Regulation of the Minister of Health of 9 November 2015 on the types, scope and templates of medical documentation and the method of its processing; c) the Act of 29 September 1994 on accounting; d) the Act of 16 July 2004 Telecommunications Law; e) the Act of 18 July 2002 on the provision of services by electronic means; f) the Act of 5 December 2008 on the prevention and control of infections and infectious diseases in humans; g) the Act of 2 March 2020 on specific solutions related to the prevention, counteraction and combating of COVID-19, other infectious diseases and crisis situations caused by them.',
      'dataProtection4':
          'Your personal data will be stored for the time and to the extent necessary to achieve the purposes of processing and resulting from detailed regulations:',
      'dataProtection5':
          'Providing data, within the scope of the above applicable regulations, is necessary to provide health services. Providing a telephone number, e-mail address is voluntary, but in their absence it will not be possible to confirm, change the appointment date or verify the correctness of ordered tests.',
      'dataProtection6':
          'In order to ensure safety and property protection, the Administrator records images (monitoring) in the patient registration area. The Administrator processes image recordings (monitoring) only for the purposes for which they were collected and stores them for no longer than 3 months from the date of recording. After this period, the image recordings are automatically destroyed.',
      'dataProtection7':
          'You have the right to: request from the Administrator access to personal data, the right to rectify them, the right to delete, limit processing or the right to object to processing, subject to the rules of collecting and processing data in medical documentation, specified in specific legal provisions.',
      'dataProtection8':
          'You have the right to lodge a complaint with the Data Protection Authority regarding the manner and method of processing personal data by the Administrator, if you consider that your personal data is processed in violation of applicable law.',
      'dataProtection9':
          'The Administrator will not transfer your personal data to recipients in third countries or international organizations.',
      'dataProtection10':
          'Your data will not be processed in an automated manner, including profiling.',
      'dataProtection11':
          'The Administrator has appointed a Data Protection Officer, who can be contacted by e-mail: daneosobowe@golarz.pl, or at the address: Orthodontic Office Agnieszka Golarz-Nosek; ul. Kordylewskiego 1/3; 31-542 Kraków',
      'patientDeclarationTitle': 'Patient declaration',
      'patientDeclarationText':
          'In accordance with Art. 6 and 7 of the Regulation of the European Parliament and of the Council (EU) 2016/679 of 27 April 2016 on the protection of personal data (GDPR), I consent to the processing of my personal data in the following scope:*',
      'consent1':
          'Contact via landline/mobile phone/SMS for the purpose of appointment (to confirm, reschedule or cancel it), verification of test results or other information provided in the field of health protection',
      'consent2':
          'E-mail contact for the purpose of appointment (to confirm, reschedule or cancel it), verification of test results or other information provided in the field of health protection',
      'consent3':
          'Receiving marketing information about promotions and treatments performed at the Orthodontic Office of Agnieszka Golarz-Nosek, 31-542 Kraków',
      'consentNote': '*Please mark the appropriate ones',
      'submit': 'Save',
      'clear': 'Clear',
      'retentionWarranty': 'Retention Warranty',
      'warrantyTerms': 'Terms and conditions of permanent retention warranty:',
      'warrantyTerm1':
          'dental hygiene visits (removing plaque) every six months',
      'warrantyTerm2':
          'maintaining proper oral hygiene according to the orthodontist\'s or hygienist\'s instructions given during visits',
      'warrantyTerm3':
          'attending regular control visits according to orthodontist\'s recommendations',
      'warrantyTerm4':
          'immediate compliance with recommendations given by the orthodontist during control visits',
      'warrantyNotCover': 'Permanent retention warranty doesn\'t cover:',
      'warrantyNotCover1':
          'treatments with limited or with no warranty, about which the patient had been previously informed, done at the patient\'s explicit request',
      'warrantyDamage':
          'Warranty doesn\'t cover retainer damages that occurred as a result of:',
      'warrantyDamage1': 'insufficient oral hygiene',
      'warrantyDamage2':
          'not following orthodontist\'s instructions concerning usage of the orthodontic appliance or retainer',
      'warrantyDamage3': 'not attending control visits',
      'warrantyDamage4': 'mechanical damages',
      'warrantyDamage5': 'naturally declining bone and periodontal diseases',
      'warrantyDamage6':
          'previously existing disease which has unfavourable influence on the chewing system (e. g. diabetics, epilepsy, osteoporosis, post- radiation and post cytostatic therapy condition)',
      'warrantyDeclaration':
          'I have read and understood the above terms and conditions of warranty given by Agnieszka Golarz-Nosek Orthodontics. The terms are clear and understandable for me. I am aware that not following these terms makes the warranty invalid.',
    },
  };

  // List of diseases for medical history section
  final List<Map<String, String>> _diseases = [
    {
      "id": "hypertension",
      "pl": "Nadciśnienie",
      "en": "High blood pressure",
      "hasDescription": "false",
    },
    {
      "id": "ischemia",
      "pl": "Choroba niedokrwienna serca",
      "en": "Ischaemic heart disease",
      "hasDescription": "false",
    },
    {
      "id": "circulation",
      "pl": "Niewydolność krążenia",
      "en": "Circulatory failure",
      "hasDescription": "false",
    },
    {
      "id": "infarct",
      "pl": "Przebyty zawał serca",
      "en": "Heart attack",
      "hasDescription": "false",
    },
    {
      "id": "heartDisease",
      "pl": "Wady/choroby serca",
      "en": "Heart Disease",
      "hasDescription": "true",
      "hintTextPl": "Jeśli tak, prosze wpisać.",
      "hintTextEn": "If so, please enter.",
    },
    {
      "id": "starter",
      "pl": "Wszczepiony rozrusznik serca, sztuczna zastawka",
      "en": "Pacemaker, artificial valve",
      "hasDescription": "false",
    },
    {
      "id": "kidneyDisease",
      "pl": "Choroby nerek",
      "en": "Kidney Disease",
      "hasDescription": "false",
    },
    {
      "id": "rheumaticDiseases",
      "pl": "Choroby reumatyczne (np. zapalenie stawów)",
      "en": "Rheumatic Disease (e.g. arthritis)",
      "hasDescription": "false",
    },
    {
      "id": "ophthalmologicalDiseases",
      "pl": "Choroby okulistyczne (np. jaskra)",
      "en": "Eye Disease (e.g. glaucoma)",
      "hasDescription": "false",
    },
    {
      "id": "hormonalDisorders",
      "pl": "Zaburzenia hormonalne",
      "en": "Hormone Disorders",
      "hasDescription": "false",
    },
    {
      "id": "prolongedBleeding",
      "pl": "Przedłużone krwawienie (np. po skaleczeniu)",
      "en": "Bleeding disorders (prolonged bleeding after cut)",
      "hasDescription": "false",
    },
    {
      "id": "hemofil",
      "pl": "Hemofilia",
      "en": "Hemophilia",
      "hasDescription": "false",
    },
    {
      "id": "epilepsy",
      "pl": "Padaczka",
      "en": "Epilepsy",
      "hasDescription": "false",
    },
    {"id": "asthma", "pl": "Astma", "en": "Asthma", "hasDescription": "false"},
    {
      "id": "lung",
      "pl": "Choroby płuc (np. gruźlica)",
      "en": "Lung Disease (e.g. tuberculosis)",
      "hasDescription": "false",
    },
    {
      "id": "liverFailure",
      "pl": "Niewydolność wątroby",
      "en": "Hepatic failure",
      "hasDescription": "false",
    },
    {
      "id": "wzwB",
      "pl": "WZW B (żółtaczka zakaźna)",
      "en": "Hepatisis B (HBV)",
      "hasDescription": "false",
    },
    {
      "id": "wzwC",
      "pl": "WZW C (żółtaczka typu C)",
      "en": "Hepatisis C (HCV)",
      "hasDescription": "false",
    },
    {
      "id": "hiv",
      "pl": "AIDS, HIV pozytywny",
      "en": "AIDS, HIV Positive",
      "hasDescription": "false",
    },
    {
      "id": "thyroidDisease",
      "pl": "Choroby tarczycy",
      "en": "Endocrine Problems",
      "hasDescription": "false",
    },
    {
      "id": "diabetes",
      "pl": "Cukrzyca",
      "en": "Diabetics",
      "hasDescription": "false",
    },
    {
      "id": "allergyToAnesthetics",
      "pl":
          "Czy ma Pan/Pani alergię na środki znieczulające, leki, materiały stomatologiczne",
      "en":
          "Have you had oral anaesthesia recently? Allergy to anaesthetics, medications or dental materials",
      "hasDescription": "true",
      "hintTextPl": "Jeśli tak, prosze wpisać alergeny.",
      "hintTextEn": "If so, please enter the allergens.",
    },
    {
      "id": "allergyToMetals",
      "pl": "Alergia na metale",
      "en": "Allergy to metals",
      "hasDescription": "true",
      "hintTextPl": "Jeśli tak, proszę uzupełnić na jakie metale uczulenie.",
      "hintTextEn": "If so, please specify which metals you are allergic to.",
    },
    {
      "id": "anaphylacticShock",
      "pl": "Wstrząs anafilaktyczny (uczuleniowy)",
      "en": "Anaphylactic shock (allergic)",
      "hasDescription": "false",
    },
    {
      "id": "pregnancy",
      "pl": "Czy jest Pani w ciąży?",
      "en": "Are you pregnant?",
      "hasDescription": "false",
    },
    {
      "id": "operation",
      "pl": "Czy była Pani/Pan operowana(y) w ciągu ostatnich 2 lat?",
      "en": "Have you been hospitalized within last two years?	",
      "hasDescription": "false",
    },
    {
      "id": "actualCure",
      "pl": "Czy aktualnie Pani/Pan się na coś leczy?",
      "en": "Are you currently under a physician’s care?",
      "hasDescription": "true",
      "hintTextPl": "Jeśli tak, proszę opisać leczenie.",
      "hintTextEn": "If so, please describe the treatment.",
    },
    {
      "id": "inhibitionOfBloodCoagulation",
      "pl": "Czy przyjmuje Pani/Pan środki hamujące krzepnięcie krwi?",
      "en": "Do you take any medicines preventing blood clotting?",
      "hasDescription": "false",
    },
    {
      "id": "otherDiseases",
      "pl": "Czy miał(a) Pan/Pani jakieś niewymienione dotąd schorzenia?",
      "en": "Are there any health problems not covered above?",
      "hasDescription": "true",
      "hintTextPl": "Jeśli tak, proszę wpisać niewymienione schorzenia.",
      "hintTextEn": "If so, please list problems not covered.",
    },
    {
      "id": "orthodonticTreatment",
      "pl": "Czy był(a) Pan/Pani leczony ortodontycznie?",
      "en":
          "Have you ever had a previous orthodontic consultation or treatment?",
      "hasDescription": "false",
    },
    {
      "id": "psychiatricTreatment",
      "pl":
          "Czy było kiedykolwiek u Pani/Pana przeprowadzone leczenie psychiatryczne?",
      "en": "Have you ever had psychiatric treatment?",
      "hasDescription": "true",
      "hintTextPl": "Jeśli tak, proszę opisać, jakie leczenie i kiedy.",
      "hintTextEn": "If so, please describe what treatment and when.",
    },
    {
      "id": "psychologicalTreatment",
      "pl": "Czy pozostaje Pani/Pan w opiece psychologicznej?",
      "en": "Are you under psychological care?",
      "hasDescription": "false",
    },
    {
      "id": "historicalpsychologicalTreatment",
      "pl":
          "Czy była u Pani/Pana w przeszłości prowadzona opieka psychologiczna?",
      "en": "Have you had psychological care in the past?",
      "hasDescription": "false",
    },
    {
      "id": "mentalDisable",
      "pl": "Czy stwierdzono u Pani/Pana upośledzenie umysłowe?",
      "en": "Have you been diagnosed with mental disability?",
      "hasDescription": "true",
      "hintTextPl": "Jeśli tak, proszę uzupełnić stopień upośledzenia.",
      "hintTextEn": "If so, please complete the degree of impairment.",
    },
  ];

  String _t(String key) {
    return _translations[_selectedLanguage]![key] ?? key;
  }

  String _diseaseName(String diseaseId) {
    return _diseases.firstWhere(
          (d) => d['id'] == diseaseId,
        )[_selectedLanguage] ??
        diseaseId;
  }

  @override
  void initState() {
    super.initState();
    // Initialize disease responses
    for (var disease in _diseases) {
      _diseaseResponses[disease['id']!] = {
        'yes': null,
        'no': null,
        'dontKnow': null,
      };
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

  Widget _buildTextFormField({
    required String label,
    required String controllerKey,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? hintText,
    int? maxLength,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
        TextFormField(
          controller: _controllers[controllerKey],
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLength: maxLength,
          maxLines: maxLines,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRadioGroup({
    required String label,
    required String name,
    required List<String> options,
    String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: options.map((option) {
              return Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: selectedValue,
                    onChanged: onChanged,
                  ),
                  Text(_t(option)),
                  const SizedBox(width: 16),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseQuestion(String diseaseId) {
    final disease = _diseases.firstWhere(
      (d) => d['id'] == diseaseId,
      orElse: () => {},
    );

    final hintText = _selectedLanguage == 'pl'
        ? disease['hintTextPl'] ?? 'Jeśli tak, proszę wpisać'
        : disease['hintTextEn'] ?? 'If yes, please specify';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_diseaseName(diseaseId)),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: TextFormField(
            controller: _controllers['${diseaseId}Description'],
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
            ),
            minLines: 1,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildConsentCheckbox(String consentKey, String text) {
    return CheckboxListTile(
      title: Text(text),
      value: _consents[consentKey],
      onChanged: (bool? value) {
        setState(() {
          _consents[consentKey] = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildWarrantySection() {
    if (_selectedLanguage != 'en') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          _t('retentionWarranty'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(_t('warrantyTerms')),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ${_t('warrantyTerm1')}'),
              Text('• ${_t('warrantyTerm2')}'),
              Text('• ${_t('warrantyTerm3')}'),
              Text('• ${_t('warrantyTerm4')}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(_t('warrantyNotCover')),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text('• ${_t('warrantyNotCover1')}'),
        ),
        const SizedBox(height: 16),
        Text(_t('warrantyDamage')),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ${_t('warrantyDamage1')}'),
              Text('• ${_t('warrantyDamage2')}'),
              Text('• ${_t('warrantyDamage3')}'),
              Text('• ${_t('warrantyDamage4')}'),
              Text('• ${_t('warrantyDamage5')}'),
              Text('• ${_t('warrantyDamage6')}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _t('warrantyDeclaration'),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Here you would typically send the data to your backend
      // For now, we'll just show a success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_t('submit'))));
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedGender = null;
      _selectedAuthorization = null;
      for (var disease in _diseases) {
        _diseaseResponses[disease['id']!] = {
          'yes': null,
          'no': null,
          'dontKnow': null,
        };
      }
      for (var consent in _consents.keys) {
        _consents[consent] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('title')),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Text(
                  _t('title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _t('confidential'),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Personal Data Section
              Text(
                _t('personalData'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextFormField(
                label: _t('name'),
                controllerKey: 'patientName',
                validator: (value) =>
                    value?.isEmpty ?? true ? _t('requiredField') : null,
              ),

              _buildTextFormField(
                label: _t('surname'),
                controllerKey: 'patientSurname',
                validator: (value) =>
                    value?.isEmpty ?? true ? _t('requiredField') : null,
              ),

              _buildTextFormField(
                label: _t('pesel'),
                controllerKey: 'patientPesel',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value?.isEmpty ?? true) return _t('requiredField');
                  if (value!.length != 11)
                    return _selectedLanguage == 'pl'
                        ? 'PESEL powinien mieć 11 cyfr'
                        : 'PESEL should have 11 digits';
                  return null;
                },
              ),

              _buildTextFormField(
                label: _t('birthDate'),
                controllerKey: 'patientBirthday',
                hintText: _selectedLanguage == 'pl'
                    ? 'dd.mm.rrrr'
                    : 'dd.mm.yyyy',
                validator: (value) {
                  if (value?.isEmpty ?? true) return _t('requiredField');
                  if (!RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(value!)) {
                    return _selectedLanguage == 'pl'
                        ? 'Wpisz datę w formacie dd.mm.rrrr'
                        : 'Enter date in dd.mm.yyyy format';
                  }
                  return null;
                },
              ),

              // Gender
              _buildRadioGroup(
                label: _t('gender'),
                name: 'patientSex',
                options: ['male', 'female'],
                selectedValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value),
              ),

              // Contact Data Section
              Text(
                _t('contactData'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextFormField(
                label: _t('street'),
                controllerKey: 'patientStreet',
                validator: (value) =>
                    value?.isEmpty ?? true ? _t('requiredField') : null,
              ),

              _buildTextFormField(
                label: _t('city'),
                controllerKey: 'patientCity',
                validator: (value) =>
                    value?.isEmpty ?? true ? _t('requiredField') : null,
              ),

              _buildTextFormField(
                label: _t('postCode'),
                controllerKey: 'patientPostCode',
                hintText: '00-000',
                validator: (value) {
                  if (value?.isEmpty ?? true) return _t('requiredField');
                  if (!RegExp(r'^\d{2}-\d{3}$').hasMatch(value!)) {
                    return _selectedLanguage == 'pl'
                        ? 'Wpisz kod w formacie 00-000'
                        : 'Enter code in 00-000 format';
                  }
                  return null;
                },
              ),

              _buildTextFormField(
                label: _t('phone'),
                controllerKey: 'patientPhone',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? _t('requiredField') : null,
              ),

              _buildTextFormField(
                label: _t('email'),
                controllerKey: 'patientEmail',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isNotEmpty ?? false) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value!)) {
                      return _selectedLanguage == 'pl'
                          ? 'Wpisz poprawny email'
                          : 'Enter valid email';
                    }
                  }
                  return null;
                },
              ),

              // Guardian Section
              _buildTextFormField(
                label: _t('guardianInfo'),
                controllerKey: 'patientGuardian',
                maxLines: 1,
              ),

              _buildTextFormField(
                label: _t('guardianAddress'),
                controllerKey: 'patientGuardianStreet',
                maxLines: 2,
              ),

              _buildWarrantySection(),

              // Authorization Section
              const SizedBox(height: 24),
              Text(
                _t('declaration'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildRadioGroup(
                label: _t('authorizationQuestion'),
                name: 'patientAuthorization',
                options: ['yes', 'no'],
                selectedValue: _selectedAuthorization,
                onChanged: (value) =>
                    setState(() => _selectedAuthorization = value),
              ),

              if (_selectedAuthorization == 'yes') ...[
                Text(_t('authorizationOption1')),
                Text(_t('authorizationOption2')),
                const SizedBox(height: 16),

                _buildTextFormField(
                  label: _t('authorizationName'),
                  controllerKey: 'patientAuthorizationName',
                ),

                _buildTextFormField(
                  label: _t('authorizationSurname'),
                  controllerKey: 'patientAuthorizationSurname',
                ),

                _buildTextFormField(
                  label: _t('authorizationAddress'),
                  controllerKey: 'patientAuthorizationAddress',
                ),

                _buildTextFormField(
                  label: _t('authorizationPhone'),
                  controllerKey: 'patientAuthorizationPhone',
                  keyboardType: TextInputType.phone,
                ),

                _buildTextFormField(
                  label: _t('authorizationPesel'),
                  controllerKey: 'patientAuthorizationPesel',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                Text(
                  _t('peselNote'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Medical History Section
              const Divider(height: 32),
              Center(
                child: Text(
                  _t('medicalHistory'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _t('confidential'),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Diseases table
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(8),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _t('diseaseQuestion'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('yes'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('no'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('dontKnow'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Add rows for each disease
                  for (var disease in _diseases.take(21))
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (disease['hasDescription'] == "false")
                              ? Text(_diseaseName(disease['id']!))
                              : _buildDiseaseQuestion(disease['id']!),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'yes',
                            groupValue:
                                _diseaseResponses[disease['id']]!['yes'] == '1'
                                ? 'yes'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['yes'] = '1';
                              });
                            },
                          ),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'no',
                            groupValue:
                                _diseaseResponses[disease['id']]!['no'] == '1'
                                ? 'no'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['no'] = '1';
                              });
                            },
                          ),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'dontKnow',
                            groupValue:
                                _diseaseResponses[disease['id']]!['dontKnow'] ==
                                    '1'
                                ? 'dontKnow'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['dontKnow'] =
                                    '1';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _t('contraindications'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('yes'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('no'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('dontKnow'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var disease in _diseases.sublist(21, 24))
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (disease['hasDescription'] == "false")
                              ? Text(_diseaseName(disease['id']!))
                              : _buildDiseaseQuestion(disease['id']!),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'yes',
                            groupValue:
                                _diseaseResponses[disease['id']]!['yes'] == '1'
                                ? 'yes'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['yes'] = '1';
                              });
                            },
                          ),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'no',
                            groupValue:
                                _diseaseResponses[disease['id']]!['no'] == '1'
                                ? 'no'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['no'] = '1';
                              });
                            },
                          ),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'dontKnow',
                            groupValue:
                                _diseaseResponses[disease['id']]!['dontKnow'] ==
                                    '1'
                                ? 'dontKnow'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['dontKnow'] =
                                    '1';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _t('other'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('yes'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('no'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            _t('dontKnow'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var disease in _diseases.sublist(24, 34))
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (disease['hasDescription'] == "false")
                              ? Text(_diseaseName(disease['id']!))
                              : _buildDiseaseQuestion(disease['id']!),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'yes',
                            groupValue:
                                _diseaseResponses[disease['id']]!['yes'] == '1'
                                ? 'yes'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['yes'] = '1';
                              });
                            },
                          ),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'no',
                            groupValue:
                                _diseaseResponses[disease['id']]!['no'] == '1'
                                ? 'no'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['no'] = '1';
                              });
                            },
                          ),
                        ),
                        Center(
                          child: Radio<String>(
                            value: 'dontKnow',
                            groupValue:
                                _diseaseResponses[disease['id']]!['dontKnow'] ==
                                    '1'
                                ? 'dontKnow'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _diseaseResponses[disease['id']]!.updateAll(
                                  (k, v) => null,
                                );
                                _diseaseResponses[disease['id']]!['dontKnow'] =
                                    '1';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Treatment reason
              _buildTextFormField(
                label: _t('treatmentReason'),
                controllerKey: 'patientQuestion_new',
                maxLength: 70,
              ),

              // Additional comments
              _buildTextFormField(
                label: _t('additionalComments'),
                controllerKey: 'comments',
                maxLines: 3,
                maxLength: 400,
              ),

              // Declaration
              Text(
                _t('declarationText'),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),

              // Data Protection Information
              Center(
                child: Text(
                  _t('dataProtectionTitle'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _t('dataProtectionIntro'),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Data protection points
              for (int i = 1; i <= 11; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$i. ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: _t('dataProtection$i')),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),

              // Patient Declaration
              const SizedBox(height: 24),
              Center(
                child: Text(
                  _t('patientDeclarationTitle'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _t('patientDeclarationText'),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Consents
              _buildConsentCheckbox('zgoda1', _t('consent1')),
              _buildConsentCheckbox('zgoda2', _t('consent2')),
              _buildConsentCheckbox('zgoda3', _t('consent3')),

              Text(
                _t('consentNote'),
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("miejsce na podpis"),
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
                    const SizedBox(height: 16),
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
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Podpis pacjenta lub opiekuna prawnego"),
                    const SizedBox(height: 16),
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
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
