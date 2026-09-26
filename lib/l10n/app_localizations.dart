import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Streamlity'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @tryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden dene'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @goBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri dön'**
  String get goBack;

  /// No description provided for @backToLists.
  ///
  /// In tr, this message translates to:
  /// **'Listelere dön'**
  String get backToLists;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @options.
  ///
  /// In tr, this message translates to:
  /// **'Seçenekler'**
  String get options;

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// No description provided for @play.
  ///
  /// In tr, this message translates to:
  /// **'Oynat'**
  String get play;

  /// No description provided for @liveBadge.
  ///
  /// In tr, this message translates to:
  /// **'CANLI'**
  String get liveBadge;

  /// No description provided for @nowBadge.
  ///
  /// In tr, this message translates to:
  /// **'ŞİMDİ'**
  String get nowBadge;

  /// No description provided for @nextLabel.
  ///
  /// In tr, this message translates to:
  /// **'SONRA'**
  String get nextLabel;

  /// No description provided for @schedule.
  ///
  /// In tr, this message translates to:
  /// **'Yayın akışı'**
  String get schedule;

  /// No description provided for @favoritePackages.
  ///
  /// In tr, this message translates to:
  /// **'Favori paketler'**
  String get favoritePackages;

  /// No description provided for @allCategories.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kategoriler'**
  String get allCategories;

  /// No description provided for @searchCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategori ara'**
  String get searchCategories;

  /// No description provided for @noMatchingCategory.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen kategori yok'**
  String get noMatchingCategory;

  /// No description provided for @addToFavoritePackages.
  ///
  /// In tr, this message translates to:
  /// **'Favori paketlere ekle'**
  String get addToFavoritePackages;

  /// No description provided for @removeFromFavoritePackages.
  ///
  /// In tr, this message translates to:
  /// **'Favori paketlerden çıkar'**
  String get removeFromFavoritePackages;

  /// No description provided for @changeSearchOrCategory.
  ///
  /// In tr, this message translates to:
  /// **'Aramayı ya da kategoriyi değiştir.'**
  String get changeSearchOrCategory;

  /// No description provided for @scrollBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri kaydır'**
  String get scrollBack;

  /// No description provided for @scrollForward.
  ///
  /// In tr, this message translates to:
  /// **'İleri kaydır'**
  String get scrollForward;

  /// No description provided for @muteShortcut.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz (M)'**
  String get muteShortcut;

  /// No description provided for @unmuteShortcut.
  ///
  /// In tr, this message translates to:
  /// **'Sesi aç (M)'**
  String get unmuteShortcut;

  /// No description provided for @ungrouped.
  ///
  /// In tr, this message translates to:
  /// **'Grupsuz'**
  String get ungrouped;

  /// No description provided for @channelCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 kanal} other{{count} kanal}}'**
  String channelCount(int count);

  /// No description provided for @movieCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 film} other{{count} film}}'**
  String movieCount(int count);

  /// No description provided for @seriesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 dizi} other{{count} dizi}}'**
  String seriesCount(int count);

  /// No description provided for @listCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 liste} other{{count} liste}}'**
  String listCount(int count);

  /// No description provided for @seasonCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 sezon} other{{count} sezon}}'**
  String seasonCount(int count);

  /// No description provided for @expiresOn.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş {date}'**
  String expiresOn(String date);

  /// No description provided for @expired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi doldu'**
  String get expired;

  /// No description provided for @minutesLeft.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk kaldı'**
  String minutesLeft(int minutes);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{hours} sa {minutes} dk'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk'**
  String durationMinutes(int minutes);

  /// No description provided for @sectionHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfa'**
  String get sectionHome;

  /// No description provided for @sectionLive.
  ///
  /// In tr, this message translates to:
  /// **'Canlı TV'**
  String get sectionLive;

  /// No description provided for @sectionMovies.
  ///
  /// In tr, this message translates to:
  /// **'Filmler'**
  String get sectionMovies;

  /// No description provided for @sectionSeries.
  ///
  /// In tr, this message translates to:
  /// **'Diziler'**
  String get sectionSeries;

  /// No description provided for @sectionSearch.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get sectionSearch;

  /// No description provided for @sectionLists.
  ///
  /// In tr, this message translates to:
  /// **'Listeler'**
  String get sectionLists;

  /// No description provided for @sectionSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get sectionSettings;

  /// No description provided for @greetingMorning.
  ///
  /// In tr, this message translates to:
  /// **'Günaydın'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In tr, this message translates to:
  /// **'İyi günler'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In tr, this message translates to:
  /// **'İyi akşamlar'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In tr, this message translates to:
  /// **'İyi geceler'**
  String get greetingNight;

  /// No description provided for @homeIntroEmpty.
  ///
  /// In tr, this message translates to:
  /// **'{listName} hazır. Bir kanal aç ya da film seç, izlediklerin burada birikir.'**
  String homeIntroEmpty(String listName);

  /// No description provided for @homeIntro.
  ///
  /// In tr, this message translates to:
  /// **'Kaldığın yerden devam et ya da yeni bir şey keşfet.'**
  String get homeIntro;

  /// No description provided for @continueWatching.
  ///
  /// In tr, this message translates to:
  /// **'İzlemeye devam et'**
  String get continueWatching;

  /// No description provided for @recentChannels.
  ///
  /// In tr, this message translates to:
  /// **'Son izlenen kanallar'**
  String get recentChannels;

  /// No description provided for @searchShortcutAll.
  ///
  /// In tr, this message translates to:
  /// **'Kanal, film, dizi'**
  String get searchShortcutAll;

  /// No description provided for @searchShortcutChannels.
  ///
  /// In tr, this message translates to:
  /// **'Kanallarda'**
  String get searchShortcutChannels;

  /// No description provided for @maxSlotsReached.
  ///
  /// In tr, this message translates to:
  /// **'Aynı anda en fazla {max} kanal izlenebilir'**
  String maxSlotsReached(int max);

  /// No description provided for @maxSlotsShort.
  ///
  /// In tr, this message translates to:
  /// **'En fazla {max} kanal'**
  String maxSlotsShort(int max);

  /// No description provided for @watchSideBySide.
  ///
  /// In tr, this message translates to:
  /// **'Yan yana izle'**
  String get watchSideBySide;

  /// No description provided for @epgUpdating.
  ///
  /// In tr, this message translates to:
  /// **'Yayın akışı güncelleniyor'**
  String get epgUpdating;

  /// No description provided for @epgFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yayın akışı alınamadı'**
  String get epgFailed;

  /// No description provided for @allChannels.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kanallar'**
  String get allChannels;

  /// No description provided for @recentlyWatched.
  ///
  /// In tr, this message translates to:
  /// **'Son izlenenler'**
  String get recentlyWatched;

  /// No description provided for @searchChannels.
  ///
  /// In tr, this message translates to:
  /// **'Kanal ara'**
  String get searchChannels;

  /// No description provided for @noRecentChannelsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kanal izlemedin'**
  String get noRecentChannelsTitle;

  /// No description provided for @noRecentChannelsMessage.
  ///
  /// In tr, this message translates to:
  /// **'İzlediğin kanallar burada görünür.'**
  String get noRecentChannelsMessage;

  /// No description provided for @noChannelFound.
  ///
  /// In tr, this message translates to:
  /// **'Kanal bulunamadı'**
  String get noChannelFound;

  /// No description provided for @pickChannelTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir kanal seç'**
  String get pickChannelTitle;

  /// No description provided for @pickChannelMessage.
  ///
  /// In tr, this message translates to:
  /// **'Listeden bir kanala tıkla. Sağ tıkla daha fazla seçenek, kanal satırındaki + ile yan yana izleme.'**
  String get pickChannelMessage;

  /// No description provided for @hintChangeChannel.
  ///
  /// In tr, this message translates to:
  /// **'Kanal değiştir'**
  String get hintChangeChannel;

  /// No description provided for @hintPreviousChannel.
  ///
  /// In tr, this message translates to:
  /// **'Önceki kanal'**
  String get hintPreviousChannel;

  /// No description provided for @hintMute.
  ///
  /// In tr, this message translates to:
  /// **'Sesi kapat / aç'**
  String get hintMute;

  /// No description provided for @hintFullscreen.
  ///
  /// In tr, this message translates to:
  /// **'Tam ekran'**
  String get hintFullscreen;

  /// No description provided for @audioInThisTile.
  ///
  /// In tr, this message translates to:
  /// **'Ses bu karede'**
  String get audioInThisTile;

  /// No description provided for @muted.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz'**
  String get muted;

  /// No description provided for @backToGrid.
  ///
  /// In tr, this message translates to:
  /// **'Izgaraya dön'**
  String get backToGrid;

  /// No description provided for @enlarge.
  ///
  /// In tr, this message translates to:
  /// **'Büyüt'**
  String get enlarge;

  /// No description provided for @closeTile.
  ///
  /// In tr, this message translates to:
  /// **'Kareyi kapat'**
  String get closeTile;

  /// No description provided for @reconnecting.
  ///
  /// In tr, this message translates to:
  /// **'Yayın gelmiyor, yeniden bağlanılıyor ({attempt}/{max})'**
  String reconnecting(int attempt, int max);

  /// No description provided for @channelFailedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kanal açılamadı'**
  String get channelFailedTitle;

  /// No description provided for @channelFailedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Sağlayıcı yayın göndermiyor ya da bağlantı sınırı dolu.'**
  String get channelFailedMessage;

  /// No description provided for @listFailedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Liste açılamadı'**
  String get listFailedTitle;

  /// No description provided for @loadingChannels.
  ///
  /// In tr, this message translates to:
  /// **'Kanal listesi yükleniyor…'**
  String get loadingChannels;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  /// No description provided for @archiveHint.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş {days} gün izlenebilir, programa tıkla'**
  String archiveHint(int days);

  /// No description provided for @noProgrammes.
  ///
  /// In tr, this message translates to:
  /// **'Bu kanal için program yok'**
  String get noProgrammes;

  /// No description provided for @watchFromStart.
  ///
  /// In tr, this message translates to:
  /// **'Baştan izle'**
  String get watchFromStart;

  /// No description provided for @watchFromArchive.
  ///
  /// In tr, this message translates to:
  /// **'Geçmişten izle'**
  String get watchFromArchive;

  /// No description provided for @searchHintAll.
  ///
  /// In tr, this message translates to:
  /// **'Kanal, film ya da dizi ara'**
  String get searchHintAll;

  /// No description provided for @searchPromptTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ne izlemek istersin?'**
  String get searchPromptTitle;

  /// No description provided for @searchPromptChannels.
  ///
  /// In tr, this message translates to:
  /// **'En az iki harf yaz; kanallarda aranır.'**
  String get searchPromptChannels;

  /// No description provided for @searchPromptAll.
  ///
  /// In tr, this message translates to:
  /// **'En az iki harf yaz; kanallarda, filmlerde ve dizilerde aynı anda aranır.'**
  String get searchPromptAll;

  /// No description provided for @channels.
  ///
  /// In tr, this message translates to:
  /// **'Kanallar'**
  String get channels;

  /// No description provided for @loadingSection.
  ///
  /// In tr, this message translates to:
  /// **'{section} yükleniyor…'**
  String loadingSection(String section);

  /// No description provided for @noResultsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResultsTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In tr, this message translates to:
  /// **'Farklı bir yazımla dene; Türkçe harfler fark etmez.'**
  String get noResultsMessage;

  /// No description provided for @addList.
  ///
  /// In tr, this message translates to:
  /// **'Liste ekle'**
  String get addList;

  /// No description provided for @editList.
  ///
  /// In tr, this message translates to:
  /// **'Listeyi düzenle'**
  String get editList;

  /// No description provided for @listNameOptional.
  ///
  /// In tr, this message translates to:
  /// **'Liste adı (isteğe bağlı)'**
  String get listNameOptional;

  /// No description provided for @listNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Ev, Spor paketi'**
  String get listNameHint;

  /// No description provided for @serverAddress.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu adresi'**
  String get serverAddress;

  /// No description provided for @serverAddressHint.
  ///
  /// In tr, this message translates to:
  /// **'http://sunucu:8080 veya sağlayıcının M3U linki'**
  String get serverAddressHint;

  /// No description provided for @username.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get username;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get hidePassword;

  /// No description provided for @m3uLocation.
  ///
  /// In tr, this message translates to:
  /// **'M3U listesi (URL veya dosya yolu)'**
  String get m3uLocation;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @errServerAndUserRequired.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu adresi ve kullanıcı adı gerekli.'**
  String get errServerAndUserRequired;

  /// No description provided for @errLocationRequired.
  ///
  /// In tr, this message translates to:
  /// **'Liste adresi ya da dosya yolu gerekli.'**
  String get errLocationRequired;

  /// No description provided for @errDuplicateList.
  ///
  /// In tr, this message translates to:
  /// **'Bu liste zaten ekli: \"{name}\".'**
  String errDuplicateList(String name);

  /// No description provided for @deleteListTitle.
  ///
  /// In tr, this message translates to:
  /// **'Liste silinsin mi?'**
  String get deleteListTitle;

  /// No description provided for @deleteListMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\", favori paketleri ve son izlenenleri silinecek. Sağlayıcıdaki hesabın etkilenmez.'**
  String deleteListMessage(String name);

  /// No description provided for @yourLists.
  ///
  /// In tr, this message translates to:
  /// **'Listelerin'**
  String get yourLists;

  /// No description provided for @welcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Streamlity\'ye hoş geldin'**
  String get welcomeTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In tr, this message translates to:
  /// **'Başlamak için bir liste ekle. İstediğin kadar liste ekleyip aralarında geçiş yapabilirsin.'**
  String get welcomeMessage;

  /// No description provided for @xtreamDescription.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu, kullanıcı adı ve şifre. Canlı TV, film, dizi.'**
  String get xtreamDescription;

  /// No description provided for @m3uDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bir liste adresi ya da bilgisayardaki dosya.'**
  String get m3uDescription;

  /// No description provided for @notOpenedYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz açılmadı'**
  String get notOpenedYet;

  /// No description provided for @audioLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Ses dili'**
  String get audioLanguage;

  /// No description provided for @subtitles.
  ///
  /// In tr, this message translates to:
  /// **'Altyazı'**
  String get subtitles;

  /// No description provided for @subtitlesOff.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get subtitlesOff;

  /// No description provided for @trackNumber.
  ///
  /// In tr, this message translates to:
  /// **'Parça {id}'**
  String trackNumber(String id);

  /// No description provided for @sortProvider.
  ///
  /// In tr, this message translates to:
  /// **'Sağlayıcı sırası'**
  String get sortProvider;

  /// No description provided for @sortName.
  ///
  /// In tr, this message translates to:
  /// **'Ada göre'**
  String get sortName;

  /// No description provided for @sortRating.
  ///
  /// In tr, this message translates to:
  /// **'Puana göre'**
  String get sortRating;

  /// No description provided for @sortYear.
  ///
  /// In tr, this message translates to:
  /// **'Yıla göre'**
  String get sortYear;

  /// No description provided for @moviesFailed.
  ///
  /// In tr, this message translates to:
  /// **'Filmler alınamadı'**
  String get moviesFailed;

  /// No description provided for @seriesFailed.
  ///
  /// In tr, this message translates to:
  /// **'Diziler alınamadı'**
  String get seriesFailed;

  /// No description provided for @allMovies.
  ///
  /// In tr, this message translates to:
  /// **'Tüm filmler'**
  String get allMovies;

  /// No description provided for @allSeries.
  ///
  /// In tr, this message translates to:
  /// **'Tüm diziler'**
  String get allSeries;

  /// No description provided for @searchMovies.
  ///
  /// In tr, this message translates to:
  /// **'Film ara'**
  String get searchMovies;

  /// No description provided for @searchSeries.
  ///
  /// In tr, this message translates to:
  /// **'Dizi ara'**
  String get searchSeries;

  /// No description provided for @noMatchingMovies.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen film yok'**
  String get noMatchingMovies;

  /// No description provided for @noMatchingSeries.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen dizi yok'**
  String get noMatchingSeries;

  /// No description provided for @loadingMovies.
  ///
  /// In tr, this message translates to:
  /// **'Filmler yükleniyor…'**
  String get loadingMovies;

  /// No description provided for @loadingSeries.
  ///
  /// In tr, this message translates to:
  /// **'Diziler yükleniyor…'**
  String get loadingSeries;

  /// No description provided for @noDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama yok.'**
  String get noDescription;

  /// No description provided for @director.
  ///
  /// In tr, this message translates to:
  /// **'Yönetmen'**
  String get director;

  /// No description provided for @cast.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncular'**
  String get cast;

  /// No description provided for @resumeAt.
  ///
  /// In tr, this message translates to:
  /// **'Devam et · {position}'**
  String resumeAt(String position);

  /// No description provided for @startOver.
  ///
  /// In tr, this message translates to:
  /// **'Baştan başla'**
  String get startOver;

  /// No description provided for @seriesInfoFailed.
  ///
  /// In tr, this message translates to:
  /// **'Dizi bilgisi alınamadı'**
  String get seriesInfoFailed;

  /// No description provided for @noEpisodes.
  ///
  /// In tr, this message translates to:
  /// **'Bu dizide bölüm yok'**
  String get noEpisodes;

  /// No description provided for @seasonTab.
  ///
  /// In tr, this message translates to:
  /// **'{season}. sezon · {count}'**
  String seasonTab(int season, int count);

  /// No description provided for @episodeLong.
  ///
  /// In tr, this message translates to:
  /// **'{season}. sezon {episode}. bölüm · {title}'**
  String episodeLong(int season, int episode, String title);

  /// No description provided for @episodeCode.
  ///
  /// In tr, this message translates to:
  /// **'S{season} B{episode}'**
  String episodeCode(int season, int episode);

  /// No description provided for @playEpisode.
  ///
  /// In tr, this message translates to:
  /// **'{code} · Oynat'**
  String playEpisode(String code);

  /// No description provided for @resumeEpisode.
  ///
  /// In tr, this message translates to:
  /// **'{code} · Devam et'**
  String resumeEpisode(String code);

  /// No description provided for @episodeFallback.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm {number}'**
  String episodeFallback(int number);

  /// No description provided for @watched.
  ///
  /// In tr, this message translates to:
  /// **'İzlendi'**
  String get watched;

  /// No description provided for @watchedUntil.
  ///
  /// In tr, this message translates to:
  /// **'{position} izlendi'**
  String watchedUntil(String position);

  /// No description provided for @playbackFailed.
  ///
  /// In tr, this message translates to:
  /// **'Oynatılamadı'**
  String get playbackFailed;

  /// No description provided for @errHttpStatus.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu {code} döndürdü.'**
  String errHttpStatus(int code);

  /// No description provided for @errFetchFailed.
  ///
  /// In tr, this message translates to:
  /// **'Liste alınamadı: {detail}'**
  String errFetchFailed(String detail);

  /// No description provided for @errNoChannels.
  ///
  /// In tr, this message translates to:
  /// **'Listede kanal bulunamadı.'**
  String get errNoChannels;

  /// No description provided for @errNoLiveChannels.
  ///
  /// In tr, this message translates to:
  /// **'Hesapta canlı kanal bulunamadı.'**
  String get errNoLiveChannels;

  /// No description provided for @errBadLogin.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı veya şifre hatalı.'**
  String get errBadLogin;

  /// No description provided for @errAccountUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Hesap kullanılamıyor (durum: {status}).'**
  String errAccountUnavailable(String status);

  /// No description provided for @errConnect.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya bağlanılamadı: {detail}'**
  String errConnect(String detail);

  /// No description provided for @errInvalidResponse.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu geçerli bir Xtream Codes yanıtı vermedi.'**
  String get errInvalidResponse;

  /// No description provided for @errNoMovies.
  ///
  /// In tr, this message translates to:
  /// **'Hesapta film bulunamadı.'**
  String get errNoMovies;

  /// No description provided for @errNoSeries.
  ///
  /// In tr, this message translates to:
  /// **'Hesapta dizi bulunamadı.'**
  String get errNoSeries;

  /// No description provided for @errEpg.
  ///
  /// In tr, this message translates to:
  /// **'Yayın akışı alınamadı: {detail}'**
  String errEpg(String detail);

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanın arayüz dili'**
  String get settingsLanguageSubtitle;

  /// No description provided for @systemLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Sistem dili'**
  String get systemLanguage;

  /// No description provided for @systemLanguageCurrent.
  ///
  /// In tr, this message translates to:
  /// **'Şu an: {language}'**
  String systemLanguageCurrent(String language);

  /// No description provided for @settingsAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsAbout;

  /// No description provided for @settingsAboutText.
  ///
  /// In tr, this message translates to:
  /// **'Windows, macOS ve Linux için açık kaynak IPTV oynatıcısı.'**
  String get settingsAboutText;

  /// No description provided for @translationNote.
  ///
  /// In tr, this message translates to:
  /// **'Çeviriler otomatik hazırlandı; hata görürsen bildir.'**
  String get translationNote;

  /// No description provided for @editCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategorileri düzenle'**
  String get editCategories;

  /// No description provided for @editCategoriesHint.
  ///
  /// In tr, this message translates to:
  /// **'Sürükleyerek sırala, göz simgesiyle gizle.'**
  String get editCategoriesHint;

  /// No description provided for @hiddenCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Gizli kategori yok} other{{count} gizli}}'**
  String hiddenCount(int count);

  /// No description provided for @hideMatching.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşenleri gizle ({count})'**
  String hideMatching(int count);

  /// No description provided for @showMatching.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşenleri göster ({count})'**
  String showMatching(int count);

  /// No description provided for @moveToTop.
  ///
  /// In tr, this message translates to:
  /// **'En üste taşı'**
  String get moveToTop;

  /// No description provided for @hideCategory.
  ///
  /// In tr, this message translates to:
  /// **'Gizle'**
  String get hideCategory;

  /// No description provided for @showCategory.
  ///
  /// In tr, this message translates to:
  /// **'Göster'**
  String get showCategory;

  /// No description provided for @reset.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get reset;

  /// No description provided for @dragToReorder.
  ///
  /// In tr, this message translates to:
  /// **'Sıralamak için sürükle'**
  String get dragToReorder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
