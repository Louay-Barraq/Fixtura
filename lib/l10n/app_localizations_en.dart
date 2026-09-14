// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FIXTURA';

  @override
  String get appSubtitle => 'Host & Manage\nLocal Leagues & Brackets';

  @override
  String get homeTab => 'Home';

  @override
  String get tournamentsTab => 'Tournaments';

  @override
  String get createTab => 'Create';

  @override
  String get rouletteTab => 'Roulette';

  @override
  String get quickActions => 'QUICK ACTIONS';

  @override
  String get createNewTournament => 'Create New Tournament';

  @override
  String get quickRouletteSpin => 'Quick Roulette Spin';

  @override
  String get lastActiveTournament => 'LAST ACTIVE TOURNAMENT';

  @override
  String get tournaments => 'TOURNAMENTS';

  @override
  String get total => 'Total';

  @override
  String get active => 'Active';

  @override
  String get finished => 'Finished';

  @override
  String get all => 'ALL';

  @override
  String get searchTournaments => 'Search tournaments...';

  @override
  String get noTournamentsFound => 'No tournaments found';

  @override
  String get createYourFirst => 'Create your first tournament to get started!';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select display language';

  @override
  String get guideAndTutorial => 'GUIDE & TUTORIAL';

  @override
  String get viewAppTutorial => 'View App Tutorial';

  @override
  String get replayOnboarding => 'Replay the 5-step onboarding walkthrough';

  @override
  String get aboutAndSupport => 'ABOUT & SUPPORT';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our offline privacy statement';

  @override
  String get contactDeveloper => 'Contact Developer';

  @override
  String get contactDeveloperSubtitle => 'Louay Barraq — Feedback & support';

  @override
  String get rateFixtura => 'Rate Fixtura';

  @override
  String get rateFixturaSubtitle => 'Review the app on Google Play Store';

  @override
  String get shareWithFriends => 'Share with Friends';

  @override
  String get shareSubtitle =>
      'Invite friends for gaming & football tournaments';

  @override
  String get dangerZone => 'DANGER ZONE';

  @override
  String get clearAllTournaments => 'Clear All Tournaments';

  @override
  String get clearAllSubtitle => 'Delete all saved data and reset the app';

  @override
  String get resetAllDataTitle => 'RESET ALL DATA';

  @override
  String get resetAllDataContent =>
      'Are you sure you want to delete ALL tournaments, matches, and roulette data? This action is irreversible.';

  @override
  String get resetEverything => 'RESET EVERYTHING';

  @override
  String get cancel => 'CANCEL';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get deleteTournament => 'DELETE TOURNAMENT';

  @override
  String deleteTournamentConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get tournamentName => 'TOURNAMENT NAME';

  @override
  String get tournamentNameHint => 'Enter tournament name...';

  @override
  String get format => 'FORMAT';

  @override
  String get league => 'League';

  @override
  String get roundRobin => 'Round-Robin';

  @override
  String get brackets => 'BRACKETS';

  @override
  String get knockout => 'Knockout';

  @override
  String get leagueSettings => 'LEAGUE SETTINGS';

  @override
  String get legs => 'Legs';

  @override
  String get legsSubtitle => 'Number of matches per pair';

  @override
  String get pointsSettings => 'POINTS SETTINGS';

  @override
  String get teamRoulette => 'TEAM ROULETTE';

  @override
  String get enableTeamRoulette => 'Enable Team Roulette';

  @override
  String get enableRouletteSubtitle => 'Assign random clubs to players';

  @override
  String get uniqueTeamsOnly => 'Unique Teams Only';

  @override
  String get uniqueTeamsSubtitle => 'Prevent duplicate team assignments';

  @override
  String get distinctTeamsAcrossRounds => 'Distinct Teams Across Rounds';

  @override
  String get distinctTeamsSubtitle => 'Prevent getting the same team twice';

  @override
  String get managePlayers => 'MANAGE PLAYERS';

  @override
  String get manageTeams => 'MANAGE TEAMS';

  @override
  String get roulettePool => 'ROULETTE POOL';

  @override
  String get fixtures => 'FIXTURES';

  @override
  String get standings => 'STANDINGS';

  @override
  String get yourLastMatch => 'Your Last Match';

  @override
  String get tournamentStatus => 'Tournament Status';

  @override
  String get tournamentCompleted => 'Tournament Completed 🎉';

  @override
  String get noPlayedMatches => 'No played matches yet';

  @override
  String get waitingForOpponent => 'WAITING FOR OPPONENT';

  @override
  String round(int num) {
    return 'Round $num';
  }
}
