import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FIXTURA'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Host & Manage\nLocal Leagues & Brackets'**
  String get appSubtitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @tournamentsTab.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tournamentsTab;

  /// No description provided for @createTab.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createTab;

  /// No description provided for @rouletteTab.
  ///
  /// In en, this message translates to:
  /// **'Roulette'**
  String get rouletteTab;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActions;

  /// No description provided for @createNewTournament.
  ///
  /// In en, this message translates to:
  /// **'Create New Tournament'**
  String get createNewTournament;

  /// No description provided for @quickRouletteSpin.
  ///
  /// In en, this message translates to:
  /// **'Quick Roulette Spin'**
  String get quickRouletteSpin;

  /// No description provided for @lastActiveTournament.
  ///
  /// In en, this message translates to:
  /// **'LAST ACTIVE TOURNAMENT'**
  String get lastActiveTournament;

  /// No description provided for @tournaments.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENTS'**
  String get tournaments;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get all;

  /// No description provided for @searchTournaments.
  ///
  /// In en, this message translates to:
  /// **'Search tournaments...'**
  String get searchTournaments;

  /// No description provided for @noTournamentsFound.
  ///
  /// In en, this message translates to:
  /// **'No tournaments found'**
  String get noTournamentsFound;

  /// No description provided for @createYourFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first tournament to get started!'**
  String get createYourFirst;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select display language'**
  String get selectLanguage;

  /// No description provided for @guideAndTutorial.
  ///
  /// In en, this message translates to:
  /// **'GUIDE & TUTORIAL'**
  String get guideAndTutorial;

  /// No description provided for @viewAppTutorial.
  ///
  /// In en, this message translates to:
  /// **'View App Tutorial'**
  String get viewAppTutorial;

  /// No description provided for @replayOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Replay the 5-step onboarding walkthrough'**
  String get replayOnboarding;

  /// No description provided for @aboutAndSupport.
  ///
  /// In en, this message translates to:
  /// **'ABOUT & SUPPORT'**
  String get aboutAndSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our offline privacy statement'**
  String get privacyPolicySubtitle;

  /// No description provided for @contactDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Contact Developer'**
  String get contactDeveloper;

  /// No description provided for @contactDeveloperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Louay Barraq — Feedback & support'**
  String get contactDeveloperSubtitle;

  /// No description provided for @rateFixtura.
  ///
  /// In en, this message translates to:
  /// **'Rate Fixtura'**
  String get rateFixtura;

  /// No description provided for @rateFixturaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the app on Google Play Store'**
  String get rateFixturaSubtitle;

  /// No description provided for @shareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriends;

  /// No description provided for @shareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends for gaming & football tournaments'**
  String get shareSubtitle;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get dangerZone;

  /// No description provided for @clearAllTournaments.
  ///
  /// In en, this message translates to:
  /// **'Clear All Tournaments'**
  String get clearAllTournaments;

  /// No description provided for @clearAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved data and reset the app'**
  String get clearAllSubtitle;

  /// No description provided for @resetAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'RESET ALL DATA'**
  String get resetAllDataTitle;

  /// No description provided for @resetAllDataContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete ALL tournaments, matches, and roulette data? This action is irreversible.'**
  String get resetAllDataContent;

  /// No description provided for @resetEverything.
  ///
  /// In en, this message translates to:
  /// **'RESET EVERYTHING'**
  String get resetEverything;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @deleteTournament.
  ///
  /// In en, this message translates to:
  /// **'DELETE TOURNAMENT'**
  String get deleteTournament;

  /// No description provided for @deleteTournamentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteTournamentConfirm(String name);

  /// No description provided for @tournamentName.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT NAME'**
  String get tournamentName;

  /// No description provided for @tournamentNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter tournament name...'**
  String get tournamentNameHint;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'FORMAT'**
  String get format;

  /// No description provided for @league.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get league;

  /// No description provided for @roundRobin.
  ///
  /// In en, this message translates to:
  /// **'Round-Robin'**
  String get roundRobin;

  /// No description provided for @brackets.
  ///
  /// In en, this message translates to:
  /// **'BRACKETS'**
  String get brackets;

  /// No description provided for @knockout.
  ///
  /// In en, this message translates to:
  /// **'Knockout'**
  String get knockout;

  /// No description provided for @leagueSettings.
  ///
  /// In en, this message translates to:
  /// **'LEAGUE SETTINGS'**
  String get leagueSettings;

  /// No description provided for @legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// No description provided for @legsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Number of matches per pair'**
  String get legsSubtitle;

  /// No description provided for @pointsSettings.
  ///
  /// In en, this message translates to:
  /// **'POINTS SETTINGS'**
  String get pointsSettings;

  /// No description provided for @teamRoulette.
  ///
  /// In en, this message translates to:
  /// **'TEAM ROULETTE'**
  String get teamRoulette;

  /// No description provided for @enableTeamRoulette.
  ///
  /// In en, this message translates to:
  /// **'Enable Team Roulette'**
  String get enableTeamRoulette;

  /// No description provided for @enableRouletteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign random clubs to players'**
  String get enableRouletteSubtitle;

  /// No description provided for @uniqueTeamsOnly.
  ///
  /// In en, this message translates to:
  /// **'Unique Teams Only'**
  String get uniqueTeamsOnly;

  /// No description provided for @uniqueTeamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent duplicate team assignments'**
  String get uniqueTeamsSubtitle;

  /// No description provided for @distinctTeamsAcrossRounds.
  ///
  /// In en, this message translates to:
  /// **'Distinct Teams Across Rounds'**
  String get distinctTeamsAcrossRounds;

  /// No description provided for @distinctTeamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent getting the same team twice'**
  String get distinctTeamsSubtitle;

  /// No description provided for @managePlayers.
  ///
  /// In en, this message translates to:
  /// **'MANAGE PLAYERS'**
  String get managePlayers;

  /// No description provided for @manageTeams.
  ///
  /// In en, this message translates to:
  /// **'MANAGE TEAMS'**
  String get manageTeams;

  /// No description provided for @roulettePool.
  ///
  /// In en, this message translates to:
  /// **'ROULETTE POOL'**
  String get roulettePool;

  /// No description provided for @fixtures.
  ///
  /// In en, this message translates to:
  /// **'FIXTURES'**
  String get fixtures;

  /// No description provided for @standings.
  ///
  /// In en, this message translates to:
  /// **'STANDINGS'**
  String get standings;

  /// No description provided for @yourLastMatch.
  ///
  /// In en, this message translates to:
  /// **'Your Last Match'**
  String get yourLastMatch;

  /// No description provided for @tournamentStatus.
  ///
  /// In en, this message translates to:
  /// **'Tournament Status'**
  String get tournamentStatus;

  /// No description provided for @tournamentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tournament Completed 🎉'**
  String get tournamentCompleted;

  /// No description provided for @noPlayedMatches.
  ///
  /// In en, this message translates to:
  /// **'No played matches yet'**
  String get noPlayedMatches;

  /// No description provided for @waitingForOpponent.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR OPPONENT'**
  String get waitingForOpponent;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round {num}'**
  String round(int num);

  /// No description provided for @createTournament.
  ///
  /// In en, this message translates to:
  /// **'CREATE TOURNAMENT'**
  String get createTournament;

  /// No description provided for @pleaseEnterTournamentName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a tournament name'**
  String get pleaseEnterTournamentName;

  /// No description provided for @atLeastTwoPlayersRequired.
  ///
  /// In en, this message translates to:
  /// **'You need at least 2 players in MANAGE PLAYERS to create a tournament.'**
  String get atLeastTwoPlayersRequired;

  /// No description provided for @teamPoolEmptyError.
  ///
  /// In en, this message translates to:
  /// **'The team pool (MANAGE TEAMS) cannot be empty when Team Roulette is enabled.'**
  String get teamPoolEmptyError;

  /// No description provided for @tournamentCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tournament created successfully!'**
  String get tournamentCreatedSuccess;

  /// No description provided for @failedToCreateTournament.
  ///
  /// In en, this message translates to:
  /// **'Failed to create tournament.'**
  String get failedToCreateTournament;

  /// No description provided for @addOptions.
  ///
  /// In en, this message translates to:
  /// **'ADD OPTIONS'**
  String get addOptions;

  /// No description provided for @rouletteWheel.
  ///
  /// In en, this message translates to:
  /// **'ROULETTE WHEEL'**
  String get rouletteWheel;

  /// No description provided for @wheelIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Wheel is Empty'**
  String get wheelIsEmpty;

  /// No description provided for @addOptionsAbove.
  ///
  /// In en, this message translates to:
  /// **'Add options above to generate your custom wheel!'**
  String get addOptionsAbove;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @singleLeg.
  ///
  /// In en, this message translates to:
  /// **'1 LEG (SINGLE)'**
  String get singleLeg;

  /// No description provided for @doubleLeg.
  ///
  /// In en, this message translates to:
  /// **'2 LEGS (DOUBLE)'**
  String get doubleLeg;

  /// No description provided for @editTournament.
  ///
  /// In en, this message translates to:
  /// **'EDIT TOURNAMENT'**
  String get editTournament;

  /// No description provided for @editPlayers.
  ///
  /// In en, this message translates to:
  /// **'EDIT PLAYERS'**
  String get editPlayers;

  /// No description provided for @playerNames.
  ///
  /// In en, this message translates to:
  /// **'PLAYER NAMES'**
  String get playerNames;

  /// No description provided for @editPlayerHint.
  ///
  /// In en, this message translates to:
  /// **'Edit player name'**
  String get editPlayerHint;

  /// No description provided for @tournamentUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tournament updated successfully!'**
  String get tournamentUpdatedSuccess;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
