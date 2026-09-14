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
}
