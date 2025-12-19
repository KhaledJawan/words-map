// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Pushto Pashto (`ps`).
class AppLocalizationsPs extends AppLocalizations {
  AppLocalizationsPs([String locale = 'ps']) : super(locale);

  @override
  String get settingsTitle => 'امستنې';

  @override
  String get settingsChangeLanguage => 'ژبه بدلول';

  @override
  String get settingsAppLanguageTitle => 'د اپ ژبه';

  @override
  String get settingsWordLanguagesTitle => 'د لغتونو ژبه';

  @override
  String get settingsSelectWordLanguagesTitle => 'د لغتونو ژبې';

  @override
  String get settingsSelectWordLanguagesHint => '۱ یا ۲ ژبې وټاکئ';

  @override
  String get settingsWordLanguagesMaxTwo => 'تر ۲ ژبو پورې انتخابولی شئ.';

  @override
  String get settingsWordLanguagesMinOne => 'لږ تر لږه یوه ژبه وټاکئ.';

  @override
  String get tabHome => 'کور';

  @override
  String get tabLessons => 'درسونه';

  @override
  String get tabProfile => 'پروفایل';

  @override
  String get totalWordsLabel => 'ټول لغتونه';

  @override
  String get settingsLanguageFarsi => 'فارسی';

  @override
  String get settingsLanguagePashto => 'پښتو';

  @override
  String get loadWordsFailed => 'کلمې بار نه شوې.';

  @override
  String get settingsSelectLanguageTitle => 'ژبه وټاکئ';

  @override
  String get settingsLanguage => 'ژبه';

  @override
  String get settingsLanguageDescription => 'د اپلیکیشن ژبه';

  @override
  String get settingsTheme => 'تم';

  @override
  String get settingsThemeDescription => 'د اپ بڼه وټاکئ';

  @override
  String get settingsThemeSystem => 'د سیستم له مخې';

  @override
  String get settingsThemeLight => 'روښانه';

  @override
  String get settingsThemeDark => 'تیاره';

  @override
  String get settingsNotificationsTitle => 'خبرتیاوې او یادونې';

  @override
  String get settingsNotifications => 'د اپ خبرتیاوې';

  @override
  String get settingsNotificationsDescription => 'خبرتیاوې او ورځنۍ یادونې';

  @override
  String get settingsDailyReminder => 'ورځنۍ یادونه';

  @override
  String get lessonsTitle => 'درسونه';

  @override
  String get lessonBeginnerAlphabetTitle => 'الفبا';

  @override
  String get lessonBeginnerReadingRulesTitle => 'د لوستلو اصول';

  @override
  String get lessonBeginnerPartsOfSpeechTitle => 'د وينا برخې';

  @override
  String get lessonBeginnerHalloTitle => 'سلام';

  @override
  String get lessonBeginnerAllAboutGermanTitle => 'د جرمني په اړه';

  @override
  String get lessonsCategoryBeginnerBasics => 'ابتدايي بنسټونه';

  @override
  String get lessonsCategoryGrammar => 'ګرامر';

  @override
  String get lessonsCategoryReadingListening => 'لوستل او اورېدل';

  @override
  String get lessonsCategoryExamPractice => 'د ازموینې تمرین';

  @override
  String get grammarLevelA1 => 'د A1 ګرامر';

  @override
  String get grammarLevelA2 => 'د A2 ګرامر';

  @override
  String get grammarLevelB1 => 'د B1 ګرامر';

  @override
  String get grammarLevelB2 => 'د B2 ګرامر';

  @override
  String get grammarLevelC1 => 'د C1 ګرامر';

  @override
  String grammarLevelLessonsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درسونه',
      one: '۱ درس',
      zero: 'لا درس نشته',
    );
    return '$_temp0';
  }

  @override
  String get lessonsStatusComingSoon => 'ژر راځي';

  @override
  String get grammarContentLoadError => 'د ګرامر منځپانګه نه بارېږي.';

  @override
  String get lessonExamplesTitle => 'بېلګې';

  @override
  String get grammarTopicComingSoon => 'منځپانګه وروسته اضافه کېږي.';

  @override
  String get lessonButtonNext => 'بل';

  @override
  String get slideAlphabetOverviewTitle => 'د جرمني الفبا – عمومي کتنه';

  @override
  String get slideAlphabetVowelsTitle => 'غږلرونکي توري (A, E, I, O, U)';

  @override
  String get slideAlphabetUmlautTitle => 'اُملاؤت غږلرونکي (Ä, Ö, Ü)';

  @override
  String get slideAlphabetEsszettTitle => 'ß – Eszett';

  @override
  String get slideReadingBasicRuleTitle => 'د لوستلو بنسټیزه قاعده – «ie» او «ei»';

  @override
  String get slideReadingSchChSpStTitle => '«sch»، «ch» او «sp / st»';

  @override
  String get slideReadingCapitalLettersTitle => 'لوی توري (اسمونه)';

  @override
  String get slideReadingLongVsShortTitle => 'اوږده او لنډه غږونه';

  @override
  String get slidePartsMainPartsTitle => 'د وينا اصلي برخې';

  @override
  String get slidePartsNounsGenderTitle => 'اسمونه او جنس';

  @override
  String get slidePartsVerbsInfinitiveTitle => 'فعل په بنسټیزه بڼه (Infinitiv)';

  @override
  String get slidePartsAdjectivesTitle => 'صفتونه – د تشریح کلمې';

  @override
  String get slideHalloBasicGreetingsTitle => 'بنسټیز سلامونه';

  @override
  String get slideHalloIntroducingTitle => 'ځان معرفي کول';

  @override
  String get slideHalloHowAreYouTitle => '«څنګه يې؟» پوښتنه';

  @override
  String get slideHalloPoliteWordsTitle => 'مؤدبانه کلمې';

  @override
  String get slideGermanWhereSpokenTitle => 'جرمني چېرته ویل کېږي؟';

  @override
  String get slideGermanFormalInformalTitle => 'رسمی او غیررسمی «ته/تاسو»';

  @override
  String get slideGermanWordOrderTitle => 'د کلمو ترتیب – بنسټیزه مفکوره';

  @override
  String get slideGermanLongWordsTitle => 'له اوږدو کلمو مه وېرېږه';

  @override
  String chapterOverview(Object chapter) {
    return 'د فصل $chapter عمومي کتنه';
  }

  @override
  String get chooseChapter => 'خپل فصل وټاکئ';

  @override
  String get chapterEmptyState => 'په دې فصل کې لا کلمې نشته.';

  @override
  String get bookmarkedLabel => 'نښه شوي';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get viewedLabel => 'لیدل شوي';

  @override
  String get lessonCompleted => 'بشپړ شو';

  @override
  String get lessonRepeat => 'تکرار';

  @override
  String get lessonRepeatAgain => 'بیا تکرار';

  @override
  String get chapterCategories => 'کټګورۍ';

  @override
  String get chooseCategory => 'یوه کټګوري وټاکئ';

  @override
  String get categoryEmptyState => 'په دې کټګورۍ کې لا کلمې نشته.';

  @override
  String categoryOverview(Object category) {
    return 'د کټګورۍ $category عمومي کتنه';
  }

  @override
  String get homeSupportTitle => '☕️ د WordMap ملاتړ';

  @override
  String get homeSupportBody => 'جرمني دې سر خوږ کړی؟ 🤯\nپر 💎 ټک کړه، چای مو روان وساته ☕️❤️';

  @override
  String get homeSupportSupportButton => 'ملاتړ';

  @override
  String get homeSupportCloseTooltip => 'بندول';

  @override
  String get commonClose => 'بندول';

  @override
  String get commonLesson => 'درس';

  @override
  String get lessonLoadFailed => 'درس نه بارېږي.';

  @override
  String get audioPlaybackFailed => 'غږ نه شي غږول کېدای.';

  @override
  String get adLoading => 'اعلان بارېږي…';

  @override
  String get noMoreWordsTitle => 'نورې کلمې نشته';

  @override
  String get noMoreWordsBody => '۰ ته ورسېدې. یو اعلان وګوره تر څو 💎 حالت د ۱ ساعت لپاره فعال شي (بې‌حده کلمې)، یا ۱ ساعت انتظار وکړه تر څو ۵۰ کلمې بېرته درشي.';

  @override
  String get noMoreWordsWaitOneHour => '۱ ساعت انتظار';

  @override
  String get noMoreWordsWatchAd => 'اعلان وګوره';

  @override
  String get diamondBadgeSubtitleActive => 'الماس';

  @override
  String get diamondBadgeSubtitleInactive => 'پاتې';

  @override
  String get diamondBadgeSubtitleCooldown => 'تم';

  @override
  String cooldownActive(Object time) {
    return 'له $time وروسته بیا هڅه وکړه';
  }

  @override
  String get updateAvailableTitle => 'نوې نسخه شته';

  @override
  String get updateAvailableBody => 'د نوو امکاناتو لپاره، مهرباني وکړئ WordMap تازه کړئ.';

  @override
  String get updateAvailableLater => 'وروسته';

  @override
  String get updateAvailableUpdate => 'تازه کول';

  @override
  String authError(Object error) {
    return 'د ننوتلو تېروتنه: $error';
  }

  @override
  String get tagA1Core => 'د A1 بنسټیز';

  @override
  String get tagDailyLife => 'ورځنی ژوند';

  @override
  String get tagConversationPhrases => 'د خبرو جملې';

  @override
  String get tagGreetingsPoliteness => 'سلام او ادب';

  @override
  String get tagQuestionsAnswers => 'پوښتنې او ځوابونه';

  @override
  String get tagTimeDate => 'وخت او نېټه';

  @override
  String get tagNumbersMath => 'شمېرې او حساب';

  @override
  String get tagColorsShapes => 'رنګونه او شکلونه';

  @override
  String get tagDaysMonthsSeasons => 'ورځې، میاشتې او فصلونه';

  @override
  String get tagWeather => 'هوا';

  @override
  String get tagDirectionsNavigation => 'لارښوونې او لوریابۍ';

  @override
  String get tagPlacesBuildings => 'ځایونه او ودانۍ';

  @override
  String get tagCityTransport => 'ښار او ترانسپورت';

  @override
  String get tagTravelHolidays => 'سفر او رخصتي';

  @override
  String get tagHomeHousehold => 'کور او کورنۍ چارې';

  @override
  String get tagFurnitureRooms => 'فرنیچر او خونې';

  @override
  String get tagKitchenCooking => 'پخلنځی او پخلی';

  @override
  String get tagFoodDrink => 'خواړه او څښاک';

  @override
  String get tagShoppingMoney => 'پېرود او پیسې';

  @override
  String get tagClothingFashion => 'کالي او فېشن';

  @override
  String get tagHealthBody => 'روغتیا او بدن';

  @override
  String get tagFeelingsEmotions => 'احساسات';

  @override
  String get tagPeopleFamily => 'خلک او کورنۍ';

  @override
  String get tagRelationships => 'اړیکې';

  @override
  String get tagSchoolLearning => 'ښوونځی او زده کړه';

  @override
  String get tagWorkOffice => 'کار او دفتر';

  @override
  String get tagJobsProfessions => 'دندې او مسلکونه';

  @override
  String get tagTechnologyInternet => 'ټکنالوژي او انټرنېټ';

  @override
  String get tagMediaSocial => 'رسنۍ او ټولنیزې شبکې';

  @override
  String get tagHobbiesSports => 'شوقونه او ورزش';

  @override
  String get tagNatureAnimals => 'طبیعت او ژوي';

  @override
  String get tagPlantsEnvironment => 'بوټي او چاپېریال';

  @override
  String get tagCultureEvents => 'کلتور او پېښې';

  @override
  String get tagServicesAuthorities => 'خدمات او ادارې';

  @override
  String get tagReligionCulture => 'دین او کلتور';

  @override
  String get tagSafetyEmergency => 'خوندیتوب او بېړني حالت';

  @override
  String get tagLawRules => 'قانون او قواعد';

  @override
  String get tagVerb => 'فعل';

  @override
  String get tagNoun => 'اسم';

  @override
  String get tagAdjective => 'صفت';

  @override
  String get tagAdverb => 'قید';

  @override
  String get tagPronoun => 'ضمیر';

  @override
  String get tagArticle => 'آرټیکل';

  @override
  String get tagPreposition => 'حرف اضافه';

  @override
  String get tagConjunction => 'حرف ربط';

  @override
  String get tagModalVerb => 'مرستندوی فعل';

  @override
  String get tagSeparableVerb => 'بېلېدونکی فعل';

  @override
  String get tagReflexiveVerb => 'انعکاسي فعل';

  @override
  String get tagIrregularVerb => 'بې قاعدې فعل';

  @override
  String get tagQuestionWord => 'پوښتنیز ټکی';

  @override
  String get tagNegation => 'نفي';

  @override
  String get tagNumbers => 'شمېرې';

  @override
  String get tagTimeExpression => 'وختي عبارت';

  @override
  String get tagPlaceExpression => 'ځایي عبارت';

  @override
  String get tagProperNoun => 'ځانګړی نوم';

  @override
  String get tagLoanwordInternational => 'نړیوال پوراخیستل شوی ټکی';

  @override
  String get tagAbbreviation => 'لنډیز';

  @override
  String get tagUncategorized => 'بې کټګورۍ';
}
