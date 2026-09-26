// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get goBack => 'العودة';

  @override
  String get backToLists => 'العودة إلى القوائم';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get options => 'خيارات';

  @override
  String get clear => 'مسح';

  @override
  String get play => 'تشغيل';

  @override
  String get liveBadge => 'مباشر';

  @override
  String get nowBadge => 'الآن';

  @override
  String get nextLabel => 'التالي';

  @override
  String get schedule => 'دليل البرامج';

  @override
  String get favoritePackages => 'الباقات المفضلة';

  @override
  String get allCategories => 'كل الفئات';

  @override
  String get searchCategories => 'البحث في الفئات';

  @override
  String get noMatchingCategory => 'لا توجد فئة مطابقة';

  @override
  String get addToFavoritePackages => 'إضافة إلى الباقات المفضلة';

  @override
  String get removeFromFavoritePackages => 'إزالة من الباقات المفضلة';

  @override
  String get changeSearchOrCategory => 'غيّر البحث أو الفئة.';

  @override
  String get scrollBack => 'التمرير للخلف';

  @override
  String get scrollForward => 'التمرير للأمام';

  @override
  String get muteShortcut => 'كتم الصوت (M)';

  @override
  String get unmuteShortcut => 'تشغيل الصوت (M)';

  @override
  String get ungrouped => 'بلا مجموعة';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString قناة',
      many: '$countString قناة',
      few: '$countString قنوات',
      two: 'قناتان',
      one: 'قناة واحدة',
      zero: 'لا قنوات',
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
      other: '$countString فيلم',
      many: '$countString فيلمًا',
      few: '$countString أفلام',
      two: 'فيلمان',
      one: 'فيلم واحد',
      zero: 'لا أفلام',
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
      other: '$countString مسلسل',
      many: '$countString مسلسلًا',
      few: '$countString مسلسلات',
      two: 'مسلسلان',
      one: 'مسلسل واحد',
      zero: 'لا مسلسلات',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قائمة',
      many: '$count قائمة',
      few: '$count قوائم',
      two: 'قائمتان',
      one: 'قائمة واحدة',
      zero: 'لا قوائم',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موسم',
      many: '$count موسمًا',
      few: '$count مواسم',
      two: 'موسمان',
      one: 'موسم واحد',
      zero: 'لا مواسم',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'ينتهي في $date';
  }

  @override
  String get expired => 'منتهي الصلاحية';

  @override
  String minutesLeft(int minutes) {
    return 'متبقٍ $minutes د';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String get sectionHome => 'الرئيسية';

  @override
  String get sectionLive => 'البث المباشر';

  @override
  String get sectionMovies => 'الأفلام';

  @override
  String get sectionSeries => 'المسلسلات';

  @override
  String get sectionSearch => 'بحث';

  @override
  String get sectionLists => 'القوائم';

  @override
  String get sectionSettings => 'الإعدادات';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingDay => 'طاب يومك';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get greetingNight => 'تصبح على خير';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName جاهزة. افتح قناة أو اختر فيلمًا، وسيظهر ما تشاهده هنا.';
  }

  @override
  String get homeIntro => 'تابع من حيث توقفت أو اكتشف شيئًا جديدًا.';

  @override
  String get continueWatching => 'متابعة المشاهدة';

  @override
  String get recentChannels => 'القنوات التي شاهدتها مؤخرًا';

  @override
  String get searchShortcutAll => 'قنوات، أفلام، مسلسلات';

  @override
  String get searchShortcutChannels => 'في القنوات';

  @override
  String maxSlotsReached(int max) {
    return 'يمكنك مشاهدة $max قنوات كحد أقصى في الوقت نفسه';
  }

  @override
  String maxSlotsShort(int max) {
    return '$max قنوات كحد أقصى';
  }

  @override
  String get watchSideBySide => 'المشاهدة جنبًا إلى جنب';

  @override
  String get epgUpdating => 'جارٍ تحديث دليل البرامج';

  @override
  String get epgFailed => 'تعذّر تحميل دليل البرامج';

  @override
  String get allChannels => 'كل القنوات';

  @override
  String get recentlyWatched => 'شوهدت مؤخرًا';

  @override
  String get searchChannels => 'البحث عن قناة';

  @override
  String get noRecentChannelsTitle => 'لم تشاهد أي قناة بعد';

  @override
  String get noRecentChannelsMessage => 'ستظهر هنا القنوات التي تشاهدها.';

  @override
  String get noChannelFound => 'لم يتم العثور على قنوات';

  @override
  String get pickChannelTitle => 'اختر قناة';

  @override
  String get pickChannelMessage =>
      'انقر على قناة في القائمة. انقر بزر الفأرة الأيمن لخيارات أكثر، أو استخدم + في صف القناة للمشاهدة جنبًا إلى جنب.';

  @override
  String get hintChangeChannel => 'تغيير القناة';

  @override
  String get hintPreviousChannel => 'القناة السابقة';

  @override
  String get hintMute => 'كتم / تشغيل الصوت';

  @override
  String get hintFullscreen => 'ملء الشاشة';

  @override
  String get audioInThisTile => 'الصوت من هذه النافذة';

  @override
  String get muted => 'مكتوم';

  @override
  String get backToGrid => 'العودة إلى الشبكة';

  @override
  String get enlarge => 'تكبير';

  @override
  String get closeTile => 'إغلاق النافذة';

  @override
  String reconnecting(int attempt, int max) {
    return 'توقف البث، جارٍ إعادة الاتصال ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'تعذّر فتح القناة';

  @override
  String get channelFailedMessage =>
      'المزوّد لا يرسل البث أو تم بلوغ حد الاتصالات.';

  @override
  String get listFailedTitle => 'تعذّر فتح القائمة';

  @override
  String get loadingChannels => 'جارٍ تحميل قائمة القنوات…';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدًا';

  @override
  String get yesterday => 'أمس';

  @override
  String archiveHint(int days) {
    return 'متاح لآخر $days أيام، انقر على برنامج';
  }

  @override
  String get noProgrammes => 'لا توجد برامج لهذه القناة';

  @override
  String get watchFromStart => 'المشاهدة من البداية';

  @override
  String get watchFromArchive => 'المشاهدة من الأرشيف';

  @override
  String get searchHintAll => 'ابحث عن قنوات أو أفلام أو مسلسلات';

  @override
  String get searchPromptTitle => 'ماذا تريد أن تشاهد؟';

  @override
  String get searchPromptChannels => 'اكتب حرفين على الأقل للبحث في القنوات.';

  @override
  String get searchPromptAll =>
      'اكتب حرفين على الأقل للبحث في القنوات والأفلام والمسلسلات معًا.';

  @override
  String get channels => 'القنوات';

  @override
  String loadingSection(String section) {
    return 'جارٍ تحميل $section…';
  }

  @override
  String get noResultsTitle => 'لا توجد نتائج';

  @override
  String get noResultsMessage => 'جرّب تهجئة مختلفة.';

  @override
  String get addList => 'إضافة قائمة';

  @override
  String get editList => 'تعديل القائمة';

  @override
  String get listNameOptional => 'اسم القائمة (اختياري)';

  @override
  String get listNameHint => 'مثل: المنزل، باقة الرياضة';

  @override
  String get serverAddress => 'عنوان الخادم';

  @override
  String get serverAddressHint => 'http://server:8080 أو رابط M3U من مزوّدك';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get m3uLocation => 'قائمة M3U (رابط أو مسار ملف)';

  @override
  String get add => 'إضافة';

  @override
  String get save => 'حفظ';

  @override
  String get errServerAndUserRequired => 'عنوان الخادم واسم المستخدم مطلوبان.';

  @override
  String get errLocationRequired => 'رابط القائمة أو مسار الملف مطلوب.';

  @override
  String errDuplicateList(String name) {
    return 'هذه القائمة مضافة بالفعل: «$name».';
  }

  @override
  String get deleteListTitle => 'حذف القائمة؟';

  @override
  String deleteListMessage(String name) {
    return 'سيتم حذف «$name» مع باقاتها المفضلة وسجل المشاهدة. لن يتأثر حسابك لدى المزوّد.';
  }

  @override
  String get yourLists => 'قوائمك';

  @override
  String get welcomeTitle => 'مرحبًا بك في Streamlity';

  @override
  String get welcomeMessage =>
      'أضف قائمة للبدء. يمكنك إضافة أي عدد من القوائم والتنقل بينها.';

  @override
  String get xtreamDescription =>
      'الخادم واسم المستخدم وكلمة المرور. بث مباشر، أفلام، مسلسلات.';

  @override
  String get m3uDescription => 'رابط قائمة أو ملف على جهازك.';

  @override
  String get notOpenedYet => 'لم تُفتح بعد';

  @override
  String get audioLanguage => 'لغة الصوت';

  @override
  String get subtitles => 'الترجمة';

  @override
  String get subtitlesOff => 'إيقاف';

  @override
  String trackNumber(String id) {
    return 'المسار $id';
  }

  @override
  String get sortProvider => 'ترتيب المزوّد';

  @override
  String get sortName => 'حسب الاسم';

  @override
  String get sortRating => 'حسب التقييم';

  @override
  String get sortYear => 'حسب السنة';

  @override
  String get moviesFailed => 'تعذّر تحميل الأفلام';

  @override
  String get seriesFailed => 'تعذّر تحميل المسلسلات';

  @override
  String get allMovies => 'كل الأفلام';

  @override
  String get allSeries => 'كل المسلسلات';

  @override
  String get searchMovies => 'البحث عن فيلم';

  @override
  String get searchSeries => 'البحث عن مسلسل';

  @override
  String get noMatchingMovies => 'لا توجد أفلام مطابقة';

  @override
  String get noMatchingSeries => 'لا توجد مسلسلات مطابقة';

  @override
  String get loadingMovies => 'جارٍ تحميل الأفلام…';

  @override
  String get loadingSeries => 'جارٍ تحميل المسلسلات…';

  @override
  String get noDescription => 'لا يوجد وصف.';

  @override
  String get director => 'الإخراج';

  @override
  String get cast => 'البطولة';

  @override
  String resumeAt(String position) {
    return 'متابعة · $position';
  }

  @override
  String get startOver => 'البدء من جديد';

  @override
  String get seriesInfoFailed => 'تعذّر تحميل تفاصيل المسلسل';

  @override
  String get noEpisodes => 'لا توجد حلقات في هذا المسلسل';

  @override
  String seasonTab(int season, int count) {
    return 'الموسم $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'الموسم $season، الحلقة $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'م$season ح$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · تشغيل';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · متابعة';
  }

  @override
  String episodeFallback(int number) {
    return 'الحلقة $number';
  }

  @override
  String get watched => 'تمت المشاهدة';

  @override
  String watchedUntil(String position) {
    return 'تمت المشاهدة حتى $position';
  }

  @override
  String get playbackFailed => 'تعذّر التشغيل';

  @override
  String errHttpStatus(int code) {
    return 'أعاد الخادم الرمز $code.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'تعذّر تحميل القائمة: $detail';
  }

  @override
  String get errNoChannels => 'لم يتم العثور على قنوات في القائمة.';

  @override
  String get errNoLiveChannels => 'لم يتم العثور على قنوات مباشرة في الحساب.';

  @override
  String get errBadLogin => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String errAccountUnavailable(String status) {
    return 'الحساب غير متاح (الحالة: $status).';
  }

  @override
  String errConnect(String detail) {
    return 'تعذّر الاتصال بالخادم: $detail';
  }

  @override
  String get errInvalidResponse =>
      'لم يُرجع الخادم ردًّا صالحًا من Xtream Codes.';

  @override
  String get errNoMovies => 'لم يتم العثور على أفلام في الحساب.';

  @override
  String get errNoSeries => 'لم يتم العثور على مسلسلات في الحساب.';

  @override
  String errEpg(String detail) {
    return 'تعذّر تحميل دليل البرامج: $detail';
  }

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSubtitle => 'لغة واجهة التطبيق';

  @override
  String get systemLanguage => 'لغة النظام';

  @override
  String systemLanguageCurrent(String language) {
    return 'الحالية: $language';
  }

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsAboutText =>
      'مشغل IPTV مفتوح المصدر لأنظمة Windows وmacOS وLinux.';

  @override
  String get translationNote => 'أُعدّت الترجمات آليًا؛ أخبرنا إن لاحظت خطأً.';

  @override
  String get editCategories => 'تعديل الفئات';

  @override
  String get editCategoriesHint =>
      'اسحب لإعادة الترتيب، واستخدم أيقونة العين للإخفاء وأيقونة القفل لطلب رمز PIN.';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فئة مخفية',
      many: '$count فئة مخفية',
      few: '$count فئات مخفية',
      two: 'فئتان مخفيتان',
      one: 'فئة مخفية واحدة',
      zero: 'لا توجد فئات مخفية',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'إخفاء المطابقات ($count)';
  }

  @override
  String showMatching(int count) {
    return 'إظهار المطابقات ($count)';
  }

  @override
  String get moveToTop => 'النقل إلى الأعلى';

  @override
  String get hideCategory => 'إخفاء';

  @override
  String get showCategory => 'إظهار';

  @override
  String get reset => 'إعادة الضبط';

  @override
  String get dragToReorder => 'اسحب لإعادة الترتيب';

  @override
  String lockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فئة مقفلة',
      many: '$count فئة مقفلة',
      few: '$count فئات مقفلة',
      two: 'فئتان مقفلتان',
      one: 'فئة مقفلة واحدة',
      zero: 'لا توجد فئات مقفلة',
    );
    return '$_temp0';
  }

  @override
  String get lockCategory => 'قفل';

  @override
  String get unlockCategory => 'إزالة القفل';

  @override
  String get lockedCategory => 'فئة مقفلة';

  @override
  String get confirm => 'موافق';

  @override
  String get pinEnterTitle => 'أدخل رمز PIN';

  @override
  String get pinWrong => 'رمز PIN غير صحيح';

  @override
  String get pinUnlockMessage =>
      'هذه الفئة مقفلة. بعد إدخال رمز PIN تبقى كل الفئات المقفلة مفتوحة حتى يُغلق التطبيق.';

  @override
  String get pinEditorMessage => 'يلزم رمز PIN لتغيير ترتيب الفئات.';

  @override
  String get pinCurrentMessage => 'أدخل رمز PIN الحالي للمتابعة.';

  @override
  String get pinRemoveMessage => 'أدخل رمز PIN الحالي لإزالته.';

  @override
  String get pinNewTitle => 'رمز PIN جديد';

  @override
  String get pinNewMessage => 'اختر رمز PIN من 4 أرقام لفتح الفئات المقفلة.';

  @override
  String get pinConfirmTitle => 'تأكيد رمز PIN';

  @override
  String get pinConfirmMessage => 'أدخل رمز PIN نفسه مرة أخرى.';

  @override
  String get pinMismatch => 'رمزا PIN غير متطابقين';

  @override
  String get pinSaved => 'تم حفظ رمز PIN';

  @override
  String get pinRemoved => 'أُزيل رمز PIN وجميع أقفال الفئات';

  @override
  String get locksClosed => 'أُعيد قفل الفئات المقفلة';

  @override
  String get parentalControl => 'الرقابة الأبوية';

  @override
  String get parentalControlSubtitle =>
      'لا تُفتح الفئات المقفلة دون رمز PIN، ولا تظهر قنواتها في البحث أو في الصفحة الرئيسية.';

  @override
  String get setPin => 'تعيين رمز PIN';

  @override
  String get setPinDetail => 'ثم اقفل الفئات بأيقونة القفل في محرر الفئات.';

  @override
  String get lockNow => 'أعد القفل الآن';

  @override
  String get lockNowDetail =>
      'ستطلب الفئات المقفلة التي فُتحت في هذه الجلسة رمز PIN مجددًا.';

  @override
  String get changePin => 'تغيير رمز PIN';

  @override
  String get removePin => 'إزالة رمز PIN';

  @override
  String get removePinDetail => 'تُزال أيضًا جميع أقفال الفئات.';

  @override
  String get searchFilterAll => 'الكل';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get fullscreenGrid => 'ملء الشاشة (F)';

  @override
  String get exitFullscreenGrid => 'الخروج من ملء الشاشة (Esc)';
}
