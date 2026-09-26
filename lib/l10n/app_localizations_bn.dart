// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get tryAgain => 'পুনরায় চেষ্টা';

  @override
  String get cancel => 'বাতিল';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get back => 'ফিরে যান';

  @override
  String get goBack => 'ফিরে যান';

  @override
  String get backToLists => 'তালিকায় ফিরুন';

  @override
  String get delete => 'মুছুন';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get options => 'বিকল্প';

  @override
  String get clear => 'মুছে ফেলুন';

  @override
  String get play => 'চালান';

  @override
  String get liveBadge => 'লাইভ';

  @override
  String get nowBadge => 'এখন';

  @override
  String get nextLabel => 'পরে';

  @override
  String get schedule => 'অনুষ্ঠান সূচি';

  @override
  String get favoritePackages => 'প্রিয় প্যাকেজ';

  @override
  String get allCategories => 'সব বিভাগ';

  @override
  String get searchCategories => 'বিভাগ খুঁজুন';

  @override
  String get noMatchingCategory => 'মিলে যাওয়া কোনো বিভাগ নেই';

  @override
  String get addToFavoritePackages => 'প্রিয় প্যাকেজে যোগ করুন';

  @override
  String get removeFromFavoritePackages => 'প্রিয় প্যাকেজ থেকে সরান';

  @override
  String get changeSearchOrCategory => 'অনুসন্ধান বা বিভাগ পরিবর্তন করুন।';

  @override
  String get scrollBack => 'পিছনে স্ক্রল করুন';

  @override
  String get scrollForward => 'সামনে স্ক্রল করুন';

  @override
  String get muteShortcut => 'মিউট (M)';

  @override
  String get unmuteShortcut => 'শব্দ চালু (M)';

  @override
  String get ungrouped => 'গোষ্ঠীহীন';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringটি চ্যানেল',
      one: '১টি চ্যানেল',
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
      other: '$countStringটি সিনেমা',
      one: '১টি সিনেমা',
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
      other: '$countStringটি সিরিজ',
      one: '১টি সিরিজ',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি তালিকা',
      one: '১টি তালিকা',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সিজন',
      one: '১টি সিজন',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'মেয়াদ শেষ $date';
  }

  @override
  String get expired => 'মেয়াদ শেষ';

  @override
  String minutesLeft(int minutes) {
    return '$minutes মিনিট বাকি';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ঘ $minutes মি';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes মি';
  }

  @override
  String get sectionHome => 'হোম';

  @override
  String get sectionLive => 'লাইভ টিভি';

  @override
  String get sectionMovies => 'সিনেমা';

  @override
  String get sectionSeries => 'সিরিজ';

  @override
  String get sectionSearch => 'খুঁজুন';

  @override
  String get sectionLists => 'তালিকা';

  @override
  String get sectionSettings => 'সেটিংস';

  @override
  String get greetingMorning => 'সুপ্রভাত';

  @override
  String get greetingDay => 'শুভ দুপুর';

  @override
  String get greetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get greetingNight => 'শুভ রাত্রি';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName প্রস্তুত। একটি চ্যানেল খুলুন বা একটি সিনেমা বেছে নিন; যা দেখবেন তা এখানে দেখা যাবে।';
  }

  @override
  String get homeIntro =>
      'যেখানে থেমেছিলেন সেখান থেকে চালিয়ে যান বা নতুন কিছু খুঁজুন।';

  @override
  String get continueWatching => 'দেখা চালিয়ে যান';

  @override
  String get recentChannels => 'সম্প্রতি দেখা চ্যানেল';

  @override
  String get searchShortcutAll => 'চ্যানেল, সিনেমা, সিরিজ';

  @override
  String get searchShortcutChannels => 'চ্যানেলে';

  @override
  String maxSlotsReached(int max) {
    return 'একসাথে সর্বোচ্চ $maxটি চ্যানেল দেখা যায়';
  }

  @override
  String maxSlotsShort(int max) {
    return 'সর্বোচ্চ $maxটি চ্যানেল';
  }

  @override
  String get watchSideBySide => 'পাশাপাশি দেখুন';

  @override
  String get epgUpdating => 'অনুষ্ঠান সূচি হালনাগাদ হচ্ছে';

  @override
  String get epgFailed => 'অনুষ্ঠান সূচি লোড করা যায়নি';

  @override
  String get allChannels => 'সব চ্যানেল';

  @override
  String get recentlyWatched => 'সম্প্রতি দেখা';

  @override
  String get searchChannels => 'চ্যানেল খুঁজুন';

  @override
  String get noRecentChannelsTitle => 'এখনও কোনো চ্যানেল দেখেননি';

  @override
  String get noRecentChannelsMessage =>
      'আপনি যে চ্যানেল দেখবেন তা এখানে দেখা যাবে।';

  @override
  String get noChannelFound => 'কোনো চ্যানেল পাওয়া যায়নি';

  @override
  String get pickChannelTitle => 'একটি চ্যানেল বেছে নিন';

  @override
  String get pickChannelMessage =>
      'তালিকার একটি চ্যানেলে ক্লিক করুন। আরও বিকল্পের জন্য রাইট-ক্লিক করুন, অথবা পাশাপাশি দেখতে চ্যানেলের সারিতে + চাপুন।';

  @override
  String get hintChangeChannel => 'চ্যানেল বদলান';

  @override
  String get hintPreviousChannel => 'আগের চ্যানেল';

  @override
  String get hintMute => 'শব্দ বন্ধ / চালু';

  @override
  String get hintFullscreen => 'পূর্ণ পর্দা';

  @override
  String get audioInThisTile => 'এই পর্দার শব্দ';

  @override
  String get muted => 'মিউট';

  @override
  String get backToGrid => 'গ্রিডে ফিরুন';

  @override
  String get enlarge => 'বড় করুন';

  @override
  String get closeTile => 'পর্দা বন্ধ করুন';

  @override
  String reconnecting(int attempt, int max) {
    return 'সম্প্রচার আটকে গেছে, আবার সংযোগ হচ্ছে ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'চ্যানেল খোলা যায়নি';

  @override
  String get channelFailedMessage =>
      'প্রদানকারী সম্প্রচার পাঠাচ্ছে না বা সংযোগের সীমা পূর্ণ হয়েছে।';

  @override
  String get listFailedTitle => 'তালিকা খোলা যায়নি';

  @override
  String get loadingChannels => 'চ্যানেল তালিকা লোড হচ্ছে…';

  @override
  String get today => 'আজ';

  @override
  String get tomorrow => 'আগামীকাল';

  @override
  String get yesterday => 'গতকাল';

  @override
  String archiveHint(int days) {
    return 'গত $days দিন দেখা যাবে, একটি অনুষ্ঠানে ক্লিক করুন';
  }

  @override
  String get noProgrammes => 'এই চ্যানেলের কোনো অনুষ্ঠান নেই';

  @override
  String get watchFromStart => 'শুরু থেকে দেখুন';

  @override
  String get watchFromArchive => 'আর্কাইভ থেকে দেখুন';

  @override
  String get searchHintAll => 'চ্যানেল, সিনেমা বা সিরিজ খুঁজুন';

  @override
  String get searchPromptTitle => 'কী দেখতে চান?';

  @override
  String get searchPromptChannels => 'চ্যানেল খুঁজতে অন্তত দুটি অক্ষর লিখুন।';

  @override
  String get searchPromptAll =>
      'অন্তত দুটি অক্ষর লিখুন; চ্যানেল, সিনেমা ও সিরিজে একসাথে খোঁজা হবে।';

  @override
  String get channels => 'চ্যানেল';

  @override
  String loadingSection(String section) {
    return '$section লোড হচ্ছে…';
  }

  @override
  String get noResultsTitle => 'কোনো ফলাফল নেই';

  @override
  String get noResultsMessage => 'অন্য বানানে চেষ্টা করুন।';

  @override
  String get addList => 'তালিকা যোগ করুন';

  @override
  String get editList => 'তালিকা সম্পাদনা';

  @override
  String get listNameOptional => 'তালিকার নাম (ঐচ্ছিক)';

  @override
  String get listNameHint => 'যেমন বাড়ি, খেলার প্যাকেজ';

  @override
  String get serverAddress => 'সার্ভারের ঠিকানা';

  @override
  String get serverAddressHint =>
      'http://server:8080 বা আপনার প্রদানকারীর M3U লিংক';

  @override
  String get username => 'ব্যবহারকারীর নাম';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get showPassword => 'পাসওয়ার্ড দেখান';

  @override
  String get hidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get m3uLocation => 'M3U তালিকা (URL বা ফাইলের পথ)';

  @override
  String get add => 'যোগ করুন';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get errServerAndUserRequired =>
      'সার্ভারের ঠিকানা ও ব্যবহারকারীর নাম প্রয়োজন।';

  @override
  String get errLocationRequired => 'তালিকার URL বা ফাইলের পথ প্রয়োজন।';

  @override
  String errDuplicateList(String name) {
    return 'এই তালিকাটি আগেই যোগ করা হয়েছে: \"$name\"।';
  }

  @override
  String get deleteListTitle => 'তালিকা মুছবেন?';

  @override
  String deleteListMessage(String name) {
    return '\"$name\" এবং এর প্রিয় প্যাকেজ ও দেখার ইতিহাস মুছে যাবে। প্রদানকারীর কাছে আপনার অ্যাকাউন্টে কোনো প্রভাব পড়বে না।';
  }

  @override
  String get yourLists => 'আপনার তালিকা';

  @override
  String get welcomeTitle => 'Streamlity-তে স্বাগতম';

  @override
  String get welcomeMessage =>
      'শুরু করতে একটি তালিকা যোগ করুন। যত খুশি তালিকা যোগ করে সেগুলোর মধ্যে বদলাতে পারবেন।';

  @override
  String get xtreamDescription =>
      'সার্ভার, ব্যবহারকারীর নাম ও পাসওয়ার্ড। লাইভ টিভি, সিনেমা, সিরিজ।';

  @override
  String get m3uDescription => 'একটি তালিকার URL বা আপনার কম্পিউটারের ফাইল।';

  @override
  String get notOpenedYet => 'এখনও খোলা হয়নি';

  @override
  String get audioLanguage => 'অডিওর ভাষা';

  @override
  String get subtitles => 'সাবটাইটেল';

  @override
  String get subtitlesOff => 'বন্ধ';

  @override
  String trackNumber(String id) {
    return 'ট্র্যাক $id';
  }

  @override
  String get sortProvider => 'প্রদানকারীর ক্রম';

  @override
  String get sortName => 'নাম অনুসারে';

  @override
  String get sortRating => 'রেটিং অনুসারে';

  @override
  String get sortYear => 'বছর অনুসারে';

  @override
  String get moviesFailed => 'সিনেমা লোড করা যায়নি';

  @override
  String get seriesFailed => 'সিরিজ লোড করা যায়নি';

  @override
  String get allMovies => 'সব সিনেমা';

  @override
  String get allSeries => 'সব সিরিজ';

  @override
  String get searchMovies => 'সিনেমা খুঁজুন';

  @override
  String get searchSeries => 'সিরিজ খুঁজুন';

  @override
  String get noMatchingMovies => 'মিলে যাওয়া কোনো সিনেমা নেই';

  @override
  String get noMatchingSeries => 'মিলে যাওয়া কোনো সিরিজ নেই';

  @override
  String get loadingMovies => 'সিনেমা লোড হচ্ছে…';

  @override
  String get loadingSeries => 'সিরিজ লোড হচ্ছে…';

  @override
  String get noDescription => 'কোনো বিবরণ নেই।';

  @override
  String get director => 'পরিচালক';

  @override
  String get cast => 'অভিনয়ে';

  @override
  String resumeAt(String position) {
    return 'চালিয়ে যান · $position';
  }

  @override
  String get startOver => 'শুরু থেকে';

  @override
  String get seriesInfoFailed => 'সিরিজের বিবরণ লোড করা যায়নি';

  @override
  String get noEpisodes => 'এই সিরিজে কোনো পর্ব নেই';

  @override
  String seasonTab(int season, int count) {
    return 'সিজন $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'সিজন $season, পর্ব $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'S$season E$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · চালান';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · চালিয়ে যান';
  }

  @override
  String episodeFallback(int number) {
    return 'পর্ব $number';
  }

  @override
  String get watched => 'দেখা হয়েছে';

  @override
  String watchedUntil(String position) {
    return '$position পর্যন্ত দেখা হয়েছে';
  }

  @override
  String get playbackFailed => 'চালানো যায়নি';

  @override
  String errHttpStatus(int code) {
    return 'সার্ভার $code ফেরত দিয়েছে।';
  }

  @override
  String errFetchFailed(String detail) {
    return 'তালিকা লোড করা যায়নি: $detail';
  }

  @override
  String get errNoChannels => 'তালিকায় কোনো চ্যানেল পাওয়া যায়নি।';

  @override
  String get errNoLiveChannels =>
      'অ্যাকাউন্টে কোনো লাইভ চ্যানেল পাওয়া যায়নি।';

  @override
  String get errBadLogin => 'ব্যবহারকারীর নাম বা পাসওয়ার্ড ভুল।';

  @override
  String errAccountUnavailable(String status) {
    return 'অ্যাকাউন্ট উপলব্ধ নয় (অবস্থা: $status)।';
  }

  @override
  String errConnect(String detail) {
    return 'সার্ভারে সংযোগ করা যায়নি: $detail';
  }

  @override
  String get errInvalidResponse =>
      'সার্ভার কোনো বৈধ Xtream Codes উত্তর দেয়নি।';

  @override
  String get errNoMovies => 'অ্যাকাউন্টে কোনো সিনেমা পাওয়া যায়নি।';

  @override
  String get errNoSeries => 'অ্যাকাউন্টে কোনো সিরিজ পাওয়া যায়নি।';

  @override
  String errEpg(String detail) {
    return 'অনুষ্ঠান সূচি লোড করা যায়নি: $detail';
  }

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageSubtitle => 'অ্যাপের ইন্টারফেসের ভাষা';

  @override
  String get systemLanguage => 'সিস্টেমের ভাষা';

  @override
  String systemLanguageCurrent(String language) {
    return 'বর্তমানে: $language';
  }

  @override
  String get settingsAbout => 'সম্পর্কে';

  @override
  String get settingsAboutText =>
      'Windows, macOS ও Linux-এর জন্য ওপেন-সোর্স IPTV প্লেয়ার।';

  @override
  String get translationNote =>
      'অনুবাদগুলো স্বয়ংক্রিয়ভাবে তৈরি; কোনো ভুল চোখে পড়লে আমাদের জানান।';

  @override
  String get editCategories => 'বিভাগ সম্পাদনা';

  @override
  String get editCategoriesHint =>
      'ক্রম বদলাতে টেনে আনুন, লুকাতে চোখের আইকন ব্যবহার করুন।';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি লুকানো',
      zero: 'কোনো লুকানো বিভাগ নেই',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'মিলে যাওয়াগুলো লুকান ($count)';
  }

  @override
  String showMatching(int count) {
    return 'মিলে যাওয়াগুলো দেখান ($count)';
  }

  @override
  String get moveToTop => 'সবার উপরে নিন';

  @override
  String get hideCategory => 'লুকান';

  @override
  String get showCategory => 'দেখান';

  @override
  String get reset => 'রিসেট';

  @override
  String get dragToReorder => 'ক্রম বদলাতে টেনে আনুন';
}
