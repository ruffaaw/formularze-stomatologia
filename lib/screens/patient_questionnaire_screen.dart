import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:email_validator/email_validator.dart';

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
      'day': 'Dzień',
      'month': 'Miesiąc',
      'year': 'Rok',
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
      'day': 'Day',
      'month': 'Month',
      'year': 'Year',
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
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
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
              hintText:
                  hintText ??
                  (_selectedLanguage == 'pl'
                      ? 'Wprowadź $label...'
                      : 'Enter $label...'),
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
              isDense: true,
            ),
            style: const TextStyle(fontSize: 16),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator:
                validator ??
                (required
                    ? (value) => value?.trim().isEmpty ?? true
                          ? _selectedLanguage == 'pl'
                                ? 'Pole wymagane'
                                : "Required field"
                          : null
                    : null),
            maxLength: maxLength,
            maxLines: maxLines,
          ),
        ],
      ),
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

  Widget _buildBirthDateField({
    required String label,
    required String controllerKey,
    bool required = true,
  }) {
    final dayController = TextEditingController();
    final monthController = TextEditingController();
    final yearController = TextEditingController();

    // Inicjalizacja z istniejącą datą
    if (_controllers[controllerKey]!.text.isNotEmpty) {
      final parts = _controllers[controllerKey]!.text.split('.');
      if (parts.length == 3) {
        dayController.text = parts[0];
        monthController.text = parts[1];
        yearController.text = parts[2];
      }
    }

    void _updateDate() {
      final day = dayController.text.padLeft(2, '0');
      final month = monthController.text.padLeft(2, '0');
      final year = yearController.text;
      _controllers[controllerKey]!.text = '$day.$month.$year';
    }

    String? _validateDate() {
      if (!required &&
          dayController.text.isEmpty &&
          monthController.text.isEmpty &&
          yearController.text.isEmpty) {
        return null;
      }

      // Podstawowa walidacja każdego pola
      if (dayController.text.isEmpty ||
          monthController.text.isEmpty ||
          yearController.text.isEmpty) {
        return _selectedLanguage == 'pl'
            ? 'Wprowadź pełną datę'
            : 'Enter full date';
      }

      final day = int.tryParse(dayController.text) ?? 0;
      final month = int.tryParse(monthController.text) ?? 0;
      final year = int.tryParse(yearController.text) ?? 0;

      // Walidacja zakresów
      if (month < 1 || month > 12) {
        return _selectedLanguage == 'pl'
            ? 'Nieprawidłowy miesiąc (1-12)'
            : 'Invalid month (1-12)';
      }

      if (day < 1 || day > 31) {
        return _selectedLanguage == 'pl'
            ? 'Nieprawidłowy dzień (1-31)'
            : 'Invalid day (1-31)';
      }

      int _getMaxDaysForMonth(int month, int year) {
        if (month == 2) {
          return DateTime(year, 3, 0).day; // Luty - uwzględnia lata przestępne
        }
        if ([4, 6, 9, 11].contains(month)) {
          return 30;
        }
        return 31;
      }

      // Specyficzna walidacja dla każdego miesiąca
      final maxDays = _getMaxDaysForMonth(month, year);
      if (day > maxDays) {
        return _selectedLanguage == 'pl'
            ? 'Nieprawidłowa liczba dni dla wybranego miesiąca (max $maxDays)'
            : 'Invalid days count for selected month (max $maxDays)';
      }

      // Sprawdzenie czy data jest z przyszłości
      final selectedDate = DateTime(year, month, day);
      if (selectedDate.isAfter(DateTime.now())) {
        return _selectedLanguage == 'pl'
            ? 'Data nie może być z przyszłości'
            : 'Date cannot be in the future';
      }

      return null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(label, style: const TextStyle(fontSize: 16)),
            ),
          Row(
            children: [
              // Dzień
              Flexible(
                child: TextFormField(
                  controller: dayController,
                  decoration: InputDecoration(
                    hintText: _t('day'),
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
                    isDense: true,
                    counterText: "",
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    _updateDate();
                    // Automatyczne przejście do następnego pola
                    if (dayController.text.length == 2) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Miesiąc
              Flexible(
                child: TextFormField(
                  controller: monthController,
                  decoration: InputDecoration(
                    hintText: _t('month'),
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
                    isDense: true,
                    counterText: "",
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    _updateDate();
                    if (monthController.text.length == 2) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Rok
              Flexible(
                child: TextFormField(
                  controller: yearController,
                  decoration: InputDecoration(
                    hintText: _t('year'),
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
                    isDense: true,
                    counterText: "",
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _updateDate(),
                ),
              ),
            ],
          ),
          if (_controllers[controllerKey]!.text.isNotEmpty)
            Text(
              _validateDate() ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  void _saveForm(context) async {
    if (await validateForm()) {
      // Formularz jest poprawny, można kontynuować zapis
      generateAndSavePDF(context);
    }
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

              _buildBirthDateField(
                label: _t('birthDate'),
                controllerKey: 'patientBirthday',
                required: true,
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
                hintText: "",
                maxLines: 1,
              ),

              _buildTextFormField(
                label: _t('guardianAddress'),
                controllerKey: 'patientGuardianStreet',
                hintText: "",
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
              Text(_t('authorizationOption1')),
              Text(_t('authorizationOption2')),
              const SizedBox(height: 16),

              if (_selectedAuthorization == 'yes') ...[
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
      final now = DateTime.now();
      final formattedDateTime =
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      doc.addPage(
        pw.Page(
          theme: pdfTheme,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Header(level: 0, text: 'Ankieta Osobowa Pacjenta'),
                ),
                pw.SizedBox(height: 20),

                // Dane osobowe
                _buildPdfSectionTitle('DANE OSOBOWE PACJENTA'),
                _buildPdfTextField('Imię:', _controllers['patientName']!.text),
                _buildPdfTextField(
                  'Nazwisko:',
                  _controllers['patientSurname']!.text,
                ),
                _buildPdfTextField(
                  'PESEL:',
                  _controllers['patientPesel']!.text,
                ),
                _buildPdfTextField(
                  'Data urodzenia:',
                  _controllers['patientBirthday']!.text,
                ),
                _buildPdfTextField(
                  'Płeć:',
                  _selectedGender == 'male'
                      ? 'Mężczyzna'
                      : _selectedGender == 'female'
                      ? 'Kobieta'
                      : "brak",
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Dane kontaktowe
                _buildPdfSectionTitle('DANE KONTAKTOWE'),
                _buildPdfTextField(
                  'Ulica:',
                  _controllers['patientStreet']!.text,
                ),
                _buildPdfTextField(
                  'Miasto:',
                  _controllers['patientCity']!.text,
                ),
                _buildPdfTextField(
                  'Kod pocztowy:',
                  _controllers['patientPostCode']!.text,
                ),
                _buildPdfTextField(
                  'Telefon:',
                  _controllers['patientPhone']!.text,
                ),
                _buildPdfTextField(
                  'Email:',
                  _controllers['patientEmail']!.text,
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Opiekun (jeśli dotyczy)
                if (_controllers['patientGuardian']!.text.isNotEmpty) ...[
                  _buildPdfSectionTitle('DANE OPIEKUNA'),
                  _buildPdfTextField(
                    'Opiekun:',
                    _controllers['patientGuardian']!.text,
                  ),
                  _buildPdfTextField(
                    'Adres opiekuna:',
                    _controllers['patientGuardianStreet']!.text,
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                ],

                _buildPdfSectionTitle('OŚWIADCZENIE'),
                if (_selectedAuthorization == 'yes') ...[
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Upoważniam niżej wymienioną osobę',
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildPdfTextField(
                    'Imię:',
                    _controllers['patientAuthorizationName']!.text,
                  ),
                  _buildPdfTextField(
                    'Nazwisko:',
                    _controllers['patientAuthorizationSurname']!.text,
                  ),
                  _buildPdfTextField(
                    'Adres:',
                    _controllers['patientAuthorizationAddress']!.text,
                  ),
                  _buildPdfTextField(
                    'Telefon:',
                    _controllers['patientAuthorizationPhone']!.text,
                  ),
                  _buildPdfTextField(
                    'PESEL:',
                    _controllers['patientAuthorizationPesel']!.text,
                  ),
                ],
                if (_selectedAuthorization == 'no') ...[
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [pw.TextSpan(text: 'Nie upoważniam nikogo')],
                      ),
                    ),
                  ),
                ], // Wywiad medyczny
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
              _buildPdfSectionTitle('HISTORIA CHOROBY'),
              // W sekcji generowania PDF dodaj:
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Nagłówek tabeli
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          _t('diseaseQuestion'),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('yes'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('no'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('dontKnow'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Wiersze z chorobami
                  for (var disease in _diseases.take(21))
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: (disease['hasDescription'] == "false")
                              ? pw.Text(_diseaseName(disease['id']!))
                              : pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(_diseaseName(disease['id']!)),
                                    if (_controllers[_getDescriptionControllerKey(
                                              disease['id']!,
                                            )]
                                            ?.text
                                            .isNotEmpty ??
                                        false)
                                      pw.Text(
                                        _controllers[_getDescriptionControllerKey(
                                              disease['id']!,
                                            )]!
                                            .text,
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                  ],
                                ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['yes'] == '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['no'] == '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['dontKnow'] ==
                                  '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Sekcja przeciwwskazań
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          _t('contraindications'),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('yes'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('no'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('dontKnow'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Wiersze z przeciwwskazaniami
                  for (var disease in _diseases.sublist(21, 24))
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: (disease['hasDescription'] == "false")
                              ? pw.Text(_diseaseName(disease['id']!))
                              : pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(_diseaseName(disease['id']!)),
                                    if (_controllers[_getDescriptionControllerKey(
                                              disease['id']!,
                                            )]
                                            ?.text
                                            .isNotEmpty ??
                                        false)
                                      pw.Text(
                                        _controllers[_getDescriptionControllerKey(
                                              disease['id']!,
                                            )]!
                                            .text,
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                  ],
                                ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['yes'] == '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['no'] == '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['dontKnow'] ==
                                  '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Sekcja inne
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          _t('other'),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('yes'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('no'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            _t('dontKnow'),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Wiersze z innymi chorobami
                  for (var disease in _diseases.sublist(24, 34))
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: (disease['hasDescription'] == "false")
                              ? pw.Text(_diseaseName(disease['id']!))
                              : pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(_diseaseName(disease['id']!)),
                                    if (_controllers[_getDescriptionControllerKey(
                                              disease['id']!,
                                            )]
                                            ?.text
                                            .isNotEmpty ??
                                        false)
                                      pw.Text(
                                        _controllers[_getDescriptionControllerKey(
                                              disease['id']!,
                                            )]!
                                            .text,
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                  ],
                                ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['yes'] == '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['no'] == '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: _buildPdfCheckbox(
                              _diseaseResponses[disease['id']]!['dontKnow'] ==
                                  '1',
                              isCentered: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 10),
              _buildPdfTextField2(
                'Z jakiego powodu zdecydował się Pan/Pani na leczenie ortodontyczne:',
                _controllers['patientQuestion_new']!.text,
              ),
              _buildPdfTextField2(
                'Dodatkowe uwagi na temat mojego stanu zdrowia:',
                _controllers['comments']!.text,
                maxLines: 3,
              ),
            ];
          },
        ),
      );

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
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Text(
                  'Oświadczam, że informacje podane powyżej są zgodne ze stanem faktycznym. Wszystkie zmiany mojej sytuacji zdrowotnej, szczególnie mogącej mieć wpływ na przebieg leczenia stomatologicznego w tym ortodontycznego, zobowiązuję się zgłaszać niezwłocznie lekarzowi prowadzącemu.',
                  // style: const pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
              pw.SizedBox(height: 16),
              _buildPdfSectionTitle(
                'INFORMACJA DLA PACJENTA DOTYCZĄCA OCHRONY DANYCH OSOBOWYCH',
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Przyjmuję do wiadomości, że:',
                  style: const pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 16),

              for (int i = 1; i <= 11; i++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: '$i. ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.TextSpan(
                          text: _translations['pl']!['dataProtection$i'],
                        ),
                      ],
                    ),
                    textAlign: pw.TextAlign.justify,
                  ),
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
                _buildPdfSectionTitle('ZGODY'),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Text(
                    'Zgodnie z art. 6 i 7 Rozporządzenia Parlamentu Europejskiego i Rady (UE) 2016/679 z dnia 27 kwietnia 2016 r. o ochronie danych osobowych (RODO) wyrażam zgodę na przetwarzanie moich danych osobowych w zakresie:',
                    textAlign: pw.TextAlign.justify,
                  ),
                ),
                _buildConsentPdfRow(
                  'Kontakt za pośrednictwem telefonii stacjonarnej/komórkowej/SMS w celu realizacji wizyty (w sprawie jej potwierdzenia, przesunięcia odwołania), weryfikacji wyników badań lub innej informacji udzielanej w zakresie ochrony zdrowia',
                  _consents['zgoda1'] ?? false,
                ),
                _buildConsentPdfRow(
                  'Kontakt mailowy w celu realizacji wizyty (w sprawie jej potwierdzenia, przesunięcia odwołania), weryfikacji wyników badań lub innej informacji udzielanej w zakresie ochrony zdrowia',
                  _consents['zgoda2'] ?? false,
                ),
                _buildConsentPdfRow(
                  'Otrzymywanie informacji marketingowej na temat promocji i zabiegów wykonywanych w Gabinecie Ortodontycznym Agnieszka Golarz – Nosek, 31-542 Kraków',
                  _consents['zgoda3'] ?? false,
                ),
                pw.SizedBox(height: 20),

                // Podpis
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    children: [
                      pw.Text('Podpis pacjenta lub opiekuna prawnego:'),
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

  // Pomocnicze funkcje:

  String? _getDescriptionControllerKey(String diseaseId) {
    switch (diseaseId) {
      case 'heartDisease':
        return 'heartDiseaseDescription';
      case 'allergyToAnesthetics':
        return 'allergyToAnestheticsDescription';
      case 'allergyToMetals':
        return 'allergyToMetalsDescription';
      case 'actualCure':
        return 'actualCureDescription';
      case 'otherDiseases':
        return 'otherDiseasesDescription';
      case 'psychiatricTreatment':
        return 'psychiatricTreatmentDescription';
      case 'mentalDisable':
        return 'mentalDisableDescription';
      default:
        return null;
    }
  }

  pw.Widget _buildDiseasePdfRow(
    String diseaseId,
    Map<String, String> response,
    String? description,
  ) {
    final responseText = response['yes'] == '1'
        ? 'Tak${description != null && description.isNotEmpty ? " ($description)" : ""}'
        : response['no'] == '1'
        ? 'Nie'
        : 'Nie wiem';

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '${_diseaseName(diseaseId)}: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: responseText),
          ],
        ),
      ),
    );
  }

  Future<ByteData?> _getSignatureImageBytes() async {
    try {
      final signatureState = _signaturePadKey.currentState;
      if (signatureState == null) return null;

      final image = await signatureState.toImage();
      return await image.toByteData(format: ImageByteFormat.png);
    } catch (e) {
      return null;
    }
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

  // Future<void> _saveAndSharePdf(pw.Document doc) async {
  //   final status = await Permission.storage.request();
  //   if (!status.isGranted) {
  //     throw Exception('Brak uprawnień do zapisu pliku');
  //   }

  //   final directory = await getApplicationDocumentsDirectory();
  //   final fileName =
  //       'Ankieta_Osobowa_${_controllers['patientName']}_${_controllers['patientSurname']}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
  //   final file = File('${directory.path}/$fileName');

  //   final pdfBytes = await doc.save();
  //   await file.writeAsBytes(pdfBytes);

  //   await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  // }

  Future<void> _saveAndSharePdf(pw.Document doc) async {
    // 1. Sprawdź i poproś o wymagane uprawnienia
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Brak uprawnień do zapisu pliku');
    }
    final name = _controllers['patientName']!.text.trim();
    final surname = _controllers['patientSurname']!.text.trim();
    final fileName =
        '${surname}_${name}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}_ankieta_pacjenta.pdf'
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

  void showValidationError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Walidacja wymaganych pól
  Future<bool> validateForm() async {
    // Dane osobowe - wymagane
    if (_controllers['patientName']!.text.isEmpty) {
      showValidationError('Proszę wprowadzić imię pacjenta');
      return false;
    }

    if (_controllers['patientSurname']!.text.isEmpty) {
      showValidationError('Proszę wprowadzić nazwisko pacjenta');
      return false;
    }

    if (_controllers['patientPesel']!.text.isEmpty ||
        _controllers['patientPesel']!.text.length != 11 ||
        !_controllers['patientPesel']!.text.isNumeric()) {
      showValidationError('Proszę wprowadzić poprawny PESEL (11 cyfr)');
      return false;
    }

    if (_controllers['patientBirthday']!.text.isEmpty) {
      showValidationError('Proszę wprowadzić datę urodzenia');
      return false;
    }

    // Dane kontaktowe - wymagane
    if (_controllers['patientStreet']!.text.isEmpty) {
      showValidationError('Proszę wprowadzić ulicę');
      return false;
    }

    if (_controllers['patientCity']!.text.isEmpty) {
      showValidationError('Proszę wprowadzić miasto');
      return false;
    }

    if (_controllers['patientPostCode']!.text.isEmpty ||
        !RegExp(
          r'^\d{2}-\d{3}$',
        ).hasMatch(_controllers['patientPostCode']!.text)) {
      showValidationError(
        'Proszę wprowadzić poprawny kod pocztowy (format: 00-000)',
      );
      return false;
    }

    if (_controllers['patientPhone']!.text.isEmpty ||
        !_controllers['patientPhone']!.text.isNumeric() ||
        _controllers['patientPhone']!.text.length < 9) {
      showValidationError(
        'Proszę wprowadzić poprawny numer telefonu (minimum 9 cyfr)',
      );
      return false;
    }

    if (_controllers['patientEmail']!.text.isNotEmpty &&
        !EmailValidator.validate(_controllers['patientEmail']!.text)) {
      showValidationError('Proszę wprowadzić poprawny adres email');
      return false;
    }

    if (_selectedAuthorization!.isEmpty) {
      showValidationError('Proszę podać oświadczenie');
      return false;
    }

    // Walidacja opiekuna (jeśli jest uzupełniony)
    if (_controllers['patientGuardian']!.text.isNotEmpty) {
      if (_controllers['patientGuardianStreet']!.text.isEmpty) {
        showValidationError('Proszę wprowadzić adres opiekuna');
        return false;
      }
    }

    // Walidacja upoważnienia (jeśli wybrano "tak")
    if (_selectedAuthorization == 'yes') {
      if (_controllers['patientAuthorizationName']!.text.isEmpty) {
        showValidationError('Proszę wprowadzić imię upoważnionej osoby');
        return false;
      }

      if (_controllers['patientAuthorizationSurname']!.text.isEmpty) {
        showValidationError('Proszę wprowadzić nazwisko upoważnionej osoby');
        return false;
      }

      if (_controllers['patientAuthorizationAddress']!.text.isEmpty) {
        showValidationError('Proszę wprowadzić adres upoważnionej osoby');
        return false;
      }

      if (_controllers['patientAuthorizationPhone']!.text.isEmpty ||
          !_controllers['patientAuthorizationPhone']!.text.isNumeric() ||
          _controllers['patientAuthorizationPhone']!.text.length < 9) {
        showValidationError(
          'Proszę wprowadzić poprawny numer telefonu upoważnionej osoby',
        );
        return false;
      }

      if (_controllers['patientAuthorizationPesel']!.text.isEmpty ||
          _controllers['patientAuthorizationPesel']!.text.length != 11 ||
          !_controllers['patientAuthorizationPesel']!.text.isNumeric()) {
        showValidationError(
          'Proszę wprowadzić poprawny PESEL upoważnionej osoby (11 cyfr)',
        );
        return false;
      }
    }

    // Walidacja opisów chorób (jeśli wybrano "tak" dla chorób z opisem)
    if (_diseaseResponses['heartDisease']?['yes'] == '1' &&
        _controllers['heartDiseaseDescription']!.text.isEmpty) {
      showValidationError('Proszę podać opis choroby serca');
      return false;
    }

    if (_diseaseResponses['allergyToAnesthetics']?['yes'] == '1' &&
        _controllers['allergyToAnestheticsDescription']!.text.isEmpty) {
      showValidationError('Proszę podać opis alergii na anestetyki');
      return false;
    }

    if (_diseaseResponses['allergyToMetals']?['yes'] == '1' &&
        _controllers['allergyToMetalsDescription']!.text.isEmpty) {
      showValidationError('Proszę podać opis alergii na metale');
      return false;
    }

    if (_diseaseResponses['actualCure']?['yes'] == '1' &&
        _controllers['actualCureDescription']!.text.isEmpty) {
      showValidationError('Proszę podać opis aktualnego leczenia');
      return false;
    }

    if (_diseaseResponses['otherDiseases']?['yes'] == '1' &&
        _controllers['otherDiseasesDescription']!.text.isEmpty) {
      showValidationError('Proszę podać opis innych chorób');
      return false;
    }

    if (_diseaseResponses['psychiatricTreatment']?['yes'] == '1' &&
        _controllers['psychiatricTreatmentDescription']!.text.isEmpty) {
      showValidationError('Proszę podać opis leczenia psychiatrycznego');
      return false;
    }

    if (_diseaseResponses['mentalDisable']?['yes'] == '1' &&
        _controllers['mentalDisableDescription']!.text.isEmpty) {
      showValidationError('Proszę podać opis niepełnosprawności umysłowej');
      return false;
    }

    // Walidacja zgód - wymagane są przynajmniej zgoda1 i zgoda2
    if (!(_consents['zgoda1'] ?? false) && !(_consents['zgoda2'] ?? false)) {
      showValidationError('Wymagana jest zgoda na wybrany kontakt');
      return false;
    }

    Future<bool> _isSignatureValid() async {
      try {
        final signatureState = _signaturePadKey.currentState;
        if (signatureState == null) return false;

        final image = await signatureState.toImage();
        final byteData = await image.toByteData();
        if (byteData == null) return false;

        final bytes = byteData.buffer.asUint8List();
        return !bytes.every((byte) => byte == 0);
      } catch (e) {
        return false;
      }
    }

    if (!await _isSignatureValid()) {
      showValidationError('Proszę złożyć podpis');
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
