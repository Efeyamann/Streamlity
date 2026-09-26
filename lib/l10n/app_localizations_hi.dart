// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get tryAgain => 'दोबारा आज़माएँ';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get close => 'बंद करें';

  @override
  String get back => 'वापस';

  @override
  String get goBack => 'वापस जाएँ';

  @override
  String get backToLists => 'सूचियों पर वापस जाएँ';

  @override
  String get delete => 'हटाएँ';

  @override
  String get edit => 'बदलें';

  @override
  String get options => 'विकल्प';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get play => 'चलाएँ';

  @override
  String get liveBadge => 'लाइव';

  @override
  String get nowBadge => 'अभी';

  @override
  String get nextLabel => 'आगे';

  @override
  String get schedule => 'कार्यक्रम सूची';

  @override
  String get favoritePackages => 'पसंदीदा पैकेज';

  @override
  String get allCategories => 'सभी श्रेणियाँ';

  @override
  String get searchCategories => 'श्रेणी खोजें';

  @override
  String get noMatchingCategory => 'कोई मिलती-जुलती श्रेणी नहीं';

  @override
  String get addToFavoritePackages => 'पसंदीदा पैकेज में जोड़ें';

  @override
  String get removeFromFavoritePackages => 'पसंदीदा पैकेज से हटाएँ';

  @override
  String get changeSearchOrCategory => 'खोज या श्रेणी बदलें।';

  @override
  String get scrollBack => 'पीछे स्क्रॉल करें';

  @override
  String get scrollForward => 'आगे स्क्रॉल करें';

  @override
  String get muteShortcut => 'म्यूट (M)';

  @override
  String get unmuteShortcut => 'आवाज़ चालू (M)';

  @override
  String get ungrouped => 'बिना समूह';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString चैनल',
      one: '1 चैनल',
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
      other: '$countString फ़िल्में',
      one: '1 फ़िल्म',
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
      other: '$countString सीरीज़',
      one: '1 सीरीज़',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सूचियाँ',
      one: '1 सूची',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सीज़न',
      one: '1 सीज़न',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return '$date को समाप्त';
  }

  @override
  String get expired => 'समाप्त हो गया';

  @override
  String minutesLeft(int minutes) {
    return '$minutes मिनट बाकी';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours घं $minutes मि';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes मि';
  }

  @override
  String get sectionHome => 'होम';

  @override
  String get sectionLive => 'लाइव टीवी';

  @override
  String get sectionMovies => 'फ़िल्में';

  @override
  String get sectionSeries => 'सीरीज़';

  @override
  String get sectionSearch => 'खोज';

  @override
  String get sectionLists => 'सूचियाँ';

  @override
  String get sectionSettings => 'सेटिंग्स';

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingDay => 'नमस्ते';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String get greetingNight => 'शुभ रात्रि';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName तैयार है। कोई चैनल खोलें या फ़िल्म चुनें; आप जो देखेंगे वह यहाँ दिखेगा।';
  }

  @override
  String get homeIntro => 'जहाँ छोड़ा था वहीं से जारी रखें या कुछ नया खोजें।';

  @override
  String get continueWatching => 'देखना जारी रखें';

  @override
  String get recentChannels => 'हाल में देखे गए चैनल';

  @override
  String get searchShortcutAll => 'चैनल, फ़िल्में, सीरीज़';

  @override
  String get searchShortcutChannels => 'चैनलों में';

  @override
  String maxSlotsReached(int max) {
    return 'आप एक साथ अधिकतम $max चैनल देख सकते हैं';
  }

  @override
  String maxSlotsShort(int max) {
    return 'अधिकतम $max चैनल';
  }

  @override
  String get watchSideBySide => 'साथ-साथ देखें';

  @override
  String get epgUpdating => 'कार्यक्रम सूची अपडेट हो रही है';

  @override
  String get epgFailed => 'कार्यक्रम सूची लोड नहीं हो सकी';

  @override
  String get allChannels => 'सभी चैनल';

  @override
  String get recentlyWatched => 'हाल में देखे गए';

  @override
  String get searchChannels => 'चैनल खोजें';

  @override
  String get noRecentChannelsTitle => 'अभी तक कोई चैनल नहीं देखा';

  @override
  String get noRecentChannelsMessage => 'आप जो चैनल देखेंगे वे यहाँ दिखेंगे।';

  @override
  String get noChannelFound => 'कोई चैनल नहीं मिला';

  @override
  String get pickChannelTitle => 'एक चैनल चुनें';

  @override
  String get pickChannelMessage =>
      'सूची में किसी चैनल पर क्लिक करें। और विकल्पों के लिए राइट-क्लिक करें, या साथ-साथ देखने के लिए चैनल की पंक्ति में + दबाएँ।';

  @override
  String get hintChangeChannel => 'चैनल बदलें';

  @override
  String get hintPreviousChannel => 'पिछला चैनल';

  @override
  String get hintMute => 'आवाज़ बंद / चालू';

  @override
  String get hintFullscreen => 'पूर्ण स्क्रीन';

  @override
  String get audioInThisTile => 'इस विंडो की आवाज़';

  @override
  String get muted => 'म्यूट';

  @override
  String get backToGrid => 'ग्रिड पर वापस';

  @override
  String get enlarge => 'बड़ा करें';

  @override
  String get closeTile => 'विंडो बंद करें';

  @override
  String reconnecting(int attempt, int max) {
    return 'प्रसारण रुक गया, दोबारा जुड़ रहा है ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'चैनल नहीं खुल सका';

  @override
  String get channelFailedMessage =>
      'प्रदाता प्रसारण नहीं भेज रहा या कनेक्शन सीमा पूरी हो गई है।';

  @override
  String get listFailedTitle => 'सूची नहीं खुल सकी';

  @override
  String get loadingChannels => 'चैनल सूची लोड हो रही है…';

  @override
  String get today => 'आज';

  @override
  String get tomorrow => 'कल';

  @override
  String get yesterday => 'बीता कल';

  @override
  String archiveHint(int days) {
    return 'पिछले $days दिन उपलब्ध हैं, किसी कार्यक्रम पर क्लिक करें';
  }

  @override
  String get noProgrammes => 'इस चैनल के लिए कोई कार्यक्रम नहीं';

  @override
  String get watchFromStart => 'शुरू से देखें';

  @override
  String get watchFromArchive => 'पुराना प्रसारण देखें';

  @override
  String get searchHintAll => 'चैनल, फ़िल्में या सीरीज़ खोजें';

  @override
  String get searchPromptTitle => 'आप क्या देखना चाहते हैं?';

  @override
  String get searchPromptChannels =>
      'चैनल खोजने के लिए कम से कम दो अक्षर लिखें।';

  @override
  String get searchPromptAll =>
      'कम से कम दो अक्षर लिखें; चैनल, फ़िल्में और सीरीज़ एक साथ खोजे जाएँगे।';

  @override
  String get channels => 'चैनल';

  @override
  String loadingSection(String section) {
    return '$section लोड हो रहे हैं…';
  }

  @override
  String get noResultsTitle => 'कोई परिणाम नहीं';

  @override
  String get noResultsMessage => 'कोई दूसरी वर्तनी आज़माएँ।';

  @override
  String get addList => 'सूची जोड़ें';

  @override
  String get editList => 'सूची बदलें';

  @override
  String get listNameOptional => 'सूची का नाम (वैकल्पिक)';

  @override
  String get listNameHint => 'जैसे घर, खेल पैकेज';

  @override
  String get serverAddress => 'सर्वर पता';

  @override
  String get serverAddressHint =>
      'http://server:8080 या आपके प्रदाता का M3U लिंक';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get password => 'पासवर्ड';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get m3uLocation => 'M3U सूची (URL या फ़ाइल पथ)';

  @override
  String get add => 'जोड़ें';

  @override
  String get save => 'सहेजें';

  @override
  String get errServerAndUserRequired =>
      'सर्वर पता और उपयोगकर्ता नाम ज़रूरी हैं।';

  @override
  String get errLocationRequired => 'सूची का URL या फ़ाइल पथ ज़रूरी है।';

  @override
  String errDuplicateList(String name) {
    return 'यह सूची पहले से जोड़ी गई है: \"$name\"।';
  }

  @override
  String get deleteListTitle => 'सूची हटाएँ?';

  @override
  String deleteListMessage(String name) {
    return '\"$name\" और उसके पसंदीदा पैकेज व देखे गए इतिहास को हटा दिया जाएगा। प्रदाता पर आपका खाता प्रभावित नहीं होगा।';
  }

  @override
  String get yourLists => 'आपकी सूचियाँ';

  @override
  String get welcomeTitle => 'Streamlity में आपका स्वागत है';

  @override
  String get welcomeMessage =>
      'शुरू करने के लिए एक सूची जोड़ें। आप जितनी चाहें सूचियाँ जोड़ सकते हैं और उनके बीच बदल सकते हैं।';

  @override
  String get xtreamDescription =>
      'सर्वर, उपयोगकर्ता नाम और पासवर्ड। लाइव टीवी, फ़िल्में, सीरीज़।';

  @override
  String get m3uDescription => 'सूची का URL या आपके कंप्यूटर की फ़ाइल।';

  @override
  String get notOpenedYet => 'अभी तक नहीं खोली गई';

  @override
  String get audioLanguage => 'ऑडियो भाषा';

  @override
  String get subtitles => 'उपशीर्षक';

  @override
  String get subtitlesOff => 'बंद';

  @override
  String trackNumber(String id) {
    return 'ट्रैक $id';
  }

  @override
  String get sortProvider => 'प्रदाता का क्रम';

  @override
  String get sortName => 'नाम के अनुसार';

  @override
  String get sortRating => 'रेटिंग के अनुसार';

  @override
  String get sortYear => 'वर्ष के अनुसार';

  @override
  String get moviesFailed => 'फ़िल्में लोड नहीं हो सकीं';

  @override
  String get seriesFailed => 'सीरीज़ लोड नहीं हो सकीं';

  @override
  String get allMovies => 'सभी फ़िल्में';

  @override
  String get allSeries => 'सभी सीरीज़';

  @override
  String get searchMovies => 'फ़िल्में खोजें';

  @override
  String get searchSeries => 'सीरीज़ खोजें';

  @override
  String get noMatchingMovies => 'कोई मिलती-जुलती फ़िल्म नहीं';

  @override
  String get noMatchingSeries => 'कोई मिलती-जुलती सीरीज़ नहीं';

  @override
  String get loadingMovies => 'फ़िल्में लोड हो रही हैं…';

  @override
  String get loadingSeries => 'सीरीज़ लोड हो रही हैं…';

  @override
  String get noDescription => 'कोई विवरण नहीं।';

  @override
  String get director => 'निर्देशक';

  @override
  String get cast => 'कलाकार';

  @override
  String resumeAt(String position) {
    return 'जारी रखें · $position';
  }

  @override
  String get startOver => 'शुरू से चलाएँ';

  @override
  String get seriesInfoFailed => 'सीरीज़ की जानकारी लोड नहीं हो सकी';

  @override
  String get noEpisodes => 'इस सीरीज़ में कोई एपिसोड नहीं है';

  @override
  String seasonTab(int season, int count) {
    return 'सीज़न $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'सीज़न $season, एपिसोड $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'S$season E$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · चलाएँ';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · जारी रखें';
  }

  @override
  String episodeFallback(int number) {
    return 'एपिसोड $number';
  }

  @override
  String get watched => 'देख लिया';

  @override
  String watchedUntil(String position) {
    return '$position तक देखा';
  }

  @override
  String get playbackFailed => 'चलाया नहीं जा सका';

  @override
  String errHttpStatus(int code) {
    return 'सर्वर ने $code लौटाया।';
  }

  @override
  String errFetchFailed(String detail) {
    return 'सूची लोड नहीं हो सकी: $detail';
  }

  @override
  String get errNoChannels => 'सूची में कोई चैनल नहीं मिला।';

  @override
  String get errNoLiveChannels => 'खाते में कोई लाइव चैनल नहीं मिला।';

  @override
  String get errBadLogin => 'उपयोगकर्ता नाम या पासवर्ड गलत है।';

  @override
  String errAccountUnavailable(String status) {
    return 'खाता उपलब्ध नहीं है (स्थिति: $status)।';
  }

  @override
  String errConnect(String detail) {
    return 'सर्वर से कनेक्ट नहीं हो सका: $detail';
  }

  @override
  String get errInvalidResponse =>
      'सर्वर ने मान्य Xtream Codes जवाब नहीं दिया।';

  @override
  String get errNoMovies => 'खाते में कोई फ़िल्म नहीं मिली।';

  @override
  String get errNoSeries => 'खाते में कोई सीरीज़ नहीं मिली।';

  @override
  String errEpg(String detail) {
    return 'कार्यक्रम सूची लोड नहीं हो सकी: $detail';
  }

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageSubtitle => 'ऐप के इंटरफ़ेस की भाषा';

  @override
  String get systemLanguage => 'सिस्टम भाषा';

  @override
  String systemLanguageCurrent(String language) {
    return 'अभी: $language';
  }

  @override
  String get settingsAbout => 'जानकारी';

  @override
  String get settingsAboutText =>
      'Windows, macOS और Linux के लिए ओपन-सोर्स IPTV प्लेयर।';

  @override
  String get translationNote =>
      'अनुवाद अपने-आप तैयार किए गए हैं; कोई गलती दिखे तो हमें बताएँ।';

  @override
  String get editCategories => 'श्रेणियाँ संपादित करें';

  @override
  String get editCategoriesHint =>
      'क्रम बदलने के लिए खींचें, छिपाने के लिए आँख वाला आइकन और PIN लगाने के लिए ताले वाला आइकन दबाएँ।';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छिपी हुई',
      zero: 'कोई छिपी श्रेणी नहीं',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'मिलती श्रेणियाँ छिपाएँ ($count)';
  }

  @override
  String showMatching(int count) {
    return 'मिलती श्रेणियाँ दिखाएँ ($count)';
  }

  @override
  String get moveToTop => 'सबसे ऊपर ले जाएँ';

  @override
  String get hideCategory => 'छिपाएँ';

  @override
  String get showCategory => 'दिखाएँ';

  @override
  String get reset => 'रीसेट करें';

  @override
  String get dragToReorder => 'क्रम बदलने के लिए खींचें';

  @override
  String lockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लॉक',
    );
    return '$_temp0';
  }

  @override
  String get lockCategory => 'लॉक करें';

  @override
  String get unlockCategory => 'लॉक हटाएँ';

  @override
  String get lockedCategory => 'लॉक की गई श्रेणी';

  @override
  String get confirm => 'ठीक है';

  @override
  String get pinEnterTitle => 'PIN डालें';

  @override
  String get pinWrong => 'गलत PIN';

  @override
  String get pinUnlockMessage =>
      'यह श्रेणी लॉक है। PIN डालने के बाद ऐप बंद होने तक सभी लॉक श्रेणियाँ खुली रहेंगी।';

  @override
  String get pinEditorMessage =>
      'श्रेणियों का क्रम बदलने के लिए PIN ज़रूरी है।';

  @override
  String get pinCurrentMessage => 'आगे बढ़ने के लिए मौजूदा PIN डालें।';

  @override
  String get pinRemoveMessage => 'PIN हटाने के लिए मौजूदा PIN डालें।';

  @override
  String get pinNewTitle => 'नया PIN';

  @override
  String get pinNewMessage =>
      'लॉक श्रेणियाँ खोलने के लिए 4 अंकों का PIN चुनें।';

  @override
  String get pinConfirmTitle => 'PIN की पुष्टि करें';

  @override
  String get pinConfirmMessage => 'वही PIN एक बार फिर डालें।';

  @override
  String get pinMismatch => 'दोनों PIN मेल नहीं खाते';

  @override
  String get pinSaved => 'PIN सहेजा गया';

  @override
  String get pinRemoved => 'PIN और सभी श्रेणी लॉक हटा दिए गए';

  @override
  String get locksClosed => 'लॉक श्रेणियाँ फिर से लॉक हो गईं';

  @override
  String get parentalControl => 'पैरेंटल कंट्रोल';

  @override
  String get parentalControlSubtitle =>
      'लॉक श्रेणियाँ PIN के बिना नहीं खुलतीं, और उनके चैनल खोज या होम पेज पर नहीं दिखते।';

  @override
  String get setPin => 'PIN सेट करें';

  @override
  String get setPinDetail =>
      'फिर श्रेणी संपादक में ताले वाले आइकन से श्रेणियाँ लॉक करें।';

  @override
  String get lockNow => 'अभी फिर से लॉक करें';

  @override
  String get lockNowDetail =>
      'इस सत्र में खोली गई लॉक श्रेणियाँ फिर से PIN माँगेंगी।';

  @override
  String get changePin => 'PIN बदलें';

  @override
  String get removePin => 'PIN हटाएँ';

  @override
  String get removePinDetail => 'सभी श्रेणी लॉक भी हट जाएँगे।';

  @override
  String get searchFilterAll => 'सभी';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get fullscreenGrid => 'फ़ुल स्क्रीन (F)';

  @override
  String get exitFullscreenGrid => 'फ़ुल स्क्रीन से बाहर निकलें (Esc)';
}
