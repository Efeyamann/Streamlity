// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'Try again';

  @override
  String get tryAgain => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get goBack => 'Go back';

  @override
  String get backToLists => 'Back to lists';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get options => 'Options';

  @override
  String get clear => 'Clear';

  @override
  String get play => 'Play';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get nowBadge => 'NOW';

  @override
  String get nextLabel => 'NEXT';

  @override
  String get schedule => 'TV guide';

  @override
  String get favoritePackages => 'Favorite packages';

  @override
  String get allCategories => 'All categories';

  @override
  String get searchCategories => 'Search categories';

  @override
  String get noMatchingCategory => 'No matching category';

  @override
  String get addToFavoritePackages => 'Add to favorite packages';

  @override
  String get removeFromFavoritePackages => 'Remove from favorite packages';

  @override
  String get changeSearchOrCategory => 'Change your search or category.';

  @override
  String get scrollBack => 'Scroll back';

  @override
  String get scrollForward => 'Scroll forward';

  @override
  String get muteShortcut => 'Mute (M)';

  @override
  String get unmuteShortcut => 'Unmute (M)';

  @override
  String get ungrouped => 'Ungrouped';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString channels',
      one: '1 channel',
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
      other: '$countString movies',
      one: '1 movie',
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
      one: '1 series',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lists',
      one: '1 list',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seasons',
      one: '1 season',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String get expired => 'Expired';

  @override
  String minutesLeft(int minutes) {
    return '$minutes min left';
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
  String get sectionHome => 'Home';

  @override
  String get sectionLive => 'Live TV';

  @override
  String get sectionMovies => 'Movies';

  @override
  String get sectionSeries => 'Series';

  @override
  String get sectionSearch => 'Search';

  @override
  String get sectionLists => 'Lists';

  @override
  String get sectionSettings => 'Settings';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingDay => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName is ready. Open a channel or pick a movie; what you watch will show up here.';
  }

  @override
  String get homeIntro =>
      'Pick up where you left off or discover something new.';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String get recentChannels => 'Recently watched channels';

  @override
  String get searchShortcutAll => 'Channels, movies, series';

  @override
  String get searchShortcutChannels => 'In channels';

  @override
  String maxSlotsReached(int max) {
    return 'You can watch up to $max channels at once';
  }

  @override
  String maxSlotsShort(int max) {
    return 'Up to $max channels';
  }

  @override
  String get watchSideBySide => 'Watch side by side';

  @override
  String get epgUpdating => 'Updating TV guide';

  @override
  String get epgFailed => 'Couldn\'t load TV guide';

  @override
  String get allChannels => 'All channels';

  @override
  String get recentlyWatched => 'Recently watched';

  @override
  String get searchChannels => 'Search channels';

  @override
  String get noRecentChannelsTitle => 'No channels watched yet';

  @override
  String get noRecentChannelsMessage => 'Channels you watch will appear here.';

  @override
  String get noChannelFound => 'No channels found';

  @override
  String get pickChannelTitle => 'Pick a channel';

  @override
  String get pickChannelMessage =>
      'Click a channel in the list. Right-click for more options, or use + on a channel row to watch side by side.';

  @override
  String get hintChangeChannel => 'Change channel';

  @override
  String get hintPreviousChannel => 'Previous channel';

  @override
  String get hintMute => 'Mute / unmute';

  @override
  String get hintFullscreen => 'Full screen';

  @override
  String get audioInThisTile => 'Audio in this tile';

  @override
  String get muted => 'Muted';

  @override
  String get backToGrid => 'Back to grid';

  @override
  String get enlarge => 'Enlarge';

  @override
  String get closeTile => 'Close tile';

  @override
  String reconnecting(int attempt, int max) {
    return 'Stream stalled, reconnecting ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'Couldn\'t open channel';

  @override
  String get channelFailedMessage =>
      'The provider isn\'t sending the stream or the connection limit is reached.';

  @override
  String get listFailedTitle => 'Couldn\'t open list';

  @override
  String get loadingChannels => 'Loading channel list…';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String archiveHint(int days) {
    return 'Past $days days available, click a programme';
  }

  @override
  String get noProgrammes => 'No programmes for this channel';

  @override
  String get watchFromStart => 'Watch from start';

  @override
  String get watchFromArchive => 'Watch from archive';

  @override
  String get searchHintAll => 'Search channels, movies or series';

  @override
  String get searchPromptTitle => 'What do you want to watch?';

  @override
  String get searchPromptChannels =>
      'Type at least two letters to search channels.';

  @override
  String get searchPromptAll =>
      'Type at least two letters to search channels, movies and series at once.';

  @override
  String get channels => 'Channels';

  @override
  String loadingSection(String section) {
    return 'Loading $section…';
  }

  @override
  String get noResultsTitle => 'No results';

  @override
  String get noResultsMessage => 'Try a different spelling.';

  @override
  String get addList => 'Add list';

  @override
  String get editList => 'Edit list';

  @override
  String get listNameOptional => 'List name (optional)';

  @override
  String get listNameHint => 'e.g. Home, Sports package';

  @override
  String get serverAddress => 'Server address';

  @override
  String get serverAddressHint =>
      'http://server:8080 or your provider\'s M3U link';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get m3uLocation => 'M3U list (URL or file path)';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get errServerAndUserRequired =>
      'Server address and username are required.';

  @override
  String get errLocationRequired => 'A list URL or file path is required.';

  @override
  String errDuplicateList(String name) {
    return 'This list is already added: \"$name\".';
  }

  @override
  String get deleteListTitle => 'Delete list?';

  @override
  String deleteListMessage(String name) {
    return '\"$name\" and its favorite packages and recently watched will be deleted. Your account at the provider isn\'t affected.';
  }

  @override
  String get yourLists => 'Your lists';

  @override
  String get welcomeTitle => 'Welcome to Streamlity';

  @override
  String get welcomeMessage =>
      'Add a list to get started. You can add as many lists as you like and switch between them.';

  @override
  String get xtreamDescription =>
      'Server, username and password. Live TV, movies, series.';

  @override
  String get m3uDescription => 'A list URL or a file on your computer.';

  @override
  String get notOpenedYet => 'Not opened yet';

  @override
  String get audioLanguage => 'Audio language';

  @override
  String get subtitles => 'Subtitles';

  @override
  String get subtitlesOff => 'Off';

  @override
  String trackNumber(String id) {
    return 'Track $id';
  }

  @override
  String get sortProvider => 'Provider order';

  @override
  String get sortName => 'By name';

  @override
  String get sortRating => 'By rating';

  @override
  String get sortYear => 'By year';

  @override
  String get moviesFailed => 'Couldn\'t load movies';

  @override
  String get seriesFailed => 'Couldn\'t load series';

  @override
  String get allMovies => 'All movies';

  @override
  String get allSeries => 'All series';

  @override
  String get searchMovies => 'Search movies';

  @override
  String get searchSeries => 'Search series';

  @override
  String get noMatchingMovies => 'No matching movies';

  @override
  String get noMatchingSeries => 'No matching series';

  @override
  String get loadingMovies => 'Loading movies…';

  @override
  String get loadingSeries => 'Loading series…';

  @override
  String get noDescription => 'No description.';

  @override
  String get director => 'Director';

  @override
  String get cast => 'Cast';

  @override
  String resumeAt(String position) {
    return 'Resume · $position';
  }

  @override
  String get startOver => 'Start over';

  @override
  String get seriesInfoFailed => 'Couldn\'t load series details';

  @override
  String get noEpisodes => 'This series has no episodes';

  @override
  String seasonTab(int season, int count) {
    return 'Season $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'Season $season, episode $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'S$season E$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · Play';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · Resume';
  }

  @override
  String episodeFallback(int number) {
    return 'Episode $number';
  }

  @override
  String get watched => 'Watched';

  @override
  String watchedUntil(String position) {
    return 'Watched until $position';
  }

  @override
  String get playbackFailed => 'Couldn\'t play';

  @override
  String errHttpStatus(int code) {
    return 'The server returned $code.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'Couldn\'t load the list: $detail';
  }

  @override
  String get errNoChannels => 'No channels found in the list.';

  @override
  String get errNoLiveChannels => 'No live channels found in the account.';

  @override
  String get errBadLogin => 'Wrong username or password.';

  @override
  String errAccountUnavailable(String status) {
    return 'Account unavailable (status: $status).';
  }

  @override
  String errConnect(String detail) {
    return 'Couldn\'t connect to the server: $detail';
  }

  @override
  String get errInvalidResponse =>
      'The server didn\'t return a valid Xtream Codes response.';

  @override
  String get errNoMovies => 'No movies found in the account.';

  @override
  String get errNoSeries => 'No series found in the account.';

  @override
  String errEpg(String detail) {
    return 'Couldn\'t load TV guide: $detail';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'The app\'s interface language';

  @override
  String get systemLanguage => 'System language';

  @override
  String systemLanguageCurrent(String language) {
    return 'Currently: $language';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutText =>
      'Open-source IPTV player for Windows, macOS and Linux.';

  @override
  String get translationNote =>
      'Translations were prepared automatically; let us know if you spot a mistake.';

  @override
  String get editCategories => 'Edit categories';

  @override
  String get editCategoriesHint => 'Drag to reorder, use the eye icon to hide.';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hidden',
      zero: 'No hidden categories',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'Hide matches ($count)';
  }

  @override
  String showMatching(int count) {
    return 'Show matches ($count)';
  }

  @override
  String get moveToTop => 'Move to top';

  @override
  String get hideCategory => 'Hide';

  @override
  String get showCategory => 'Show';

  @override
  String get reset => 'Reset';

  @override
  String get dragToReorder => 'Drag to reorder';
}
