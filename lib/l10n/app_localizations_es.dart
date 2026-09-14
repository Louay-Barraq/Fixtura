// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FIXTURA';

  @override
  String get appSubtitle => 'Organiza y Gestiona\nLigas y Torneos Locales';

  @override
  String get homeTab => 'Inicio';

  @override
  String get tournamentsTab => 'Torneos';

  @override
  String get createTab => 'Crear';

  @override
  String get rouletteTab => 'Ruleta';

  @override
  String get quickActions => 'ACCIONES RÁPIDAS';

  @override
  String get createNewTournament => 'Crear Nuevo Torneo';

  @override
  String get quickRouletteSpin => 'Giro de Ruleta Rápido';

  @override
  String get lastActiveTournament => 'ÚLTIMO TORNEO ACTIVO';

  @override
  String get tournaments => 'TORNEOS';

  @override
  String get total => 'Total';

  @override
  String get active => 'Activos';

  @override
  String get finished => 'Finalizados';

  @override
  String get all => 'TODOS';

  @override
  String get searchTournaments => 'Buscar torneos...';

  @override
  String get noTournamentsFound => 'No se encontraron torneos';

  @override
  String get createYourFirst => '¡Crea tu primer torneo para empezar!';

  @override
  String get settingsTitle => 'AJUSTES';

  @override
  String get preferences => 'PREFERENCIAS';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma de visualización';

  @override
  String get guideAndTutorial => 'GUÍA Y TUTORIAL';

  @override
  String get viewAppTutorial => 'Ver Tutorial';

  @override
  String get replayOnboarding => 'Repetir la guía de inicio de 5 pasos';

  @override
  String get aboutAndSupport => 'ACERCA DE Y SOPORTE';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get privacyPolicySubtitle =>
      'Lee nuestra declaración de privacidad sin conexión';

  @override
  String get contactDeveloper => 'Contactar al Desarrollador';

  @override
  String get contactDeveloperSubtitle => 'Louay Barraq — Comentarios y soporte';

  @override
  String get rateFixtura => 'Calificar Fixtura';

  @override
  String get rateFixturaSubtitle => 'Valora la app en Google Play Store';

  @override
  String get shareWithFriends => 'Compartir con Amigos';

  @override
  String get shareSubtitle =>
      'Invita a tus amigos para torneos de juegos y fútbol';

  @override
  String get dangerZone => 'ZONA DE PELIGRO';

  @override
  String get clearAllTournaments => 'Borrar Todos los Torneos';

  @override
  String get clearAllSubtitle =>
      'Eliminar todos los datos guardados y reiniciar';

  @override
  String get resetAllDataTitle => 'RESTABLECER TODOS LOS DATOS';

  @override
  String get resetAllDataContent =>
      '¿Estás seguro de que deseas eliminar TODOS los torneos, partidos y datos de ruleta? Esta acción es irreversible.';

  @override
  String get resetEverything => 'RESTABLECER TODO';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get saveChanges => 'GUARDAR CAMBIOS';

  @override
  String get deleteTournament => 'ELIMINAR TORNEO';

  @override
  String deleteTournamentConfirm(String name) {
    return '¿Estás seguro de que deseas eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get tournamentName => 'NOMBRE DEL TORNEO';

  @override
  String get tournamentNameHint => 'Introduce el nombre del torneo...';

  @override
  String get format => 'FORMATO';

  @override
  String get league => 'Liga';

  @override
  String get roundRobin => 'Todos contra Todos';

  @override
  String get brackets => 'CUADRO';

  @override
  String get knockout => 'Eliminatoria';

  @override
  String get leagueSettings => 'AJUSTES DE LIGA';

  @override
  String get legs => 'Ida y Vuelta';

  @override
  String get legsSubtitle => 'Número de partidos por enfrentamiento';

  @override
  String get pointsSettings => 'SISTEMA DE PUNTOS';

  @override
  String get teamRoulette => 'RULETA DE EQUIPOS';

  @override
  String get enableTeamRoulette => 'Activar Ruleta de Equipos';

  @override
  String get enableRouletteSubtitle =>
      'Asignar clubes aleatorios a los jugadores';

  @override
  String get uniqueTeamsOnly => 'Equipos Únicos por Ronda';

  @override
  String get uniqueTeamsSubtitle =>
      'Evitar asignaciones duplicadas en la misma ronda';

  @override
  String get distinctTeamsAcrossRounds => 'Equipos Distintos entre Rondas';

  @override
  String get distinctTeamsSubtitle =>
      'Evitar recibir el mismo equipo más de una vez';

  @override
  String get managePlayers => 'GESTIONAR JUGADORES';

  @override
  String get manageTeams => 'GESTIONAR EQUIPOS';

  @override
  String get roulettePool => 'LISTA DE EQUIPOS';

  @override
  String get fixtures => 'PARTIDOS';

  @override
  String get standings => 'CLASIFICACIÓN';

  @override
  String get yourLastMatch => 'Tu Último Partido';

  @override
  String get tournamentStatus => 'Estado del Torneo';

  @override
  String get tournamentCompleted => 'Torneo Finalizado 🎉';

  @override
  String get noPlayedMatches => 'Sin partidos jugados aún';

  @override
  String get waitingForOpponent => 'ESPERANDO RIVAL';

  @override
  String round(int num) {
    return 'Ronda $num';
  }
}
