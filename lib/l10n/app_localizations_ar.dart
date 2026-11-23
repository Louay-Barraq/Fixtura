// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فيكستورا';

  @override
  String get appSubtitle => 'تنظيم وإدارة\nالدوريات والبطولات المحلية';

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get tournamentsTab => 'البطولات';

  @override
  String get createTab => 'إنشاء';

  @override
  String get rouletteTab => 'القرعة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get createNewTournament => 'إنشاء بطولة جديدة';

  @override
  String get quickRouletteSpin => 'تدوير سريع للقرعة';

  @override
  String get lastActiveTournament => 'آخر بطولة نشطة';

  @override
  String get tournaments => 'البطولات';

  @override
  String get total => 'الإجمالي';

  @override
  String get active => 'الجارية';

  @override
  String get finished => 'المنتهية';

  @override
  String get all => 'الكل';

  @override
  String get searchTournaments => 'البحث في البطولات...';

  @override
  String get noTournamentsFound => 'لم يتم العثور على بطولات';

  @override
  String get createYourFirst => 'أنشئ أول بطولة لك للبدء!';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر لغة العرض';

  @override
  String get guideAndTutorial => 'الدليل والشرح';

  @override
  String get viewAppTutorial => 'عرض شرح التطبيق';

  @override
  String get replayOnboarding => 'إعادة تشغيل دليل الخطوات الخمس';

  @override
  String get aboutAndSupport => 'حول التطبيق والدعم';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyPolicySubtitle =>
      'اقرأ بيان الخصوصية الخاص بالتطبيق دون إنترنت';

  @override
  String get contactDeveloper => 'تواصل مع المطور';

  @override
  String get contactDeveloperSubtitle => 'لؤي براق — للملاحظات والدعم الفني';

  @override
  String get rateFixtura => 'تقييم فيكستورا';

  @override
  String get rateFixturaSubtitle => 'شارك برأيك على متجر Google Play';

  @override
  String get shareWithFriends => 'مشاركة مع الأصدقاء';

  @override
  String get shareSubtitle => 'ادعُ أصدقاءك لتنظيم دوريات الألعاب وكرة القدم';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get clearAllTournaments => 'حذف جميع البطولات';

  @override
  String get clearAllSubtitle => 'حذف كافة البيانات وإعادة تعيين التطبيق';

  @override
  String get resetAllDataTitle => 'إعادة تعيين كافة البيانات';

  @override
  String get resetAllDataContent =>
      'هل أنت متأكد من رغبتك في حذف جميع البطولات والمباريات وبيانات القرعة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get resetEverything => 'إعادة تعيين كل شيء';

  @override
  String get cancel => 'إلغاء';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get deleteTournament => 'حذف البطولة';

  @override
  String deleteTournamentConfirm(String name) {
    return 'هل أنت متأكد من رغبتك في حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get tournamentName => 'اسم البطولة';

  @override
  String get tournamentNameHint => 'أدخل اسم البطولة...';

  @override
  String get format => 'النظام';

  @override
  String get league => 'دوري';

  @override
  String get roundRobin => 'دوري النقاط';

  @override
  String get brackets => 'تصفيات';

  @override
  String get knockout => 'خروج المغلوب';

  @override
  String get leagueSettings => 'إعدادات الدوري';

  @override
  String get legs => 'ذهاب / إياب';

  @override
  String get legsSubtitle => 'عدد المواجهات بين كل فريقين';

  @override
  String get pointsSettings => 'نظام النقاط';

  @override
  String get teamRoulette => 'قرعة الفرق';

  @override
  String get enableTeamRoulette => 'تفعيل قرعة الفرق';

  @override
  String get enableRouletteSubtitle => 'توزيع فرق وأندية عشوائية على اللاعبين';

  @override
  String get uniqueTeamsOnly => 'فرق فريدة في الجولة';

  @override
  String get uniqueTeamsSubtitle => 'منع تكرار نفس الفريق في نفس الجولة';

  @override
  String get distinctTeamsAcrossRounds => 'فرق مختلفة عبر الجولات';

  @override
  String get distinctTeamsSubtitle => 'منع حصول اللاعب على نفس الفريق مرتين';

  @override
  String get managePlayers => 'إدارة اللاعبين';

  @override
  String get manageTeams => 'إدارة الفرق';

  @override
  String get roulettePool => 'مجموعة الفرق';

  @override
  String get fixtures => 'المباريات';

  @override
  String get standings => 'الترتيب';

  @override
  String get yourLastMatch => 'آخر مباراة';

  @override
  String get tournamentStatus => 'حالة البطولة';

  @override
  String get tournamentCompleted => 'اكتملت البطولة 🎉';

  @override
  String get noPlayedMatches => 'لم تُلعب أي مباراة بعد';

  @override
  String get waitingForOpponent => 'في انتظار المنافس';

  @override
  String round(int num) {
    return 'الجولة $num';
  }

  @override
  String get createTournament => 'إنشاء البطولة';

  @override
  String get pleaseEnterTournamentName => 'يرجى إدخال اسم البطولة';

  @override
  String get atLeastTwoPlayersRequired =>
      'يجب إضافة لاعبَين اثنين على الأقل في قائمة إدارة اللاعبين.';

  @override
  String get teamPoolEmptyError =>
      'لا يمكن أن تكون قائمة الفرق فارغة عند تفعيل القرعة.';

  @override
  String get tournamentCreatedSuccess => 'تم إنشاء البطولة بنجاح!';

  @override
  String get failedToCreateTournament => 'فشل إنشاء البطولة.';

  @override
  String get addOptions => 'إضافة خيارات';

  @override
  String get rouletteWheel => 'عجلة القرعة';

  @override
  String get wheelIsEmpty => 'العجلة فارغة';

  @override
  String get addOptionsAbove =>
      'أضف خيارات أعلاه لإنشاء عجلة القرعة الخاصة بك!';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get skip => 'تخطي';

  @override
  String get singleLeg => 'مواجهة واحدة (مباراة)';

  @override
  String get doubleLeg => 'مواجهتان (ذهاب وإياب)';

  @override
  String get editTournament => 'تعديل البطولة';

  @override
  String get editPlayers => 'تعديل اللاعبين';

  @override
  String get playerNames => 'أسماء اللاعبين';

  @override
  String get editPlayerHint => 'تعديل اسم اللاعب';

  @override
  String get tournamentUpdatedSuccess => 'تم تحديث البطولة بنجاح!';

  @override
  String get delete => 'حذف';

  @override
  String get laterResultWarningTitle => 'حذف نتيجة لاحقة؟';

  @override
  String laterResultWarningBody(String round) {
    return 'سيؤدي تغيير هذه النتيجة إلى حذف نتيجة $round وكل الأدوار التي تليها، وسيتعين عليك إدخالها من جديد.';
  }

  @override
  String get laterResultWarningContinue => 'متابعة';

  @override
  String get knockoutDrawNotAllowed =>
      'التعادل غير مسموح في مباريات خروج المغلوب. اختر الفائز بركلات الترجيح.';

  @override
  String get penaltyShootoutWinner => 'الفائز بركلات الترجيح';

  @override
  String get tbd => 'لم يُحدَّد';

  @override
  String get bye => 'راحة';

  @override
  String get notDrafted => 'لم يُسحب بعد';

  @override
  String get currentPlayer => 'اللاعب الحالي';

  @override
  String get currentPlayerSubtitle => 'اختر اللاعب الذي ستدير العجلة له';

  @override
  String get playersStatus => 'حالة اللاعبين';

  @override
  String get roundChip => 'الجولة';

  @override
  String get rouletteUpper => 'القرعة';

  @override
  String get winPts => 'نقاط الفوز';

  @override
  String get drawPts => 'نقاط التعادل';

  @override
  String get lossPts => 'نقاط الخسارة';

  @override
  String couldNotOpenLink(String url) {
    return 'تعذّر فتح $url';
  }

  @override
  String get allDataCleared => 'تم حذف جميع البيانات.';

  @override
  String get tournamentNotFound => 'البطولة غير موجودة.';

  @override
  String get noMatchesYet => 'لم يتم إنشاء أي مباراة بعد.';

  @override
  String get noMatchesInRound => 'لا توجد مباريات في هذه الجولة.';

  @override
  String get noStandings => 'لا يوجد ترتيب متاح.';

  @override
  String get finalRound => 'النهائي';

  @override
  String get semiFinals => 'نصف النهائي';

  @override
  String get quarterFinals => 'ربع النهائي';

  @override
  String roundOf(int count) {
    return 'دور الـ $count';
  }

  @override
  String notEnoughRouletteTeams(int round, String player) {
    return 'لا توجد فرق كافية لسحب الجولة $round للاعب $player. أضف فرقًا أو ألغِ إحدى قواعد عدم التكرار.';
  }

  @override
  String get autoDraftFailed => 'تعذّر إكمال السحب التلقائي.';

  @override
  String rouletteDistinctNeedsMore(int needed, int have) {
    return 'تحتاج إلى $needed فرق على الأقل في إدارة الفرق لتكون القرعة مختلفة في كل الجولات (لديك $have).';
  }

  @override
  String rouletteUniqueNeedsMore(int needed, int have) {
    return 'تحتاج إلى $needed فرق على الأقل في إدارة الفرق ليحصل كل لاعب على فريق مختلف (لديك $have).';
  }

  @override
  String get playerHint => 'اسم اللاعب (مثال: أحمد، يوسف)...';

  @override
  String get teamHint => 'اسم الفريق (مثال: PSG، RMA، FCB)...';

  @override
  String get onboardingTitle1 => 'مرحبًا بك في FIXTURA';

  @override
  String get onboardingBody1 =>
      'نظّم بطولات محلية مع أصدقائك: دوري النقاط، خروج المغلوب والمزيد. كل شيء بدون إنترنت وملكك بالكامل.';

  @override
  String get onboardingTitle2 => 'اللاعبون والفرق';

  @override
  String get onboardingBody2 =>
      'اللاعبون هم الأشخاص الحقيقيون المتنافسون: أنت وأصدقاؤك.\n\nالفرق هي الأندية التي يلعبون بها مثل PSG وريال مدريد وبرشلونة...\n\nأضف لاعبيك أولًا، ثم أنشئ قائمة الفرق.';

  @override
  String get onboardingTitle3 => 'أدر العجلة';

  @override
  String get onboardingBody3 =>
      'لا تستطيعون تحديد من يلعب بأي فريق؟ فعّل قرعة الفرق ودع العجلة تختار.\n\nاختر عدم التكرار حتى لا يحصل لاعبان على الفريق نفسه، أو الاختلاف بين الجولات حتى لا يتكرر فريق لنفس اللاعب.';

  @override
  String get onboardingTitle4 => 'تابع كل مباراة';

  @override
  String get onboardingBody4 =>
      'اضغط على أي مباراة لإدخال النتيجة. يتحدّث الترتيب تلقائيًا: النقاط وفارق الأهداف وكل شيء.\n\nتنقّل بين الجولات من الأزرار في الأعلى.';

  @override
  String get onboardingTitle5 => 'أنت جاهز';

  @override
  String get onboardingBody5 =>
      'أنشئ بطولتك الأولى من الشاشة الرئيسية، أو أدر عجلة سريعة للمتعة.\n\nهيا بنا!';

  @override
  String get groups => 'مجموعات';

  @override
  String get groupsPlusKnockout => '+ خروج المغلوب';

  @override
  String get groupSettings => 'إعدادات دور المجموعات';

  @override
  String get numberOfGroups => 'عدد المجموعات';

  @override
  String get numberOfGroupsSubtitle =>
      'عدد المجموعات التي يُقسَّم إليها اللاعبون';

  @override
  String get qualifiersPerGroup => 'المتأهلون';

  @override
  String get qualifiersPerGroupSubtitle =>
      'عدد المتأهلين من كل مجموعة إلى الأدوار الإقصائية';

  @override
  String groupName(String letter) {
    return 'المجموعة $letter';
  }

  @override
  String get groupStage => 'دور المجموعات';

  @override
  String groupsNeedMorePlayers(int needed, int groups) {
    return 'تحتاج إلى $needed لاعبين على الأقل لـ $groups مجموعات.';
  }

  @override
  String get knockoutWaitingForGroups =>
      'تُملأ الأدوار الإقصائية بعد لعب جميع مباريات المجموعات.';

  @override
  String laterResultWarningGroupBody(String round) {
    return 'تغيير هذه النتيجة يغيّر المتأهلين من المجموعات. سيتم حذف نتائج الأدوار الإقصائية بدءًا من $round وستحتاج إلى إدخالها من جديد.';
  }

  @override
  String get shareResults => 'مشاركة النتائج';

  @override
  String get latestResults => 'آخر النتائج';

  @override
  String get upcomingMatches => 'المباريات القادمة';

  @override
  String championLine(String name) {
    return '🏆 البطل: $name';
  }

  @override
  String get madeWithFixtura => 'صُنع باستخدام Fixtura';

  @override
  String get pointsShort => 'ن';

  @override
  String get dataSection => 'النسخ الاحتياطي';

  @override
  String get exportBackup => 'تصدير نسخة احتياطية';

  @override
  String get exportBackupSubtitle => 'احفظ جميع البطولات في ملف';

  @override
  String get importBackup => 'استيراد نسخة احتياطية';

  @override
  String get importBackupSubtitle => 'استعد البطولات من ملف نسخة احتياطية';

  @override
  String backupImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استيراد $count بطولات.',
      one: 'تم استيراد بطولة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get backupNothingNew => 'كل ما في هذه النسخة موجود بالفعل في التطبيق.';

  @override
  String get backupInvalid => 'هذا الملف ليس نسخة احتياطية صالحة من Fixtura.';

  @override
  String get backupExportFailed => 'تعذّر إنشاء النسخة الاحتياطية.';

  @override
  String get noTournamentsToExport => 'لا توجد بطولات لنسخها بعد.';

  @override
  String get openTournament => 'فتح البطولة';

  @override
  String get resetScore => 'مسح النتيجة';

  @override
  String get saveResult => 'حفظ النتيجة';

  @override
  String get selectedTeam => 'الفريق المختار';
}
