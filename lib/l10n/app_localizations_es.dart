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

  @override
  String get createTournament => 'CREAR TORNEO';

  @override
  String get pleaseEnterTournamentName =>
      'Por favor, introduce el nombre del torneo';

  @override
  String get atLeastTwoPlayersRequired =>
      'Necesitas al menos 2 jugadores en GESTIONAR JUGADORES.';

  @override
  String get teamPoolEmptyError =>
      'La lista de equipos no puede estar vacía cuando la ruleta está activada.';

  @override
  String get tournamentCreatedSuccess => '¡Torneo creado con éxito!';

  @override
  String get failedToCreateTournament => 'Error al crear el torneo.';

  @override
  String get addOptions => 'AÑADIR OPCIONES';

  @override
  String get rouletteWheel => 'RULETA';

  @override
  String get wheelIsEmpty => 'La ruleta está vacía';

  @override
  String get addOptionsAbove =>
      '¡Añade opciones arriba para generar tu ruleta personalizada!';

  @override
  String get next => 'SIGUIENTE';

  @override
  String get getStarted => 'EMPEZAR';

  @override
  String get skip => 'OMITIR';

  @override
  String get singleLeg => '1 PARTIDO (IDA)';

  @override
  String get doubleLeg => '2 PARTIDOS (IDA/VUELTA)';

  @override
  String get editTournament => 'EDITAR TORNEO';

  @override
  String get editPlayers => 'EDITAR JUGADORES';

  @override
  String get playerNames => 'NOMBRES DE JUGADORES';

  @override
  String get editPlayerHint => 'Nombre del jugador';

  @override
  String get tournamentUpdatedSuccess => '¡Torneo actualizado con éxito!';

  @override
  String get delete => 'ELIMINAR';

  @override
  String get laterResultWarningTitle => '¿BORRAR UN RESULTADO POSTERIOR?';

  @override
  String laterResultWarningBody(String round) {
    return 'Cambiar este resultado borrará el de: $round, y el de las rondas siguientes. Tendrás que introducirlos de nuevo.';
  }

  @override
  String get laterResultWarningContinue => 'CONTINUAR';

  @override
  String get knockoutDrawNotAllowed =>
      'No se permite el empate en una eliminatoria. Elige al ganador de la tanda de penaltis.';

  @override
  String get penaltyShootoutWinner => 'GANADOR EN LOS PENALTIS';

  @override
  String get tbd => 'POR DEFINIR';

  @override
  String get bye => 'DESCANSA';

  @override
  String get notDrafted => 'SIN SORTEAR';

  @override
  String get currentPlayer => 'Jugador actual';

  @override
  String get currentPlayerSubtitle =>
      'Elige el jugador para el que girar la ruleta';

  @override
  String get playersStatus => 'ESTADO DE LOS JUGADORES';

  @override
  String get roundChip => 'RONDA';

  @override
  String get rouletteUpper => 'RULETA';

  @override
  String get winPts => 'Pts victoria';

  @override
  String get drawPts => 'Pts empate';

  @override
  String get lossPts => 'Pts derrota';

  @override
  String couldNotOpenLink(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get allDataCleared => 'Se han borrado todos los datos.';

  @override
  String get tournamentNotFound => 'Torneo no encontrado.';

  @override
  String get noMatchesYet => 'Aún no se han generado partidos.';

  @override
  String get noMatchesInRound => 'No hay partidos en esta ronda.';

  @override
  String get noStandings => 'No hay clasificación disponible.';

  @override
  String get finalRound => 'Final';

  @override
  String get semiFinals => 'Semifinales';

  @override
  String get quarterFinals => 'Cuartos de final';

  @override
  String roundOf(int count) {
    return 'Ronda de $count';
  }

  @override
  String notEnoughRouletteTeams(int round, String player) {
    return 'No hay suficientes equipos para sortear la ronda $round de $player. Añade equipos o desactiva una regla de unicidad.';
  }

  @override
  String get autoDraftFailed => 'No se pudo completar el sorteo automático.';

  @override
  String rouletteDistinctNeedsMore(int needed, int have) {
    return 'Necesitas al menos $needed equipos en GESTIONAR EQUIPOS para que las asignaciones sean distintas en todas las rondas (tienes $have).';
  }

  @override
  String rouletteUniqueNeedsMore(int needed, int have) {
    return 'Necesitas al menos $needed equipos en GESTIONAR EQUIPOS para que cada jugador tenga un equipo único (tienes $have).';
  }

  @override
  String get playerHint => 'Nombre del jugador (ej. Juan, David)...';

  @override
  String get teamHint => 'Nombre del equipo (ej. PSG, RMA, FCB)...';

  @override
  String get onboardingTitle1 => 'BIENVENIDO A FIXTURA';

  @override
  String get onboardingBody1 =>
      'Organiza torneos locales con tus amigos: ligas, cuadros eliminatorios y más. Todo sin conexión, todo tuyo.';

  @override
  String get onboardingTitle2 => 'JUGADORES Y EQUIPOS';

  @override
  String get onboardingBody2 =>
      'Los jugadores son las personas reales que compiten: tú y tus amigos.\n\nLos equipos son los clubes con los que juegan: PSG, Real Madrid, Barcelona...\n\nAñade primero a tus jugadores y luego tu lista de equipos.';

  @override
  String get onboardingTitle3 => 'GIRA LA RULETA';

  @override
  String get onboardingBody3 =>
      '¿No sabéis quién juega con qué equipo? Activa la ruleta y deja que elija por ti.\n\nActiva la unicidad para que dos jugadores no tengan el mismo equipo, o la distinción entre rondas para que nadie repita.';

  @override
  String get onboardingTitle4 => 'SIGUE CADA PARTIDO';

  @override
  String get onboardingBody4 =>
      'Toca un partido para introducir el resultado. La clasificación se actualiza sola: puntos, diferencia de goles, todo.\n\nCambia de ronda con los botones de arriba.';

  @override
  String get onboardingTitle5 => '¡TODO LISTO!';

  @override
  String get onboardingBody5 =>
      'Crea tu primer torneo desde la pantalla de inicio o gira una ruleta rápida por diversión.\n\n¡Vamos!';

  @override
  String get groups => 'Grupos';

  @override
  String get groupsPlusKnockout => '+ Eliminatoria';

  @override
  String get groupSettings => 'AJUSTES DE LA FASE DE GRUPOS';

  @override
  String get numberOfGroups => 'Grupos';

  @override
  String get numberOfGroupsSubtitle =>
      'En cuántos grupos dividir a los jugadores';

  @override
  String get qualifiersPerGroup => 'Clasificados';

  @override
  String get qualifiersPerGroupSubtitle =>
      'Jugadores por grupo que pasan a la eliminatoria';

  @override
  String groupName(String letter) {
    return 'GRUPO $letter';
  }

  @override
  String get groupStage => 'Fase de grupos';

  @override
  String groupsNeedMorePlayers(int needed, int groups) {
    return 'Necesitas al menos $needed jugadores para $groups grupos.';
  }

  @override
  String get knockoutWaitingForGroups =>
      'El cuadro se completa cuando se jueguen todos los partidos de grupo.';

  @override
  String laterResultWarningGroupBody(String round) {
    return 'Este resultado cambia quién se clasifica de los grupos. Se borrarán los resultados de la eliminatoria desde $round y habrá que volver a introducirlos.';
  }

  @override
  String get shareResults => 'Compartir resultados';

  @override
  String get latestResults => 'ÚLTIMOS RESULTADOS';

  @override
  String get upcomingMatches => 'PRÓXIMOS PARTIDOS';

  @override
  String championLine(String name) {
    return '🏆 Campeón: $name';
  }

  @override
  String get madeWithFixtura => 'Hecho con Fixtura';

  @override
  String get pointsShort => 'pts';

  @override
  String get dataSection => 'COPIA DE SEGURIDAD';

  @override
  String get exportBackup => 'Exportar copia';

  @override
  String get exportBackupSubtitle => 'Guarda todos los torneos en un archivo';

  @override
  String get importBackup => 'Importar copia';

  @override
  String get importBackupSubtitle => 'Restaura torneos desde un archivo';

  @override
  String backupImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count torneos importados.',
      one: '1 torneo importado.',
    );
    return '$_temp0';
  }

  @override
  String get backupNothingNew => 'Todo lo de esta copia ya está en la app.';

  @override
  String get backupInvalid => 'Este archivo no es una copia de Fixtura válida.';

  @override
  String get backupExportFailed => 'No se pudo crear la copia.';

  @override
  String get noTournamentsToExport => 'Todavía no hay torneos que guardar.';
}
