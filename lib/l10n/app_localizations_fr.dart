// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'Réessayer';

  @override
  String get tryAgain => 'Relancer';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get goBack => 'Revenir';

  @override
  String get backToLists => 'Retour aux listes';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get options => 'Options';

  @override
  String get clear => 'Effacer';

  @override
  String get play => 'Lire';

  @override
  String get liveBadge => 'DIRECT';

  @override
  String get nowBadge => 'EN COURS';

  @override
  String get nextLabel => 'ENSUITE';

  @override
  String get schedule => 'Programme TV';

  @override
  String get favoritePackages => 'Bouquets favoris';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get searchCategories => 'Rechercher une catégorie';

  @override
  String get noMatchingCategory => 'Aucune catégorie correspondante';

  @override
  String get addToFavoritePackages => 'Ajouter aux bouquets favoris';

  @override
  String get removeFromFavoritePackages => 'Retirer des bouquets favoris';

  @override
  String get changeSearchOrCategory => 'Modifie la recherche ou la catégorie.';

  @override
  String get scrollBack => 'Défiler en arrière';

  @override
  String get scrollForward => 'Défiler en avant';

  @override
  String get muteShortcut => 'Couper le son (M)';

  @override
  String get unmuteShortcut => 'Rétablir le son (M)';

  @override
  String get ungrouped => 'Sans groupe';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString chaînes',
      one: '1 chaîne',
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
      other: '$countString films',
      one: '1 film',
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
      other: '$countString séries',
      one: '1 série',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listes',
      one: '1 liste',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saisons',
      one: '1 saison',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String get expired => 'Expiré';

  @override
  String minutesLeft(int minutes) {
    return 'Encore $minutes min';
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
  String get sectionHome => 'Accueil';

  @override
  String get sectionLive => 'TV en direct';

  @override
  String get sectionMovies => 'Films';

  @override
  String get sectionSeries => 'Séries';

  @override
  String get sectionSearch => 'Recherche';

  @override
  String get sectionLists => 'Listes';

  @override
  String get sectionSettings => 'Paramètres';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingDay => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get greetingNight => 'Bonne nuit';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName est prête. Ouvre une chaîne ou choisis un film : ce que tu regardes apparaîtra ici.';
  }

  @override
  String get homeIntro =>
      'Reprends là où tu t\'es arrêté ou découvre quelque chose de nouveau.';

  @override
  String get continueWatching => 'Reprendre';

  @override
  String get recentChannels => 'Chaînes regardées récemment';

  @override
  String get searchShortcutAll => 'Chaînes, films, séries';

  @override
  String get searchShortcutChannels => 'Dans les chaînes';

  @override
  String maxSlotsReached(int max) {
    return 'Tu peux regarder jusqu\'à $max chaînes à la fois';
  }

  @override
  String maxSlotsShort(int max) {
    return 'Jusqu\'à $max chaînes';
  }

  @override
  String get watchSideBySide => 'Regarder côte à côte';

  @override
  String get epgUpdating => 'Mise à jour du programme';

  @override
  String get epgFailed => 'Impossible de charger le programme';

  @override
  String get allChannels => 'Toutes les chaînes';

  @override
  String get recentlyWatched => 'Regardées récemment';

  @override
  String get searchChannels => 'Rechercher une chaîne';

  @override
  String get noRecentChannelsTitle => 'Aucune chaîne regardée';

  @override
  String get noRecentChannelsMessage =>
      'Les chaînes que tu regardes apparaîtront ici.';

  @override
  String get noChannelFound => 'Aucune chaîne trouvée';

  @override
  String get pickChannelTitle => 'Choisis une chaîne';

  @override
  String get pickChannelMessage =>
      'Clique sur une chaîne dans la liste. Clic droit pour plus d\'options, ou + sur une ligne pour regarder côte à côte.';

  @override
  String get hintChangeChannel => 'Changer de chaîne';

  @override
  String get hintPreviousChannel => 'Chaîne précédente';

  @override
  String get hintMute => 'Couper / rétablir le son';

  @override
  String get hintFullscreen => 'Plein écran';

  @override
  String get audioInThisTile => 'Son dans cette vignette';

  @override
  String get muted => 'Son coupé';

  @override
  String get backToGrid => 'Retour à la grille';

  @override
  String get enlarge => 'Agrandir';

  @override
  String get closeTile => 'Fermer la vignette';

  @override
  String reconnecting(int attempt, int max) {
    return 'Flux interrompu, reconnexion ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'Impossible d\'ouvrir la chaîne';

  @override
  String get channelFailedMessage =>
      'Le fournisseur n\'envoie pas le flux ou la limite de connexions est atteinte.';

  @override
  String get listFailedTitle => 'Impossible d\'ouvrir la liste';

  @override
  String get loadingChannels => 'Chargement de la liste des chaînes…';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get yesterday => 'Hier';

  @override
  String archiveHint(int days) {
    return '$days derniers jours disponibles, clique sur un programme';
  }

  @override
  String get noProgrammes => 'Aucun programme pour cette chaîne';

  @override
  String get watchFromStart => 'Regarder depuis le début';

  @override
  String get watchFromArchive => 'Regarder en replay';

  @override
  String get searchHintAll => 'Rechercher chaînes, films ou séries';

  @override
  String get searchPromptTitle => 'Que veux-tu regarder ?';

  @override
  String get searchPromptChannels =>
      'Tape au moins deux lettres pour rechercher les chaînes.';

  @override
  String get searchPromptAll =>
      'Tape au moins deux lettres pour rechercher à la fois les chaînes, films et séries.';

  @override
  String get channels => 'Chaînes';

  @override
  String loadingSection(String section) {
    return 'Chargement : $section…';
  }

  @override
  String get noResultsTitle => 'Aucun résultat';

  @override
  String get noResultsMessage => 'Essaie une autre orthographe.';

  @override
  String get addList => 'Ajouter une liste';

  @override
  String get editList => 'Modifier la liste';

  @override
  String get listNameOptional => 'Nom de la liste (facultatif)';

  @override
  String get listNameHint => 'ex. Maison, Bouquet sport';

  @override
  String get serverAddress => 'Adresse du serveur';

  @override
  String get serverAddressHint =>
      'http://serveur:8080 ou le lien M3U de ton fournisseur';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get m3uLocation => 'Liste M3U (URL ou chemin du fichier)';

  @override
  String get add => 'Ajouter';

  @override
  String get save => 'Enregistrer';

  @override
  String get errServerAndUserRequired =>
      'L\'adresse du serveur et le nom d\'utilisateur sont requis.';

  @override
  String get errLocationRequired =>
      'Une URL de liste ou un chemin de fichier est requis.';

  @override
  String errDuplicateList(String name) {
    return 'Cette liste est déjà ajoutée : « $name ».';
  }

  @override
  String get deleteListTitle => 'Supprimer la liste ?';

  @override
  String deleteListMessage(String name) {
    return '« $name », ses bouquets favoris et son historique seront supprimés. Ton compte chez le fournisseur n\'est pas concerné.';
  }

  @override
  String get yourLists => 'Tes listes';

  @override
  String get welcomeTitle => 'Bienvenue dans Streamlity';

  @override
  String get welcomeMessage =>
      'Ajoute une liste pour commencer. Tu peux en ajouter autant que tu veux et passer de l\'une à l\'autre.';

  @override
  String get xtreamDescription =>
      'Serveur, nom d\'utilisateur et mot de passe. TV en direct, films, séries.';

  @override
  String get m3uDescription =>
      'Une URL de liste ou un fichier sur ton ordinateur.';

  @override
  String get notOpenedYet => 'Pas encore ouverte';

  @override
  String get audioLanguage => 'Langue audio';

  @override
  String get subtitles => 'Sous-titres';

  @override
  String get subtitlesOff => 'Désactivés';

  @override
  String trackNumber(String id) {
    return 'Piste $id';
  }

  @override
  String get sortProvider => 'Ordre du fournisseur';

  @override
  String get sortName => 'Par nom';

  @override
  String get sortRating => 'Par note';

  @override
  String get sortYear => 'Par année';

  @override
  String get moviesFailed => 'Impossible de charger les films';

  @override
  String get seriesFailed => 'Impossible de charger les séries';

  @override
  String get allMovies => 'Tous les films';

  @override
  String get allSeries => 'Toutes les séries';

  @override
  String get searchMovies => 'Rechercher un film';

  @override
  String get searchSeries => 'Rechercher une série';

  @override
  String get noMatchingMovies => 'Aucun film correspondant';

  @override
  String get noMatchingSeries => 'Aucune série correspondante';

  @override
  String get loadingMovies => 'Chargement des films…';

  @override
  String get loadingSeries => 'Chargement des séries…';

  @override
  String get noDescription => 'Aucune description.';

  @override
  String get director => 'Réalisation';

  @override
  String get cast => 'Distribution';

  @override
  String resumeAt(String position) {
    return 'Reprendre · $position';
  }

  @override
  String get startOver => 'Recommencer';

  @override
  String get seriesInfoFailed =>
      'Impossible de charger les détails de la série';

  @override
  String get noEpisodes => 'Cette série n\'a aucun épisode';

  @override
  String seasonTab(int season, int count) {
    return 'Saison $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'Saison $season, épisode $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'S$season É$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · Lire';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · Reprendre';
  }

  @override
  String episodeFallback(int number) {
    return 'Épisode $number';
  }

  @override
  String get watched => 'Vu';

  @override
  String watchedUntil(String position) {
    return 'Vu jusqu\'à $position';
  }

  @override
  String get playbackFailed => 'Lecture impossible';

  @override
  String errHttpStatus(int code) {
    return 'Le serveur a renvoyé $code.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'Impossible de charger la liste : $detail';
  }

  @override
  String get errNoChannels => 'Aucune chaîne trouvée dans la liste.';

  @override
  String get errNoLiveChannels =>
      'Aucune chaîne en direct trouvée dans le compte.';

  @override
  String get errBadLogin => 'Nom d\'utilisateur ou mot de passe incorrect.';

  @override
  String errAccountUnavailable(String status) {
    return 'Compte indisponible (statut : $status).';
  }

  @override
  String errConnect(String detail) {
    return 'Connexion au serveur impossible : $detail';
  }

  @override
  String get errInvalidResponse =>
      'Le serveur n\'a pas renvoyé de réponse Xtream Codes valide.';

  @override
  String get errNoMovies => 'Aucun film trouvé dans le compte.';

  @override
  String get errNoSeries => 'Aucune série trouvée dans le compte.';

  @override
  String errEpg(String detail) {
    return 'Impossible de charger le programme : $detail';
  }

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSubtitle => 'Langue de l\'interface';

  @override
  String get systemLanguage => 'Langue du système';

  @override
  String systemLanguageCurrent(String language) {
    return 'Actuellement : $language';
  }

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutText =>
      'Lecteur IPTV open source pour Windows, macOS et Linux.';

  @override
  String get translationNote =>
      'Les traductions ont été préparées automatiquement ; signale-nous toute erreur.';

  @override
  String get editCategories => 'Modifier les catégories';

  @override
  String get editCategoriesHint =>
      'Fais glisser pour réorganiser, utilise l\'œil pour masquer.';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count masquées',
      one: '1 masquée',
      zero: 'Aucune catégorie masquée',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'Masquer les résultats ($count)';
  }

  @override
  String showMatching(int count) {
    return 'Afficher les résultats ($count)';
  }

  @override
  String get moveToTop => 'Placer en haut';

  @override
  String get hideCategory => 'Masquer';

  @override
  String get showCategory => 'Afficher';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get dragToReorder => 'Faire glisser pour réorganiser';
}
