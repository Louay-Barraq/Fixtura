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
}
