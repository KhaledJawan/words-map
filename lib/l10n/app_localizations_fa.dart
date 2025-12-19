// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsChangeLanguage => 'تغییر زبان';

  @override
  String get settingsAppLanguageTitle => 'زبان برنامه';

  @override
  String get settingsWordLanguagesTitle => 'زبان ترجمهٔ کلمات';

  @override
  String get settingsSelectWordLanguagesTitle => 'زبان‌های کلمات';

  @override
  String get settingsSelectWordLanguagesHint => '۱ یا ۲ زبان را انتخاب کنید';

  @override
  String get settingsWordLanguagesMaxTwo => 'حداکثر ۲ زبان می‌توانید انتخاب کنید.';

  @override
  String get settingsWordLanguagesMinOne => 'حداقل یک زبان را انتخاب کنید.';

  @override
  String get tabHome => 'خانه';

  @override
  String get tabLessons => 'درس‌ها';

  @override
  String get tabProfile => 'حساب کاربری';

  @override
  String get totalWordsLabel => 'مجموع کلمات';

  @override
  String get settingsLanguageFarsi => 'فارسی';

  @override
  String get settingsLanguagePashto => 'پښتو';

  @override
  String get loadWordsFailed => 'بارگذاری کلمات ناموفق بود.';

  @override
  String get settingsSelectLanguageTitle => 'انتخاب زبان';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageDescription => 'زبان برنامه';

  @override
  String get settingsTheme => 'تم';

  @override
  String get settingsThemeDescription => 'ظاهر برنامه را انتخاب کنید';

  @override
  String get settingsThemeSystem => 'مطابق سیستم';

  @override
  String get settingsThemeLight => 'حالت روشن';

  @override
  String get settingsThemeDark => 'حالت تاریک';

  @override
  String get settingsNotificationsTitle => 'اعلان‌ها و یادآوری‌ها';

  @override
  String get settingsNotifications => 'اعلان‌های برنامه';

  @override
  String get settingsNotificationsDescription => 'اعلان‌های برنامه و یادآوری روزانه';

  @override
  String get settingsDailyReminder => 'یادآوری روزانه';

  @override
  String get lessonsTitle => 'درس‌ها';

  @override
  String get lessonBeginnerAlphabetTitle => 'الفبا';

  @override
  String get lessonBeginnerReadingRulesTitle => 'قواعد خواندن';

  @override
  String get lessonBeginnerPartsOfSpeechTitle => 'اقسام کلمه';

  @override
  String get lessonBeginnerHalloTitle => 'سلام';

  @override
  String get lessonBeginnerAllAboutGermanTitle => 'همه‌چیز دربارهٔ آلمانی';

  @override
  String get lessonsCategoryBeginnerBasics => 'مبانی مقدماتی';

  @override
  String get lessonsCategoryGrammar => 'دستور زبان';

  @override
  String get lessonsCategoryReadingListening => 'خواندن و شنیدن';

  @override
  String get lessonsCategoryExamPractice => 'تمرین آزمون';

  @override
  String get grammarLevelA1 => 'گرامر A1';

  @override
  String get grammarLevelA2 => 'گرامر A2';

  @override
  String get grammarLevelB1 => 'گرامر B1';

  @override
  String get grammarLevelB2 => 'گرامر B2';

  @override
  String get grammarLevelC1 => 'گرامر C1';

  @override
  String grammarLevelLessonsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درس',
      one: '1 درس',
      zero: 'هنوز درسی نیست',
    );
    return '$_temp0';
  }

  @override
  String get lessonsStatusComingSoon => 'به‌زودی';

  @override
  String get grammarContentLoadError => 'بارگذاری محتوای گرامر با خطا مواجه شد.';

  @override
  String get lessonExamplesTitle => 'نمونه‌ها';

  @override
  String get grammarTopicComingSoon => 'محتوا به‌زودی اضافه می‌شود.';

  @override
  String get lessonButtonNext => 'بعدی';

  @override
  String get slideAlphabetOverviewTitle => 'الفبای آلمانی – معرفی';

  @override
  String get slideAlphabetVowelsTitle => 'صدادارها (A, E, I, O, U)';

  @override
  String get slideAlphabetUmlautTitle => 'اُملاؤت‌ها (Ä, Ö, Ü)';

  @override
  String get slideAlphabetEsszettTitle => 'ß – Eszett';

  @override
  String get slideReadingBasicRuleTitle => 'قاعدهٔ سادهٔ خواندن – «ie» در برابر «ei»';

  @override
  String get slideReadingSchChSpStTitle => '“sch”, “ch” and “sp / st”';

  @override
  String get slideReadingCapitalLettersTitle => 'حروف بزرگ (اسم‌ها)';

  @override
  String get slideReadingLongVsShortTitle => 'صدادار بلند و کوتاه';

  @override
  String get slidePartsMainPartsTitle => 'اقسام اصلی کلمه';

  @override
  String get slidePartsNounsGenderTitle => 'اسم‌ها و جنسیت';

  @override
  String get slidePartsVerbsInfinitiveTitle => 'فعل در شکل پایه (Infinitiv)';

  @override
  String get slidePartsAdjectivesTitle => 'صفت‌ها – کلمات توصیفی';

  @override
  String get slideHalloBasicGreetingsTitle => 'سلام‌های ساده';

  @override
  String get slideHalloIntroducingTitle => 'معرفی خود';

  @override
  String get slideHalloHowAreYouTitle => 'پرسیدن «حال‌تان چطور است؟»';

  @override
  String get slideHalloPoliteWordsTitle => 'کلمات مؤدبانه';

  @override
  String get slideGermanWhereSpokenTitle => 'آلمانی کجا صحبت می‌شود؟';

  @override
  String get slideGermanFormalInformalTitle => 'رسمی و غیررسمی در «تو/شما»';

  @override
  String get slideGermanWordOrderTitle => 'ترتیب کلمات – ایدهٔ کلی';

  @override
  String get slideGermanLongWordsTitle => 'از کلمات طولانی نترس';

  @override
  String chapterOverview(Object chapter) {
    return 'نمای کلی فصل $chapter';
  }

  @override
  String get chooseChapter => 'فصل خود را انتخاب کنید';

  @override
  String get chapterEmptyState => 'در این فصل هنوز کلمه‌ای نیست.';

  @override
  String get bookmarkedLabel => 'نشان‌دار';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get viewedLabel => 'دیده‌شده';

  @override
  String get lessonCompleted => 'یاد گرفتم';

  @override
  String get lessonRepeat => 'تکرار';

  @override
  String get lessonRepeatAgain => 'دوباره تکرار کن';

  @override
  String get chapterCategories => 'دسته‌بندی‌ها';

  @override
  String get chooseCategory => 'یک دسته‌بندی را انتخاب کنید';

  @override
  String get categoryEmptyState => 'در این دسته‌بندی هنوز کلمه‌ای نیست.';

  @override
  String categoryOverview(Object category) {
    return 'نمای کلی دسته‌بندی $category';
  }

  @override
  String get homeSupportTitle => '☕️ حمایت از WordMap';

  @override
  String get homeSupportBody => 'اگر WordMap کمکت می‌کند… ☺️\nبا 💎 حمایت کن تا چای ما همیشه دم باشد ☕️❤️';

  @override
  String get homeSupportSupportButton => 'حمایت';

  @override
  String get homeSupportCloseTooltip => 'بستن';

  @override
  String get commonClose => 'بستن';

  @override
  String get commonLesson => 'درس';

  @override
  String get lessonLoadFailed => 'بارگذاری درس ناموفق بود.';

  @override
  String get audioPlaybackFailed => 'پخش صدا ممکن نشد.';

  @override
  String get adLoading => 'تبلیغ در حال بارگذاری است…';

  @override
  String get noMoreWordsTitle => 'دیگر کلمه‌ای نمانده';

  @override
  String get noMoreWordsBody => 'به ۰ رسیدی. یک تبلیغ ببین تا حالت 💎 برای ۱ ساعت فعال شود (کلمه نامحدود)، یا ۱ ساعت صبر کن تا ۵۰ کلمه دوباره برگردد.';

  @override
  String get noMoreWordsWaitOneHour => '۱ ساعت صبر کن';

  @override
  String get noMoreWordsWatchAd => 'دیدن تبلیغ';

  @override
  String get diamondBadgeSubtitleActive => 'الماس';

  @override
  String get diamondBadgeSubtitleInactive => 'مانده';

  @override
  String get diamondBadgeSubtitleCooldown => 'وقفه';

  @override
  String cooldownActive(Object time) {
    return 'بعد از $time دوباره امتحان کن';
  }

  @override
  String get updateAvailableTitle => 'نسخهٔ جدید موجود است';

  @override
  String get updateAvailableBody => 'برای دریافت امکانات جدید، لطفاً WordMap را به‌روز کنید.';

  @override
  String get updateAvailableLater => 'بعداً';

  @override
  String get updateAvailableUpdate => 'به‌روزرسانی';

  @override
  String authError(Object error) {
    return 'خطای ورود: $error';
  }

  @override
  String get tagA1Core => 'کلمات اصلی A1';

  @override
  String get tagDailyLife => 'زندگی روزمره';

  @override
  String get tagConversationPhrases => 'عبارت‌های گفت‌وگو';

  @override
  String get tagGreetingsPoliteness => 'سلام و ادب';

  @override
  String get tagQuestionsAnswers => 'پرسش و پاسخ';

  @override
  String get tagTimeDate => 'وقت و تاریخ';

  @override
  String get tagNumbersMath => 'اعداد و حساب';

  @override
  String get tagColorsShapes => 'رنگ‌ها و شکل‌ها';

  @override
  String get tagDaysMonthsSeasons => 'روزها، ماه‌ها و فصل‌ها';

  @override
  String get tagWeather => 'آب‌وهوا';

  @override
  String get tagDirectionsNavigation => 'مسیر و جهت‌یابی';

  @override
  String get tagPlacesBuildings => 'مکان‌ها و ساختمان‌ها';

  @override
  String get tagCityTransport => 'شهر و ترانسپورت';

  @override
  String get tagTravelHolidays => 'سفر و رخصتی';

  @override
  String get tagHomeHousehold => 'خانه و کارهای خانه';

  @override
  String get tagFurnitureRooms => 'مبلمان و اتاق‌ها';

  @override
  String get tagKitchenCooking => 'آشپزخانه و پخت‌وپز';

  @override
  String get tagFoodDrink => 'خوراک و نوشیدنی';

  @override
  String get tagShoppingMoney => 'خرید و پول';

  @override
  String get tagClothingFashion => 'لباس و پوشاک';

  @override
  String get tagHealthBody => 'سلامتی و بدن';

  @override
  String get tagFeelingsEmotions => 'احساسات';

  @override
  String get tagPeopleFamily => 'مردم و خانواده';

  @override
  String get tagRelationships => 'روابط';

  @override
  String get tagSchoolLearning => 'مکتب و یادگیری';

  @override
  String get tagWorkOffice => 'کار و دفتر';

  @override
  String get tagJobsProfessions => 'شغل‌ها';

  @override
  String get tagTechnologyInternet => 'تکنالوژی و اینترنت';

  @override
  String get tagMediaSocial => 'رسانه و شبکه‌های اجتماعی';

  @override
  String get tagHobbiesSports => 'سرگرمی و ورزش';

  @override
  String get tagNatureAnimals => 'طبیعت و حیوانات';

  @override
  String get tagPlantsEnvironment => 'گیاهان و محیط‌زیست';

  @override
  String get tagCultureEvents => 'فرهنگ و رویدادها';

  @override
  String get tagServicesAuthorities => 'خدمات و ادارات';

  @override
  String get tagReligionCulture => 'دین و فرهنگ';

  @override
  String get tagSafetyEmergency => 'ایمنی و حالات اضطراری';

  @override
  String get tagLawRules => 'قانون و مقررات';

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
  String get tagArticle => 'حرف تعریف';

  @override
  String get tagPreposition => 'حرف اضافه';

  @override
  String get tagConjunction => 'حرف ربط';

  @override
  String get tagModalVerb => 'فعل کمکی';

  @override
  String get tagSeparableVerb => 'فعل جداشدنی';

  @override
  String get tagReflexiveVerb => 'فعل انعکاسی';

  @override
  String get tagIrregularVerb => 'فعل بی‌قاعده';

  @override
  String get tagQuestionWord => 'کلمهٔ پرسشی';

  @override
  String get tagNegation => 'نفی';

  @override
  String get tagNumbers => 'اعداد';

  @override
  String get tagTimeExpression => 'عبارت زمانی';

  @override
  String get tagPlaceExpression => 'عبارت مکانی';

  @override
  String get tagProperNoun => 'اسم خاص';

  @override
  String get tagLoanwordInternational => 'کلمهٔ قرضی (بین‌المللی)';

  @override
  String get tagAbbreviation => 'اختصار';

  @override
  String get tagUncategorized => 'بدون دسته‌بندی';
}
