// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'Повторить';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get goBack => 'Вернуться';

  @override
  String get backToLists => 'К спискам';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get options => 'Параметры';

  @override
  String get clear => 'Очистить';

  @override
  String get play => 'Смотреть';

  @override
  String get liveBadge => 'ЭФИР';

  @override
  String get nowBadge => 'СЕЙЧАС';

  @override
  String get nextLabel => 'ДАЛЕЕ';

  @override
  String get schedule => 'Телепрограмма';

  @override
  String get favoritePackages => 'Избранные пакеты';

  @override
  String get allCategories => 'Все категории';

  @override
  String get searchCategories => 'Поиск категорий';

  @override
  String get noMatchingCategory => 'Нет подходящих категорий';

  @override
  String get addToFavoritePackages => 'Добавить в избранные пакеты';

  @override
  String get removeFromFavoritePackages => 'Убрать из избранных пакетов';

  @override
  String get changeSearchOrCategory => 'Измените запрос или категорию.';

  @override
  String get scrollBack => 'Прокрутить назад';

  @override
  String get scrollForward => 'Прокрутить вперёд';

  @override
  String get muteShortcut => 'Без звука (M)';

  @override
  String get unmuteShortcut => 'Включить звук (M)';

  @override
  String get ungrouped => 'Без группы';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString канала',
      many: '$countString каналов',
      few: '$countString канала',
      one: '$countString канал',
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
      other: '$countString фильма',
      many: '$countString фильмов',
      few: '$countString фильма',
      one: '$countString фильм',
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
      other: '$countString сериала',
      many: '$countString сериалов',
      few: '$countString сериала',
      one: '$countString сериал',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count списка',
      many: '$count списков',
      few: '$count списка',
      one: '$count список',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сезона',
      many: '$count сезонов',
      few: '$count сезона',
      one: '$count сезон',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Действует до $date';
  }

  @override
  String get expired => 'Срок истёк';

  @override
  String minutesLeft(int minutes) {
    return 'Осталось $minutes мин';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get sectionHome => 'Главная';

  @override
  String get sectionLive => 'ТВ';

  @override
  String get sectionMovies => 'Фильмы';

  @override
  String get sectionSeries => 'Сериалы';

  @override
  String get sectionSearch => 'Поиск';

  @override
  String get sectionLists => 'Списки';

  @override
  String get sectionSettings => 'Настройки';

  @override
  String get greetingMorning => 'Доброе утро';

  @override
  String get greetingDay => 'Добрый день';

  @override
  String get greetingEvening => 'Добрый вечер';

  @override
  String get greetingNight => 'Доброй ночи';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName готов. Откройте канал или выберите фильм — то, что вы смотрите, появится здесь.';
  }

  @override
  String get homeIntro => 'Продолжите просмотр или откройте что-то новое.';

  @override
  String get continueWatching => 'Продолжить просмотр';

  @override
  String get recentChannels => 'Недавние каналы';

  @override
  String get searchShortcutAll => 'Каналы, фильмы, сериалы';

  @override
  String get searchShortcutChannels => 'По каналам';

  @override
  String maxSlotsReached(int max) {
    return 'Одновременно можно смотреть до $max каналов';
  }

  @override
  String maxSlotsShort(int max) {
    return 'До $max каналов';
  }

  @override
  String get watchSideBySide => 'Смотреть рядом';

  @override
  String get epgUpdating => 'Обновление телепрограммы';

  @override
  String get epgFailed => 'Не удалось загрузить телепрограмму';

  @override
  String get allChannels => 'Все каналы';

  @override
  String get recentlyWatched => 'Недавние';

  @override
  String get searchChannels => 'Поиск каналов';

  @override
  String get noRecentChannelsTitle => 'Вы ещё не смотрели каналы';

  @override
  String get noRecentChannelsMessage =>
      'Здесь появятся каналы, которые вы смотрите.';

  @override
  String get noChannelFound => 'Каналы не найдены';

  @override
  String get pickChannelTitle => 'Выберите канал';

  @override
  String get pickChannelMessage =>
      'Нажмите на канал в списке. Правый клик — дополнительные действия, + в строке канала — просмотр рядом.';

  @override
  String get hintChangeChannel => 'Сменить канал';

  @override
  String get hintPreviousChannel => 'Предыдущий канал';

  @override
  String get hintMute => 'Выключить / включить звук';

  @override
  String get hintFullscreen => 'Полный экран';

  @override
  String get audioInThisTile => 'Звук в этом окне';

  @override
  String get muted => 'Без звука';

  @override
  String get backToGrid => 'Вернуться к сетке';

  @override
  String get enlarge => 'Увеличить';

  @override
  String get closeTile => 'Закрыть окно';

  @override
  String reconnecting(int attempt, int max) {
    return 'Поток завис, переподключение ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'Не удалось открыть канал';

  @override
  String get channelFailedMessage =>
      'Провайдер не передаёт поток или достигнут лимит подключений.';

  @override
  String get listFailedTitle => 'Не удалось открыть список';

  @override
  String get loadingChannels => 'Загрузка списка каналов…';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get yesterday => 'Вчера';

  @override
  String archiveHint(int days) {
    return 'Доступны последние дни: $days, нажмите на передачу';
  }

  @override
  String get noProgrammes => 'Для этого канала нет передач';

  @override
  String get watchFromStart => 'Смотреть с начала';

  @override
  String get watchFromArchive => 'Смотреть из архива';

  @override
  String get searchHintAll => 'Поиск каналов, фильмов или сериалов';

  @override
  String get searchPromptTitle => 'Что хотите посмотреть?';

  @override
  String get searchPromptChannels =>
      'Введите не менее двух букв для поиска по каналам.';

  @override
  String get searchPromptAll =>
      'Введите не менее двух букв — поиск идёт сразу по каналам, фильмам и сериалам.';

  @override
  String get channels => 'Каналы';

  @override
  String loadingSection(String section) {
    return 'Загрузка: $section…';
  }

  @override
  String get noResultsTitle => 'Ничего не найдено';

  @override
  String get noResultsMessage => 'Попробуйте другое написание.';

  @override
  String get addList => 'Добавить список';

  @override
  String get editList => 'Изменить список';

  @override
  String get listNameOptional => 'Название списка (необязательно)';

  @override
  String get listNameHint => 'напр. Дом, Спортивный пакет';

  @override
  String get serverAddress => 'Адрес сервера';

  @override
  String get serverAddressHint =>
      'http://server:8080 или M3U-ссылка провайдера';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get m3uLocation => 'Список M3U (URL или путь к файлу)';

  @override
  String get add => 'Добавить';

  @override
  String get save => 'Сохранить';

  @override
  String get errServerAndUserRequired =>
      'Нужны адрес сервера и имя пользователя.';

  @override
  String get errLocationRequired => 'Нужен URL списка или путь к файлу.';

  @override
  String errDuplicateList(String name) {
    return 'Этот список уже добавлен: «$name».';
  }

  @override
  String get deleteListTitle => 'Удалить список?';

  @override
  String deleteListMessage(String name) {
    return '«$name» будет удалён вместе с избранными пакетами и историей. Ваша учётная запись у провайдера не изменится.';
  }

  @override
  String get yourLists => 'Ваши списки';

  @override
  String get welcomeTitle => 'Добро пожаловать в Streamlity';

  @override
  String get welcomeMessage =>
      'Добавьте список, чтобы начать. Можно добавить сколько угодно списков и переключаться между ними.';

  @override
  String get xtreamDescription =>
      'Сервер, имя пользователя и пароль. ТВ, фильмы, сериалы.';

  @override
  String get m3uDescription => 'URL списка или файл на компьютере.';

  @override
  String get notOpenedYet => 'Ещё не открывался';

  @override
  String get audioLanguage => 'Язык звука';

  @override
  String get subtitles => 'Субтитры';

  @override
  String get subtitlesOff => 'Выкл.';

  @override
  String trackNumber(String id) {
    return 'Дорожка $id';
  }

  @override
  String get sortProvider => 'Порядок провайдера';

  @override
  String get sortName => 'По названию';

  @override
  String get sortRating => 'По рейтингу';

  @override
  String get sortYear => 'По году';

  @override
  String get moviesFailed => 'Не удалось загрузить фильмы';

  @override
  String get seriesFailed => 'Не удалось загрузить сериалы';

  @override
  String get allMovies => 'Все фильмы';

  @override
  String get allSeries => 'Все сериалы';

  @override
  String get searchMovies => 'Поиск фильмов';

  @override
  String get searchSeries => 'Поиск сериалов';

  @override
  String get noMatchingMovies => 'Нет подходящих фильмов';

  @override
  String get noMatchingSeries => 'Нет подходящих сериалов';

  @override
  String get loadingMovies => 'Загрузка фильмов…';

  @override
  String get loadingSeries => 'Загрузка сериалов…';

  @override
  String get noDescription => 'Нет описания.';

  @override
  String get director => 'Режиссёр';

  @override
  String get cast => 'В ролях';

  @override
  String resumeAt(String position) {
    return 'Продолжить · $position';
  }

  @override
  String get startOver => 'Начать сначала';

  @override
  String get seriesInfoFailed => 'Не удалось загрузить сведения о сериале';

  @override
  String get noEpisodes => 'В этом сериале нет серий';

  @override
  String seasonTab(int season, int count) {
    return 'Сезон $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'Сезон $season, серия $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'С$season Е$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · Смотреть';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · Продолжить';
  }

  @override
  String episodeFallback(int number) {
    return 'Серия $number';
  }

  @override
  String get watched => 'Просмотрено';

  @override
  String watchedUntil(String position) {
    return 'Просмотрено до $position';
  }

  @override
  String get playbackFailed => 'Не удалось воспроизвести';

  @override
  String errHttpStatus(int code) {
    return 'Сервер вернул $code.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'Не удалось загрузить список: $detail';
  }

  @override
  String get errNoChannels => 'В списке нет каналов.';

  @override
  String get errNoLiveChannels => 'В учётной записи нет каналов.';

  @override
  String get errBadLogin => 'Неверное имя пользователя или пароль.';

  @override
  String errAccountUnavailable(String status) {
    return 'Учётная запись недоступна (статус: $status).';
  }

  @override
  String errConnect(String detail) {
    return 'Не удалось подключиться к серверу: $detail';
  }

  @override
  String get errInvalidResponse =>
      'Сервер не вернул корректный ответ Xtream Codes.';

  @override
  String get errNoMovies => 'В учётной записи нет фильмов.';

  @override
  String get errNoSeries => 'В учётной записи нет сериалов.';

  @override
  String errEpg(String detail) {
    return 'Не удалось загрузить телепрограмму: $detail';
  }

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSubtitle => 'Язык интерфейса приложения';

  @override
  String get systemLanguage => 'Язык системы';

  @override
  String systemLanguageCurrent(String language) {
    return 'Сейчас: $language';
  }

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsAboutText =>
      'IPTV-плеер с открытым исходным кодом для Windows, macOS и Linux.';

  @override
  String get translationNote =>
      'Переводы подготовлены автоматически; сообщите нам, если заметите ошибку.';

  @override
  String get editCategories => 'Настроить категории';

  @override
  String get editCategoriesHint =>
      'Перетаскивайте, чтобы изменить порядок; скрывайте значком глаза, защищайте PIN-кодом значком замка.';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скрыто $count',
      many: 'Скрыто $count',
      few: 'Скрыто $count',
      one: 'Скрыта $count',
      zero: 'Скрытых категорий нет',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'Скрыть найденные ($count)';
  }

  @override
  String showMatching(int count) {
    return 'Показать найденные ($count)';
  }

  @override
  String get moveToTop => 'Переместить наверх';

  @override
  String get hideCategory => 'Скрыть';

  @override
  String get showCategory => 'Показать';

  @override
  String get reset => 'Сбросить';

  @override
  String get dragToReorder => 'Перетащите, чтобы изменить порядок';

  @override
  String lockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Заблокировано $count',
      many: 'Заблокировано $count',
      few: 'Заблокировано $count',
      one: 'Заблокирована $count',
    );
    return '$_temp0';
  }

  @override
  String get lockCategory => 'Заблокировать';

  @override
  String get unlockCategory => 'Снять блокировку';

  @override
  String get lockedCategory => 'Заблокированная категория';

  @override
  String get confirm => 'ОК';

  @override
  String get pinEnterTitle => 'Введите PIN-код';

  @override
  String get pinWrong => 'Неверный PIN-код';

  @override
  String get pinUnlockMessage =>
      'Эта категория заблокирована. После ввода PIN-кода все заблокированные категории останутся открытыми до закрытия приложения.';

  @override
  String get pinEditorMessage =>
      'Чтобы изменить порядок категорий, нужен PIN-код.';

  @override
  String get pinCurrentMessage => 'Введите текущий PIN-код, чтобы продолжить.';

  @override
  String get pinRemoveMessage => 'Введите текущий PIN-код, чтобы удалить его.';

  @override
  String get pinNewTitle => 'Новый PIN-код';

  @override
  String get pinNewMessage =>
      'Выберите 4-значный PIN-код для открытия заблокированных категорий.';

  @override
  String get pinConfirmTitle => 'Подтвердите PIN-код';

  @override
  String get pinConfirmMessage => 'Введите тот же PIN-код ещё раз.';

  @override
  String get pinMismatch => 'PIN-коды не совпадают';

  @override
  String get pinSaved => 'PIN-код сохранён';

  @override
  String get pinRemoved => 'PIN-код и все блокировки категорий удалены';

  @override
  String get locksClosed => 'Заблокированные категории снова закрыты';

  @override
  String get parentalControl => 'Родительский контроль';

  @override
  String get parentalControlSubtitle =>
      'Заблокированные категории не открываются без PIN-кода, а их каналы не показываются в поиске и на главной.';

  @override
  String get setPin => 'Задать PIN-код';

  @override
  String get setPinDetail =>
      'Затем блокируйте категории значком замка в редакторе категорий.';

  @override
  String get lockNow => 'Заблокировать снова';

  @override
  String get lockNowDetail =>
      'Заблокированные категории, открытые в этом сеансе, снова запросят PIN-код.';

  @override
  String get changePin => 'Изменить PIN-код';

  @override
  String get removePin => 'Удалить PIN-код';

  @override
  String get removePinDetail => 'Все блокировки категорий тоже будут удалены.';

  @override
  String get searchFilterAll => 'Все';

  @override
  String get seeAll => 'Показать все';

  @override
  String get fullscreenGrid => 'Во весь экран (F)';

  @override
  String get exitFullscreenGrid => 'Выйти из полноэкранного режима (Esc)';
}
