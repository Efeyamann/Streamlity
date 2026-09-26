// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get tryAgain => 'Wiederholen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get goBack => 'Zurückgehen';

  @override
  String get backToLists => 'Zurück zu den Listen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get options => 'Optionen';

  @override
  String get clear => 'Leeren';

  @override
  String get play => 'Abspielen';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get nowBadge => 'JETZT';

  @override
  String get nextLabel => 'DANACH';

  @override
  String get schedule => 'Programm';

  @override
  String get favoritePackages => 'Lieblingspakete';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get searchCategories => 'Kategorien suchen';

  @override
  String get noMatchingCategory => 'Keine passende Kategorie';

  @override
  String get addToFavoritePackages => 'Zu Lieblingspaketen hinzufügen';

  @override
  String get removeFromFavoritePackages => 'Aus Lieblingspaketen entfernen';

  @override
  String get changeSearchOrCategory => 'Ändere die Suche oder die Kategorie.';

  @override
  String get scrollBack => 'Zurückscrollen';

  @override
  String get scrollForward => 'Weiterscrollen';

  @override
  String get muteShortcut => 'Stumm (M)';

  @override
  String get unmuteShortcut => 'Ton an (M)';

  @override
  String get ungrouped => 'Ohne Gruppe';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Sender',
      one: '1 Sender',
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
      other: '$countString Filme',
      one: '1 Film',
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
      other: '$countString Serien',
      one: '1 Serie',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Listen',
      one: '1 Liste',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Staffeln',
      one: '1 Staffel',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Läuft ab am $date';
  }

  @override
  String get expired => 'Abgelaufen';

  @override
  String minutesLeft(int minutes) {
    return 'noch $minutes Min.';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get sectionHome => 'Start';

  @override
  String get sectionLive => 'Live-TV';

  @override
  String get sectionMovies => 'Filme';

  @override
  String get sectionSeries => 'Serien';

  @override
  String get sectionSearch => 'Suche';

  @override
  String get sectionLists => 'Listen';

  @override
  String get sectionSettings => 'Einstellungen';

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingDay => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get greetingNight => 'Gute Nacht';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName ist bereit. Öffne einen Sender oder wähle einen Film – was du schaust, erscheint hier.';
  }

  @override
  String get homeIntro =>
      'Mach dort weiter, wo du aufgehört hast, oder entdecke etwas Neues.';

  @override
  String get continueWatching => 'Weiterschauen';

  @override
  String get recentChannels => 'Zuletzt gesehene Sender';

  @override
  String get searchShortcutAll => 'Sender, Filme, Serien';

  @override
  String get searchShortcutChannels => 'In Sendern';

  @override
  String maxSlotsReached(int max) {
    return 'Du kannst bis zu $max Sender gleichzeitig ansehen';
  }

  @override
  String maxSlotsShort(int max) {
    return 'Bis zu $max Sender';
  }

  @override
  String get watchSideBySide => 'Nebeneinander ansehen';

  @override
  String get epgUpdating => 'Programm wird aktualisiert';

  @override
  String get epgFailed => 'Programm konnte nicht geladen werden';

  @override
  String get allChannels => 'Alle Sender';

  @override
  String get recentlyWatched => 'Zuletzt gesehen';

  @override
  String get searchChannels => 'Sender suchen';

  @override
  String get noRecentChannelsTitle => 'Noch keine Sender angesehen';

  @override
  String get noRecentChannelsMessage =>
      'Sender, die du ansiehst, erscheinen hier.';

  @override
  String get noChannelFound => 'Keine Sender gefunden';

  @override
  String get pickChannelTitle => 'Wähle einen Sender';

  @override
  String get pickChannelMessage =>
      'Klicke auf einen Sender in der Liste. Rechtsklick für mehr Optionen, + in der Senderzeile zum Nebeneinander-Ansehen.';

  @override
  String get hintChangeChannel => 'Sender wechseln';

  @override
  String get hintPreviousChannel => 'Vorheriger Sender';

  @override
  String get hintMute => 'Ton aus / an';

  @override
  String get hintFullscreen => 'Vollbild';

  @override
  String get audioInThisTile => 'Ton in dieser Kachel';

  @override
  String get muted => 'Stumm';

  @override
  String get backToGrid => 'Zurück zum Raster';

  @override
  String get enlarge => 'Vergrößern';

  @override
  String get closeTile => 'Kachel schließen';

  @override
  String reconnecting(int attempt, int max) {
    return 'Stream hängt, neue Verbindung ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'Sender konnte nicht geöffnet werden';

  @override
  String get channelFailedMessage =>
      'Der Anbieter sendet keinen Stream oder das Verbindungslimit ist erreicht.';

  @override
  String get listFailedTitle => 'Liste konnte nicht geöffnet werden';

  @override
  String get loadingChannels => 'Senderliste wird geladen…';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get yesterday => 'Gestern';

  @override
  String archiveHint(int days) {
    return 'Letzte $days Tage verfügbar, klicke auf eine Sendung';
  }

  @override
  String get noProgrammes => 'Kein Programm für diesen Sender';

  @override
  String get watchFromStart => 'Von Anfang an ansehen';

  @override
  String get watchFromArchive => 'Aus dem Archiv ansehen';

  @override
  String get searchHintAll => 'Sender, Filme oder Serien suchen';

  @override
  String get searchPromptTitle => 'Was möchtest du sehen?';

  @override
  String get searchPromptChannels =>
      'Gib mindestens zwei Buchstaben ein, um Sender zu durchsuchen.';

  @override
  String get searchPromptAll =>
      'Gib mindestens zwei Buchstaben ein; Sender, Filme und Serien werden gleichzeitig durchsucht.';

  @override
  String get channels => 'Sender';

  @override
  String loadingSection(String section) {
    return '$section werden geladen…';
  }

  @override
  String get noResultsTitle => 'Keine Ergebnisse';

  @override
  String get noResultsMessage => 'Versuche eine andere Schreibweise.';

  @override
  String get addList => 'Liste hinzufügen';

  @override
  String get editList => 'Liste bearbeiten';

  @override
  String get listNameOptional => 'Listenname (optional)';

  @override
  String get listNameHint => 'z. B. Zuhause, Sportpaket';

  @override
  String get serverAddress => 'Serveradresse';

  @override
  String get serverAddressHint =>
      'http://server:8080 oder der M3U-Link deines Anbieters';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get hidePassword => 'Passwort verbergen';

  @override
  String get m3uLocation => 'M3U-Liste (URL oder Dateipfad)';

  @override
  String get add => 'Hinzufügen';

  @override
  String get save => 'Speichern';

  @override
  String get errServerAndUserRequired =>
      'Serveradresse und Benutzername sind erforderlich.';

  @override
  String get errLocationRequired =>
      'Eine Listen-URL oder ein Dateipfad ist erforderlich.';

  @override
  String errDuplicateList(String name) {
    return 'Diese Liste ist bereits hinzugefügt: „$name“.';
  }

  @override
  String get deleteListTitle => 'Liste löschen?';

  @override
  String deleteListMessage(String name) {
    return '„$name“ wird mit Lieblingspaketen und Verlauf gelöscht. Dein Konto beim Anbieter bleibt unberührt.';
  }

  @override
  String get yourLists => 'Deine Listen';

  @override
  String get welcomeTitle => 'Willkommen bei Streamlity';

  @override
  String get welcomeMessage =>
      'Füge eine Liste hinzu, um loszulegen. Du kannst beliebig viele Listen hinzufügen und zwischen ihnen wechseln.';

  @override
  String get xtreamDescription =>
      'Server, Benutzername und Passwort. Live-TV, Filme, Serien.';

  @override
  String get m3uDescription =>
      'Eine Listen-URL oder eine Datei auf deinem Computer.';

  @override
  String get notOpenedYet => 'Noch nicht geöffnet';

  @override
  String get audioLanguage => 'Tonspur';

  @override
  String get subtitles => 'Untertitel';

  @override
  String get subtitlesOff => 'Aus';

  @override
  String trackNumber(String id) {
    return 'Spur $id';
  }

  @override
  String get sortProvider => 'Reihenfolge des Anbieters';

  @override
  String get sortName => 'Nach Name';

  @override
  String get sortRating => 'Nach Bewertung';

  @override
  String get sortYear => 'Nach Jahr';

  @override
  String get moviesFailed => 'Filme konnten nicht geladen werden';

  @override
  String get seriesFailed => 'Serien konnten nicht geladen werden';

  @override
  String get allMovies => 'Alle Filme';

  @override
  String get allSeries => 'Alle Serien';

  @override
  String get searchMovies => 'Filme suchen';

  @override
  String get searchSeries => 'Serien suchen';

  @override
  String get noMatchingMovies => 'Keine passenden Filme';

  @override
  String get noMatchingSeries => 'Keine passenden Serien';

  @override
  String get loadingMovies => 'Filme werden geladen…';

  @override
  String get loadingSeries => 'Serien werden geladen…';

  @override
  String get noDescription => 'Keine Beschreibung.';

  @override
  String get director => 'Regie';

  @override
  String get cast => 'Besetzung';

  @override
  String resumeAt(String position) {
    return 'Fortsetzen · $position';
  }

  @override
  String get startOver => 'Von vorn';

  @override
  String get seriesInfoFailed => 'Seriendetails konnten nicht geladen werden';

  @override
  String get noEpisodes => 'Diese Serie hat keine Folgen';

  @override
  String seasonTab(int season, int count) {
    return 'Staffel $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'Staffel $season, Folge $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'S$season F$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · Abspielen';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · Fortsetzen';
  }

  @override
  String episodeFallback(int number) {
    return 'Folge $number';
  }

  @override
  String get watched => 'Gesehen';

  @override
  String watchedUntil(String position) {
    return 'Gesehen bis $position';
  }

  @override
  String get playbackFailed => 'Wiedergabe fehlgeschlagen';

  @override
  String errHttpStatus(int code) {
    return 'Der Server hat $code zurückgegeben.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'Liste konnte nicht geladen werden: $detail';
  }

  @override
  String get errNoChannels => 'Keine Sender in der Liste gefunden.';

  @override
  String get errNoLiveChannels => 'Keine Live-Sender im Konto gefunden.';

  @override
  String get errBadLogin => 'Benutzername oder Passwort ist falsch.';

  @override
  String errAccountUnavailable(String status) {
    return 'Konto nicht verfügbar (Status: $status).';
  }

  @override
  String errConnect(String detail) {
    return 'Keine Verbindung zum Server: $detail';
  }

  @override
  String get errInvalidResponse =>
      'Der Server hat keine gültige Xtream-Codes-Antwort geliefert.';

  @override
  String get errNoMovies => 'Keine Filme im Konto gefunden.';

  @override
  String get errNoSeries => 'Keine Serien im Konto gefunden.';

  @override
  String errEpg(String detail) {
    return 'Programm konnte nicht geladen werden: $detail';
  }

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSubtitle => 'Sprache der App-Oberfläche';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String systemLanguageCurrent(String language) {
    return 'Aktuell: $language';
  }

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsAboutText =>
      'Open-Source-IPTV-Player für Windows, macOS und Linux.';

  @override
  String get translationNote =>
      'Die Übersetzungen wurden automatisch erstellt; melde uns gern Fehler.';

  @override
  String get editCategories => 'Kategorien bearbeiten';

  @override
  String get editCategoriesHint =>
      'Ziehen zum Sortieren, Augensymbol zum Ausblenden, Schlosssymbol für PIN-Schutz.';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgeblendet',
      zero: 'Keine ausgeblendeten Kategorien',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'Treffer ausblenden ($count)';
  }

  @override
  String showMatching(int count) {
    return 'Treffer einblenden ($count)';
  }

  @override
  String get moveToTop => 'Nach oben verschieben';

  @override
  String get hideCategory => 'Ausblenden';

  @override
  String get showCategory => 'Einblenden';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get dragToReorder => 'Zum Sortieren ziehen';

  @override
  String lockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gesperrt',
    );
    return '$_temp0';
  }

  @override
  String get lockCategory => 'Sperren';

  @override
  String get unlockCategory => 'Sperre aufheben';

  @override
  String get lockedCategory => 'Gesperrte Kategorie';

  @override
  String get confirm => 'OK';

  @override
  String get pinEnterTitle => 'PIN eingeben';

  @override
  String get pinWrong => 'Falsche PIN';

  @override
  String get pinUnlockMessage =>
      'Diese Kategorie ist gesperrt. Nach Eingabe der PIN bleiben alle gesperrten Kategorien geöffnet, bis die App geschlossen wird.';

  @override
  String get pinEditorMessage =>
      'Zum Ändern der Kategorien wird die PIN benötigt.';

  @override
  String get pinCurrentMessage =>
      'Gib deine aktuelle PIN ein, um fortzufahren.';

  @override
  String get pinRemoveMessage =>
      'Gib deine aktuelle PIN ein, um sie zu entfernen.';

  @override
  String get pinNewTitle => 'Neue PIN';

  @override
  String get pinNewMessage =>
      'Wähle eine 4-stellige PIN zum Öffnen gesperrter Kategorien.';

  @override
  String get pinConfirmTitle => 'PIN bestätigen';

  @override
  String get pinConfirmMessage => 'Gib dieselbe PIN noch einmal ein.';

  @override
  String get pinMismatch => 'Die PINs stimmen nicht überein';

  @override
  String get pinSaved => 'PIN gespeichert';

  @override
  String get pinRemoved => 'PIN und alle Kategoriesperren entfernt';

  @override
  String get locksClosed => 'Gesperrte Kategorien sind wieder gesperrt';

  @override
  String get parentalControl => 'Jugendschutz';

  @override
  String get parentalControlSubtitle =>
      'Gesperrte Kategorien öffnen sich nicht ohne PIN, und ihre Sender erscheinen weder in der Suche noch auf der Startseite.';

  @override
  String get setPin => 'PIN festlegen';

  @override
  String get setPinDetail =>
      'Sperre dann Kategorien mit dem Schlosssymbol im Kategorie-Editor.';

  @override
  String get lockNow => 'Jetzt wieder sperren';

  @override
  String get lockNowDetail =>
      'In dieser Sitzung geöffnete gesperrte Kategorien fragen wieder nach der PIN.';

  @override
  String get changePin => 'PIN ändern';

  @override
  String get removePin => 'PIN entfernen';

  @override
  String get removePinDetail =>
      'Alle Kategoriesperren werden ebenfalls entfernt.';

  @override
  String get searchFilterAll => 'Alle';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get fullscreenGrid => 'Vollbild (F)';

  @override
  String get exitFullscreenGrid => 'Vollbild beenden (Esc)';
}
