// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FIXTURA';

  @override
  String get appSubtitle => 'Organisez et Gérez\nVos Ligues & Tournois';

  @override
  String get homeTab => 'Accueil';

  @override
  String get tournamentsTab => 'Tournois';

  @override
  String get createTab => 'Créer';

  @override
  String get rouletteTab => 'Roulette';

  @override
  String get quickActions => 'ACTIONS RAPIDES';

  @override
  String get createNewTournament => 'Créer un Nouveau Tournoi';

  @override
  String get quickRouletteSpin => 'Tirage Roulette Rapide';

  @override
  String get lastActiveTournament => 'DERNIER TOURNOI ACTIF';

  @override
  String get tournaments => 'TOURNOIS';

  @override
  String get total => 'Total';

  @override
  String get active => 'En cours';

  @override
  String get finished => 'Terminés';

  @override
  String get all => 'TOUS';

  @override
  String get searchTournaments => 'Rechercher un tournoi...';

  @override
  String get noTournamentsFound => 'Aucun tournoi trouvé';

  @override
  String get createYourFirst => 'Créez votre premier tournoi pour commencer !';

  @override
  String get settingsTitle => 'PARAMÈTRES';

  @override
  String get preferences => 'PRÉFÉRENCES';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Choisir la langue d\'affichage';

  @override
  String get guideAndTutorial => 'GUIDE & TUTORIEL';

  @override
  String get viewAppTutorial => 'Voir le tutoriel';

  @override
  String get replayOnboarding => 'Revoir la présentation en 5 étapes';

  @override
  String get aboutAndSupport => 'À PROPOS & SUPPORT';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyPolicySubtitle =>
      'Lire notre charte de confidentialité hors-ligne';

  @override
  String get contactDeveloper => 'Contacter le développeur';

  @override
  String get contactDeveloperSubtitle => 'Louay Barraq — Retours & assistance';

  @override
  String get rateFixtura => 'Noter Fixtura';

  @override
  String get rateFixturaSubtitle =>
      'Donnez votre avis sur le Google Play Store';

  @override
  String get shareWithFriends => 'Partager avec des amis';

  @override
  String get shareSubtitle =>
      'Invitez vos amis pour des tournois gaming & foot';

  @override
  String get dangerZone => 'ZONE DE DANGER';

  @override
  String get clearAllTournaments => 'Effacer tous les tournois';

  @override
  String get clearAllSubtitle =>
      'Supprimer toutes les données et réinitialiser';

  @override
  String get resetAllDataTitle => 'RÉINITIALISER TOUT';

  @override
  String get resetAllDataContent =>
      'Êtes-vous sûr de vouloir supprimer TOUS les tournois, matchs et données de roulette ? Cette action est irréversible.';

  @override
  String get resetEverything => 'TOUT RÉINITIALISER';

  @override
  String get cancel => 'ANNULER';

  @override
  String get saveChanges => 'ENREGISTRER';

  @override
  String get deleteTournament => 'SUPPRIMER LE TOURNOI';

  @override
  String deleteTournamentConfirm(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ? Cette action ne peut pas être annulée.';
  }

  @override
  String get tournamentName => 'NOM DU TOURNOI';

  @override
  String get tournamentNameHint => 'Entrez le nom du tournoi...';

  @override
  String get format => 'FORMAT';

  @override
  String get league => 'Ligue';

  @override
  String get roundRobin => 'Championnat';

  @override
  String get brackets => 'TABLEAU';

  @override
  String get knockout => 'Élimination';

  @override
  String get leagueSettings => 'RÈGLES DE LA LIGUE';

  @override
  String get legs => 'Aller / Retour';

  @override
  String get legsSubtitle => 'Nombre de confrontations directes';

  @override
  String get pointsSettings => 'BARÈME DE POINTS';

  @override
  String get teamRoulette => 'ROULETTE D\'ÉQUIPES';

  @override
  String get enableTeamRoulette => 'Activer la Roulette d\'Équipes';

  @override
  String get enableRouletteSubtitle =>
      'Attribuer des clubs aléatoires aux joueurs';

  @override
  String get uniqueTeamsOnly => 'Équipes Uniques par Journée';

  @override
  String get uniqueTeamsSubtitle => 'Éviter les équipes en double le même tour';

  @override
  String get distinctTeamsAcrossRounds => 'Équipes Distinctes au Fil des Tours';

  @override
  String get distinctTeamsSubtitle =>
      'Empêcher d\'avoir deux fois le même club';

  @override
  String get managePlayers => 'GÉRER LES JOUEURS';

  @override
  String get manageTeams => 'GÉRER LES ÉQUIPES';

  @override
  String get roulettePool => 'LISTE DES ÉQUIPES';

  @override
  String get fixtures => 'MATCHS';

  @override
  String get standings => 'CLASSEMENT';

  @override
  String get yourLastMatch => 'Dernier Match';

  @override
  String get tournamentStatus => 'Statut du Tournoi';

  @override
  String get tournamentCompleted => 'Tournoi Terminé 🎉';

  @override
  String get noPlayedMatches => 'Aucun match joué';

  @override
  String get waitingForOpponent => 'EN ATTENTE D\'ADVERSAIRE';

  @override
  String round(int num) {
    return 'Tour $num';
  }

  @override
  String get createTournament => 'CRÉER LE TOURNOI';

  @override
  String get pleaseEnterTournamentName => 'Veuillez entrer un nom de tournoi';

  @override
  String get atLeastTwoPlayersRequired =>
      'Vous devez ajouter au moins 2 joueurs dans GÉRER LES JOUEURS.';

  @override
  String get teamPoolEmptyError =>
      'La liste des équipes ne peut pas être vide lorsque la roulette est activée.';

  @override
  String get tournamentCreatedSuccess => 'Tournoi créé avec succès !';

  @override
  String get failedToCreateTournament => 'Échec de la création du tournoi.';

  @override
  String get addOptions => 'AJOUTER DES OPTIONS';

  @override
  String get rouletteWheel => 'ROULETTE';

  @override
  String get wheelIsEmpty => 'La roulette est vide';

  @override
  String get addOptionsAbove =>
      'Ajoutez des options ci-dessus pour générer votre roue personnalisée !';

  @override
  String get next => 'SUIVANT';

  @override
  String get getStarted => 'COMMENCER';

  @override
  String get skip => 'PASSER';

  @override
  String get singleLeg => '1 MATCH (ALLER)';

  @override
  String get doubleLeg => '2 MATCHS (ALLER/RETOUR)';

  @override
  String get editTournament => 'MODIFIER LE TOURNOI';

  @override
  String get editPlayers => 'MODIFIER LES JOUEURS';

  @override
  String get playerNames => 'NOMS DES JOUEURS';

  @override
  String get editPlayerHint => 'Nom du joueur';

  @override
  String get tournamentUpdatedSuccess => 'Tournoi mis à jour avec succès !';

  @override
  String get delete => 'SUPPRIMER';

  @override
  String get laterResultWarningTitle => 'EFFACER UN RÉSULTAT SUIVANT ?';

  @override
  String laterResultWarningBody(String round) {
    return 'Modifier ce score effacera le résultat de : $round, ainsi que des tours suivants. Vous devrez les saisir à nouveau.';
  }

  @override
  String get laterResultWarningContinue => 'CONTINUER';

  @override
  String get knockoutDrawNotAllowed =>
      'Le match nul n\'est pas permis en élimination directe. Choisissez le vainqueur aux tirs au but.';

  @override
  String get penaltyShootoutWinner => 'VAINQUEUR AUX TIRS AU BUT';

  @override
  String get tbd => 'À VENIR';

  @override
  String get bye => 'EXEMPT';

  @override
  String get notDrafted => 'NON TIRÉ';

  @override
  String get currentPlayer => 'Joueur actuel';

  @override
  String get currentPlayerSubtitle =>
      'Choisissez le joueur pour qui tourner la roue';

  @override
  String get playersStatus => 'STATUT DES JOUEURS';

  @override
  String get roundChip => 'TOUR';

  @override
  String get rouletteUpper => 'ROULETTE';

  @override
  String get winPts => 'Pts victoire';

  @override
  String get drawPts => 'Pts nul';

  @override
  String get lossPts => 'Pts défaite';

  @override
  String couldNotOpenLink(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get allDataCleared => 'Toutes les données ont été supprimées.';

  @override
  String get tournamentNotFound => 'Tournoi introuvable.';

  @override
  String get noMatchesYet => 'Aucun match généré pour l\'instant.';

  @override
  String get noMatchesInRound => 'Aucun match dans ce tour.';

  @override
  String get noStandings => 'Aucun classement disponible.';

  @override
  String get finalRound => 'Finale';

  @override
  String get semiFinals => 'Demi-finales';

  @override
  String get quarterFinals => 'Quarts de finale';

  @override
  String roundOf(int count) {
    return 'Tour des $count';
  }

  @override
  String notEnoughRouletteTeams(int round, String player) {
    return 'Pas assez d\'équipes pour le tirage du tour $round de $player. Ajoutez des équipes ou désactivez une règle d\'unicité.';
  }

  @override
  String get autoDraftFailed =>
      'Le tirage automatique n\'a pas pu être terminé.';

  @override
  String rouletteDistinctNeedsMore(int needed, int have) {
    return 'Il faut au moins $needed équipes dans GÉRER LES ÉQUIPES pour des attributions distinctes sur tous les tours (vous en avez $have).';
  }

  @override
  String rouletteUniqueNeedsMore(int needed, int have) {
    return 'Il faut au moins $needed équipes dans GÉRER LES ÉQUIPES pour que chaque joueur ait une équipe unique (vous en avez $have).';
  }

  @override
  String get playerHint => 'Nom du joueur (ex. Karim, Hugo)...';

  @override
  String get teamHint => 'Nom de l\'équipe (ex. PSG, RMA, FCB)...';

  @override
  String get onboardingTitle1 => 'BIENVENUE SUR FIXTURA';

  @override
  String get onboardingBody1 =>
      'Organisez des tournois entre amis : championnats, tableaux à élimination directe et plus encore. Tout hors ligne, tout à vous.';

  @override
  String get onboardingTitle2 => 'JOUEURS & ÉQUIPES';

  @override
  String get onboardingBody2 =>
      'Les joueurs sont les vraies personnes qui s\'affrontent : vous, vos amis.\n\nLes équipes sont les clubs qu\'ils incarnent : PSG, Real Madrid, Barcelone...\n\nAjoutez d\'abord vos joueurs, puis votre liste d\'équipes.';

  @override
  String get onboardingTitle3 => 'TOURNEZ LA ROUE';

  @override
  String get onboardingBody3 =>
      'Impossible de décider qui joue avec quelle équipe ? Activez la roulette et laissez la roue choisir.\n\nActivez l\'unicité pour que deux joueurs n\'aient pas la même équipe, ou la distinction entre tours pour que personne ne la reprenne.';

  @override
  String get onboardingTitle4 => 'SUIVEZ CHAQUE MATCH';

  @override
  String get onboardingBody4 =>
      'Touchez un match pour saisir le score. Le classement se met à jour tout seul : points, différence de buts, tout.\n\nChangez de tour avec les pastilles en haut.';

  @override
  String get onboardingTitle5 => 'C\'EST PARTI';

  @override
  String get onboardingBody5 =>
      'Créez votre premier tournoi depuis l\'accueil, ou lancez une roulette rapide pour le plaisir.\n\nC\'est parti !';

  @override
  String get groups => 'Groupes';

  @override
  String get groupsPlusKnockout => '+ Élimination';

  @override
  String get groupSettings => 'PARAMÈTRES DES GROUPES';

  @override
  String get numberOfGroups => 'Groupes';

  @override
  String get numberOfGroupsSubtitle => 'Nombre de groupes de joueurs';

  @override
  String get qualifiersPerGroup => 'Qualifiés';

  @override
  String get qualifiersPerGroupSubtitle =>
      'Joueurs par groupe qualifiés pour l\'élimination';

  @override
  String groupName(String letter) {
    return 'GROUPE $letter';
  }

  @override
  String get groupStage => 'Phase de groupes';

  @override
  String groupsNeedMorePlayers(int needed, int groups) {
    return 'Il faut au moins $needed joueurs pour $groups groupes.';
  }

  @override
  String get knockoutWaitingForGroups =>
      'Le tableau se remplit quand tous les matchs de groupe sont joués.';

  @override
  String laterResultWarningGroupBody(String round) {
    return 'Ce score change les qualifiés des groupes. Les résultats du tableau à partir des $round seront effacés et devront être ressaisis.';
  }

  @override
  String get shareResults => 'Partager les résultats';

  @override
  String get latestResults => 'DERNIERS RÉSULTATS';

  @override
  String get upcomingMatches => 'À VENIR';

  @override
  String championLine(String name) {
    return '🏆 Champion : $name';
  }

  @override
  String get madeWithFixtura => 'Créé avec Fixtura';

  @override
  String get pointsShort => 'pts';

  @override
  String get dataSection => 'SAUVEGARDE';

  @override
  String get exportBackup => 'Exporter une sauvegarde';

  @override
  String get exportBackupSubtitle =>
      'Enregistrer tous les tournois dans un fichier';

  @override
  String get importBackup => 'Importer une sauvegarde';

  @override
  String get importBackupSubtitle => 'Restaurer des tournois depuis un fichier';

  @override
  String backupImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tournois importés.',
      one: '1 tournoi importé.',
    );
    return '$_temp0';
  }

  @override
  String get backupNothingNew =>
      'Tout le contenu de cette sauvegarde est déjà dans l\'app.';

  @override
  String get backupInvalid =>
      'Ce fichier n\'est pas une sauvegarde Fixtura valide.';

  @override
  String get backupExportFailed => 'Impossible de créer la sauvegarde.';

  @override
  String get noTournamentsToExport =>
      'Aucun tournoi à sauvegarder pour l\'instant.';
}
