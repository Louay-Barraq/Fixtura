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

  @override
  String get createTournament => 'CREATE TOURNAMENT';

  @override
  String get pleaseEnterTournamentName => 'Please enter a tournament name';

  @override
  String get atLeastTwoPlayersRequired =>
      'You need at least 2 players in MANAGE PLAYERS to create a tournament.';

  @override
  String get teamPoolEmptyError =>
      'The team pool (MANAGE TEAMS) cannot be empty when Team Roulette is enabled.';

  @override
  String get tournamentCreatedSuccess => 'Tournament created successfully!';

  @override
  String get failedToCreateTournament => 'Failed to create tournament.';

  @override
  String get addOptions => 'ADD OPTIONS';

  @override
  String get rouletteWheel => 'ROULETTE WHEEL';

  @override
  String get wheelIsEmpty => 'Wheel is Empty';

  @override
  String get addOptionsAbove =>
      'Add options above to generate your custom wheel!';

  @override
  String get next => 'NEXT';

  @override
  String get getStarted => 'GET STARTED';

  @override
  String get skip => 'SKIP';

  @override
  String get singleLeg => '1 LEG (SINGLE)';

  @override
  String get doubleLeg => '2 LEGS (DOUBLE)';

  @override
  String get editTournament => 'EDIT TOURNAMENT';

  @override
  String get editPlayers => 'EDIT PLAYERS';

  @override
  String get playerNames => 'PLAYER NAMES';

  @override
  String get editPlayerHint => 'Edit player name';

  @override
  String get tournamentUpdatedSuccess => 'Tournament updated successfully!';

  @override
  String get delete => 'DELETE';

  @override
  String get laterResultWarningTitle => 'CLEAR LATER RESULT?';

  @override
  String laterResultWarningBody(String round) {
    return 'Changing this score will clear the result of the $round and any rounds after it. You will need to enter them again.';
  }

  @override
  String get laterResultWarningContinue => 'CONTINUE';

  @override
  String get knockoutDrawNotAllowed =>
      'A draw isn\'t allowed in a knockout match. Pick the penalty shootout winner.';

  @override
  String get penaltyShootoutWinner => 'PENALTY SHOOTOUT WINNER';

  @override
  String get tbd => 'TBD';

  @override
  String get bye => 'BYE';

  @override
  String get notDrafted => 'NOT DRAFTED';

  @override
  String get currentPlayer => 'Current Player';

  @override
  String get currentPlayerSubtitle => 'Select active player to spin for';

  @override
  String get playersStatus => 'PLAYERS STATUS';

  @override
  String get roundChip => 'ROUND';

  @override
  String get rouletteUpper => 'ROULETTE';

  @override
  String get winPts => 'Win Pts';

  @override
  String get drawPts => 'Draw Pts';

  @override
  String get lossPts => 'Loss Pts';

  @override
  String couldNotOpenLink(String url) {
    return 'Could not open $url';
  }

  @override
  String get allDataCleared => 'All data has been cleared.';

  @override
  String get tournamentNotFound => 'Tournament not found.';

  @override
  String get noMatchesYet => 'No matches generated yet.';

  @override
  String get noMatchesInRound => 'No matches in this round.';

  @override
  String get noStandings => 'No standings available.';

  @override
  String get finalRound => 'Final';

  @override
  String get semiFinals => 'Semi-finals';

  @override
  String get quarterFinals => 'Quarter-finals';

  @override
  String roundOf(int count) {
    return 'Round of $count';
  }

  @override
  String notEnoughRouletteTeams(int round, String player) {
    return 'Not enough roulette teams to draft round $round for $player. Add teams to the pool or turn off a uniqueness rule.';
  }

  @override
  String get autoDraftFailed => 'The auto draft couldn\'t be completed.';

  @override
  String rouletteDistinctNeedsMore(int needed, int have) {
    return 'You need at least $needed teams in MANAGE TEAMS to keep assignments distinct across all rounds (you have $have).';
  }

  @override
  String rouletteUniqueNeedsMore(int needed, int have) {
    return 'You need at least $needed teams in MANAGE TEAMS so every player gets a unique team (you have $have).';
  }

  @override
  String get playerHint => 'Enter player name (e.g. John, David)...';

  @override
  String get teamHint => 'Enter team name (e.g. PSG, RMA, FCB)...';

  @override
  String get onboardingTitle1 => 'WELCOME TO FIXTURA';

  @override
  String get onboardingBody1 =>
      'Host and manage local tournaments with your friends: round robin leagues, knockout brackets, and more. All offline, all yours.';

  @override
  String get onboardingTitle2 => 'PLAYERS & TEAMS';

  @override
  String get onboardingBody2 =>
      'Players are the real people competing: you, your friends.\n\nTeams are the clubs they play as like PSG, Real Madrid, Barcelona, ...\n\nAdd your players first, then build your team pool.';

  @override
  String get onboardingTitle3 => 'SPIN THE ROULETTE';

  @override
  String get onboardingBody3 =>
      'Can\'t decide who plays as what? Enable Team Roulette and let the wheel pick for you.\n\nSet it to unique so no two players get the same team, or distinct across rounds so nobody repeats.';

  @override
  String get onboardingTitle4 => 'TRACK EVERY GAME';

  @override
  String get onboardingBody4 =>
      'Tap any match to enter the score. Standings update automatically: the points, the goal difference, everything.\n\nSwitch between rounds using the chips at the top.';

  @override
  String get onboardingTitle5 => 'YOU\'RE ALL SET';

  @override
  String get onboardingBody5 =>
      'Create your first tournament from the home screen, or spin a quick roulette for fun.\n\nLet\'s go!';

  @override
  String get groups => 'Groups';

  @override
  String get groupsPlusKnockout => '+ Knockout';

  @override
  String get groupSettings => 'GROUP STAGE SETTINGS';

  @override
  String get numberOfGroups => 'Groups';

  @override
  String get numberOfGroupsSubtitle => 'How many groups to split players into';

  @override
  String get qualifiersPerGroup => 'Qualifiers';

  @override
  String get qualifiersPerGroupSubtitle =>
      'Players per group who reach the knockouts';

  @override
  String groupName(String letter) {
    return 'GROUP $letter';
  }

  @override
  String get groupStage => 'Group stage';

  @override
  String groupsNeedMorePlayers(int needed, int groups) {
    return 'You need at least $needed players for $groups groups.';
  }

  @override
  String get knockoutWaitingForGroups =>
      'Knockout spots fill in once every group match is played.';

  @override
  String laterResultWarningGroupBody(String round) {
    return 'Changing this score changes who qualifies from the groups. Knockout results from the $round onward will be cleared and need to be entered again.';
  }

  @override
  String get shareResults => 'Share results';

  @override
  String get latestResults => 'LATEST RESULTS';

  @override
  String get upcomingMatches => 'UP NEXT';

  @override
  String championLine(String name) {
    return '🏆 Champion: $name';
  }

  @override
  String get madeWithFixtura => 'Made with Fixtura';

  @override
  String get pointsShort => 'pts';

  @override
  String get dataSection => 'BACKUP';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get exportBackupSubtitle => 'Save every tournament to a file';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get importBackupSubtitle => 'Restore tournaments from a backup file';

  @override
  String backupImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tournaments imported.',
      one: '1 tournament imported.',
    );
    return '$_temp0';
  }

  @override
  String get backupNothingNew =>
      'Everything in this backup is already in the app.';

  @override
  String get backupInvalid => 'This file isn\'t a valid Fixtura backup.';

  @override
  String get backupExportFailed => 'Couldn\'t create the backup.';

  @override
  String get noTournamentsToExport =>
      'There are no tournaments to back up yet.';

  @override
  String get openTournament => 'Open Tournament';

  @override
  String get resetScore => 'RESET SCORE';

  @override
  String get saveResult => 'SAVE RESULT';

  @override
  String get selectedTeam => 'SELECTED TEAM';
}
