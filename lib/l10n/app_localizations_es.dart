// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'Reintentar';

  @override
  String get tryAgain => 'Volver a intentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get goBack => 'Volver';

  @override
  String get backToLists => 'Volver a las listas';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get options => 'Opciones';

  @override
  String get clear => 'Borrar';

  @override
  String get play => 'Reproducir';

  @override
  String get liveBadge => 'EN VIVO';

  @override
  String get nowBadge => 'AHORA';

  @override
  String get nextLabel => 'DESPUÉS';

  @override
  String get schedule => 'Guía de TV';

  @override
  String get favoritePackages => 'Paquetes favoritos';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get searchCategories => 'Buscar categorías';

  @override
  String get noMatchingCategory => 'Ninguna categoría coincide';

  @override
  String get addToFavoritePackages => 'Añadir a paquetes favoritos';

  @override
  String get removeFromFavoritePackages => 'Quitar de paquetes favoritos';

  @override
  String get changeSearchOrCategory => 'Cambia la búsqueda o la categoría.';

  @override
  String get scrollBack => 'Desplazar atrás';

  @override
  String get scrollForward => 'Desplazar adelante';

  @override
  String get muteShortcut => 'Silenciar (M)';

  @override
  String get unmuteShortcut => 'Activar sonido (M)';

  @override
  String get ungrouped => 'Sin grupo';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString canales',
      one: '1 canal',
    );
    return '$_temp0';
  }

  @override
  String movieCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString películas',
      one: '1 película',
    );
    return '$_temp0';
  }

  @override
  String seriesCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString series',
      one: '1 serie',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas',
      one: '1 lista',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temporadas',
      one: '1 temporada',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Vence el $date';
  }

  @override
  String get expired => 'Vencida';

  @override
  String minutesLeft(int minutes) {
    return 'Quedan $minutes min';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get sectionHome => 'Inicio';

  @override
  String get sectionLive => 'TV en vivo';

  @override
  String get sectionMovies => 'Películas';

  @override
  String get sectionSeries => 'Series';

  @override
  String get sectionSearch => 'Buscar';

  @override
  String get sectionLists => 'Listas';

  @override
  String get sectionSettings => 'Ajustes';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingDay => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get greetingNight => 'Buenas noches';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName está lista. Abre un canal o elige una película; lo que veas aparecerá aquí.';
  }

  @override
  String get homeIntro => 'Continúa donde lo dejaste o descubre algo nuevo.';

  @override
  String get continueWatching => 'Seguir viendo';

  @override
  String get recentChannels => 'Canales vistos recientemente';

  @override
  String get searchShortcutAll => 'Canales, películas, series';

  @override
  String get searchShortcutChannels => 'En canales';

  @override
  String maxSlotsReached(int max) {
    return 'Puedes ver hasta $max canales a la vez';
  }

  @override
  String maxSlotsShort(int max) {
    return 'Hasta $max canales';
  }

  @override
  String get watchSideBySide => 'Ver lado a lado';

  @override
  String get epgUpdating => 'Actualizando la guía';

  @override
  String get epgFailed => 'No se pudo cargar la guía';

  @override
  String get allChannels => 'Todos los canales';

  @override
  String get recentlyWatched => 'Vistos recientemente';

  @override
  String get searchChannels => 'Buscar canales';

  @override
  String get noRecentChannelsTitle => 'Aún no has visto canales';

  @override
  String get noRecentChannelsMessage => 'Los canales que veas aparecerán aquí.';

  @override
  String get noChannelFound => 'No se encontraron canales';

  @override
  String get pickChannelTitle => 'Elige un canal';

  @override
  String get pickChannelMessage =>
      'Haz clic en un canal de la lista. Clic derecho para más opciones, o + en la fila del canal para verlo lado a lado.';

  @override
  String get hintChangeChannel => 'Cambiar de canal';

  @override
  String get hintPreviousChannel => 'Canal anterior';

  @override
  String get hintMute => 'Silenciar / activar';

  @override
  String get hintFullscreen => 'Pantalla completa';

  @override
  String get audioInThisTile => 'Sonido en este recuadro';

  @override
  String get muted => 'Silenciado';

  @override
  String get backToGrid => 'Volver a la cuadrícula';

  @override
  String get enlarge => 'Ampliar';

  @override
  String get closeTile => 'Cerrar recuadro';

  @override
  String reconnecting(int attempt, int max) {
    return 'La emisión se detuvo, reconectando ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'No se pudo abrir el canal';

  @override
  String get channelFailedMessage =>
      'El proveedor no está enviando la emisión o se alcanzó el límite de conexiones.';

  @override
  String get listFailedTitle => 'No se pudo abrir la lista';

  @override
  String get loadingChannels => 'Cargando la lista de canales…';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get yesterday => 'Ayer';

  @override
  String archiveHint(int days) {
    return 'Disponibles los últimos $days días, haz clic en un programa';
  }

  @override
  String get noProgrammes => 'No hay programas para este canal';

  @override
  String get watchFromStart => 'Ver desde el inicio';

  @override
  String get watchFromArchive => 'Ver del archivo';

  @override
  String get searchHintAll => 'Buscar canales, películas o series';

  @override
  String get searchPromptTitle => '¿Qué quieres ver?';

  @override
  String get searchPromptChannels =>
      'Escribe al menos dos letras para buscar canales.';

  @override
  String get searchPromptAll =>
      'Escribe al menos dos letras para buscar en canales, películas y series a la vez.';

  @override
  String get channels => 'Canales';

  @override
  String loadingSection(String section) {
    return 'Cargando $section…';
  }

  @override
  String get noResultsTitle => 'Sin resultados';

  @override
  String get noResultsMessage => 'Prueba con otra forma de escribirlo.';

  @override
  String get addList => 'Añadir lista';

  @override
  String get editList => 'Editar lista';

  @override
  String get listNameOptional => 'Nombre de la lista (opcional)';

  @override
  String get listNameHint => 'p. ej. Casa, Paquete deportivo';

  @override
  String get serverAddress => 'Dirección del servidor';

  @override
  String get serverAddressHint =>
      'http://servidor:8080 o el enlace M3U de tu proveedor';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get m3uLocation => 'Lista M3U (URL o ruta de archivo)';

  @override
  String get add => 'Añadir';

  @override
  String get save => 'Guardar';

  @override
  String get errServerAndUserRequired =>
      'Se necesitan la dirección del servidor y el usuario.';

  @override
  String get errLocationRequired =>
      'Se necesita una URL de lista o una ruta de archivo.';

  @override
  String errDuplicateList(String name) {
    return 'Esta lista ya está añadida: «$name».';
  }

  @override
  String get deleteListTitle => '¿Eliminar la lista?';

  @override
  String deleteListMessage(String name) {
    return 'Se eliminarán «$name», sus paquetes favoritos y su historial. Tu cuenta con el proveedor no se verá afectada.';
  }

  @override
  String get yourLists => 'Tus listas';

  @override
  String get welcomeTitle => 'Te damos la bienvenida a Streamlity';

  @override
  String get welcomeMessage =>
      'Añade una lista para empezar. Puedes añadir todas las listas que quieras y cambiar entre ellas.';

  @override
  String get xtreamDescription =>
      'Servidor, usuario y contraseña. TV en vivo, películas, series.';

  @override
  String get m3uDescription => 'Una URL de lista o un archivo de tu ordenador.';

  @override
  String get notOpenedYet => 'Aún no abierta';

  @override
  String get audioLanguage => 'Idioma del audio';

  @override
  String get subtitles => 'Subtítulos';

  @override
  String get subtitlesOff => 'Desactivados';

  @override
  String trackNumber(String id) {
    return 'Pista $id';
  }

  @override
  String get sortProvider => 'Orden del proveedor';

  @override
  String get sortName => 'Por nombre';

  @override
  String get sortRating => 'Por valoración';

  @override
  String get sortYear => 'Por año';

  @override
  String get moviesFailed => 'No se pudieron cargar las películas';

  @override
  String get seriesFailed => 'No se pudieron cargar las series';

  @override
  String get allMovies => 'Todas las películas';

  @override
  String get allSeries => 'Todas las series';

  @override
  String get searchMovies => 'Buscar películas';

  @override
  String get searchSeries => 'Buscar series';

  @override
  String get noMatchingMovies => 'Ninguna película coincide';

  @override
  String get noMatchingSeries => 'Ninguna serie coincide';

  @override
  String get loadingMovies => 'Cargando películas…';

  @override
  String get loadingSeries => 'Cargando series…';

  @override
  String get noDescription => 'Sin descripción.';

  @override
  String get director => 'Dirección';

  @override
  String get cast => 'Reparto';

  @override
  String resumeAt(String position) {
    return 'Continuar · $position';
  }

  @override
  String get startOver => 'Empezar de nuevo';

  @override
  String get seriesInfoFailed =>
      'No se pudieron cargar los detalles de la serie';

  @override
  String get noEpisodes => 'Esta serie no tiene episodios';

  @override
  String seasonTab(int season, int count) {
    return 'Temporada $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'Temporada $season, episodio $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'T$season E$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · Reproducir';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · Continuar';
  }

  @override
  String episodeFallback(int number) {
    return 'Episodio $number';
  }

  @override
  String get watched => 'Visto';

  @override
  String watchedUntil(String position) {
    return 'Visto hasta $position';
  }

  @override
  String get playbackFailed => 'No se pudo reproducir';

  @override
  String errHttpStatus(int code) {
    return 'El servidor respondió $code.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'No se pudo cargar la lista: $detail';
  }

  @override
  String get errNoChannels => 'No se encontraron canales en la lista.';

  @override
  String get errNoLiveChannels =>
      'No se encontraron canales en vivo en la cuenta.';

  @override
  String get errBadLogin => 'Usuario o contraseña incorrectos.';

  @override
  String errAccountUnavailable(String status) {
    return 'Cuenta no disponible (estado: $status).';
  }

  @override
  String errConnect(String detail) {
    return 'No se pudo conectar con el servidor: $detail';
  }

  @override
  String get errInvalidResponse =>
      'El servidor no devolvió una respuesta válida de Xtream Codes.';

  @override
  String get errNoMovies => 'No se encontraron películas en la cuenta.';

  @override
  String get errNoSeries => 'No se encontraron series en la cuenta.';

  @override
  String errEpg(String detail) {
    return 'No se pudo cargar la guía: $detail';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle =>
      'Idioma de la interfaz de la aplicación';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String systemLanguageCurrent(String language) {
    return 'Ahora: $language';
  }

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutText =>
      'Reproductor IPTV de código abierto para Windows, macOS y Linux.';

  @override
  String get translationNote =>
      'Las traducciones se prepararon automáticamente; avísanos si ves algún error.';

  @override
  String get editCategories => 'Editar categorías';

  @override
  String get editCategoriesHint =>
      'Arrastra para ordenar; usa el ojo para ocultar y el candado para pedir el PIN.';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ocultas',
      one: '1 oculta',
      zero: 'Ninguna categoría oculta',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'Ocultar coincidencias ($count)';
  }

  @override
  String showMatching(int count) {
    return 'Mostrar coincidencias ($count)';
  }

  @override
  String get moveToTop => 'Mover arriba del todo';

  @override
  String get hideCategory => 'Ocultar';

  @override
  String get showCategory => 'Mostrar';

  @override
  String get reset => 'Restablecer';

  @override
  String get dragToReorder => 'Arrastra para ordenar';

  @override
  String lockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bloqueadas',
      one: '1 bloqueada',
    );
    return '$_temp0';
  }

  @override
  String get lockCategory => 'Bloquear';

  @override
  String get unlockCategory => 'Quitar bloqueo';

  @override
  String get lockedCategory => 'Categoría bloqueada';

  @override
  String get confirm => 'Aceptar';

  @override
  String get pinEnterTitle => 'Introduce el PIN';

  @override
  String get pinWrong => 'PIN incorrecto';

  @override
  String get pinUnlockMessage =>
      'Esta categoría está bloqueada. Al introducir el PIN, todas las categorías bloqueadas quedan abiertas hasta que cierres la aplicación.';

  @override
  String get pinEditorMessage =>
      'Se necesita el PIN para cambiar la disposición de las categorías.';

  @override
  String get pinCurrentMessage => 'Introduce tu PIN actual para continuar.';

  @override
  String get pinRemoveMessage => 'Introduce tu PIN actual para quitarlo.';

  @override
  String get pinNewTitle => 'Nuevo PIN';

  @override
  String get pinNewMessage =>
      'Elige un PIN de 4 dígitos para abrir las categorías bloqueadas.';

  @override
  String get pinConfirmTitle => 'Confirma el PIN';

  @override
  String get pinConfirmMessage => 'Introduce el mismo PIN otra vez.';

  @override
  String get pinMismatch => 'Los PIN no coinciden';

  @override
  String get pinSaved => 'PIN guardado';

  @override
  String get pinRemoved =>
      'Se quitaron el PIN y todos los bloqueos de categorías';

  @override
  String get locksClosed => 'Las categorías bloqueadas se volvieron a bloquear';

  @override
  String get parentalControl => 'Control parental';

  @override
  String get parentalControlSubtitle =>
      'Las categorías bloqueadas no se abren sin el PIN y sus canales no aparecen en la búsqueda ni en la página de inicio.';

  @override
  String get setPin => 'Establecer PIN';

  @override
  String get setPinDetail =>
      'Después bloquea categorías con el candado del editor de categorías.';

  @override
  String get lockNow => 'Volver a bloquear ahora';

  @override
  String get lockNowDetail =>
      'Las categorías bloqueadas abiertas en esta sesión volverán a pedir el PIN.';

  @override
  String get changePin => 'Cambiar PIN';

  @override
  String get removePin => 'Quitar PIN';

  @override
  String get removePinDetail =>
      'También se quitan todos los bloqueos de categorías.';

  @override
  String get searchFilterAll => 'Todo';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get fullscreenGrid => 'Pantalla completa (F)';

  @override
  String get exitFullscreenGrid => 'Salir de pantalla completa (Esc)';
}
