// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get tryAgain => 'Yeniden dene';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get goBack => 'Geri dön';

  @override
  String get backToLists => 'Listelere dön';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get options => 'Seçenekler';

  @override
  String get clear => 'Temizle';

  @override
  String get play => 'Oynat';

  @override
  String get liveBadge => 'CANLI';

  @override
  String get nowBadge => 'ŞİMDİ';

  @override
  String get nextLabel => 'SONRA';

  @override
  String get schedule => 'Yayın akışı';

  @override
  String get favoritePackages => 'Favori paketler';

  @override
  String get allCategories => 'Tüm kategoriler';

  @override
  String get searchCategories => 'Kategori ara';

  @override
  String get noMatchingCategory => 'Eşleşen kategori yok';

  @override
  String get addToFavoritePackages => 'Favori paketlere ekle';

  @override
  String get removeFromFavoritePackages => 'Favori paketlerden çıkar';

  @override
  String get changeSearchOrCategory => 'Aramayı ya da kategoriyi değiştir.';

  @override
  String get scrollBack => 'Geri kaydır';

  @override
  String get scrollForward => 'İleri kaydır';

  @override
  String get muteShortcut => 'Sessiz (M)';

  @override
  String get unmuteShortcut => 'Sesi aç (M)';

  @override
  String get ungrouped => 'Grupsuz';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString kanal',
      one: '1 kanal',
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
      other: '$countString film',
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
      other: '$countString dizi',
      one: '1 dizi',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count liste',
      one: '1 liste',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sezon',
      one: '1 sezon',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Bitiş $date';
  }

  @override
  String get expired => 'Süresi doldu';

  @override
  String minutesLeft(int minutes) {
    return '$minutes dk kaldı';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get sectionHome => 'Ana sayfa';

  @override
  String get sectionLive => 'Canlı TV';

  @override
  String get sectionMovies => 'Filmler';

  @override
  String get sectionSeries => 'Diziler';

  @override
  String get sectionSearch => 'Ara';

  @override
  String get sectionLists => 'Listeler';

  @override
  String get sectionSettings => 'Ayarlar';

  @override
  String get greetingMorning => 'Günaydın';

  @override
  String get greetingDay => 'İyi günler';

  @override
  String get greetingEvening => 'İyi akşamlar';

  @override
  String get greetingNight => 'İyi geceler';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName hazır. Bir kanal aç ya da film seç, izlediklerin burada birikir.';
  }

  @override
  String get homeIntro => 'Kaldığın yerden devam et ya da yeni bir şey keşfet.';

  @override
  String get continueWatching => 'İzlemeye devam et';

  @override
  String get recentChannels => 'Son izlenen kanallar';

  @override
  String get searchShortcutAll => 'Kanal, film, dizi';

  @override
  String get searchShortcutChannels => 'Kanallarda';

  @override
  String maxSlotsReached(int max) {
    return 'Aynı anda en fazla $max kanal izlenebilir';
  }

  @override
  String maxSlotsShort(int max) {
    return 'En fazla $max kanal';
  }

  @override
  String get watchSideBySide => 'Yan yana izle';

  @override
  String get epgUpdating => 'Yayın akışı güncelleniyor';

  @override
  String get epgFailed => 'Yayın akışı alınamadı';

  @override
  String get allChannels => 'Tüm kanallar';

  @override
  String get recentlyWatched => 'Son izlenenler';

  @override
  String get searchChannels => 'Kanal ara';

  @override
  String get noRecentChannelsTitle => 'Henüz kanal izlemedin';

  @override
  String get noRecentChannelsMessage => 'İzlediğin kanallar burada görünür.';

  @override
  String get noChannelFound => 'Kanal bulunamadı';

  @override
  String get pickChannelTitle => 'Bir kanal seç';

  @override
  String get pickChannelMessage =>
      'Listeden bir kanala tıkla. Sağ tıkla daha fazla seçenek, kanal satırındaki + ile yan yana izleme.';

  @override
  String get hintChangeChannel => 'Kanal değiştir';

  @override
  String get hintPreviousChannel => 'Önceki kanal';

  @override
  String get hintMute => 'Sesi kapat / aç';

  @override
  String get hintFullscreen => 'Tam ekran';

  @override
  String get audioInThisTile => 'Ses bu karede';

  @override
  String get muted => 'Sessiz';

  @override
  String get backToGrid => 'Izgaraya dön';

  @override
  String get enlarge => 'Büyüt';

  @override
  String get closeTile => 'Kareyi kapat';

  @override
  String reconnecting(int attempt, int max) {
    return 'Yayın gelmiyor, yeniden bağlanılıyor ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'Kanal açılamadı';

  @override
  String get channelFailedMessage =>
      'Sağlayıcı yayın göndermiyor ya da bağlantı sınırı dolu.';

  @override
  String get listFailedTitle => 'Liste açılamadı';

  @override
  String get loadingChannels => 'Kanal listesi yükleniyor…';

  @override
  String get today => 'Bugün';

  @override
  String get tomorrow => 'Yarın';

  @override
  String get yesterday => 'Dün';

  @override
  String archiveHint(int days) {
    return 'Geçmiş $days gün izlenebilir, programa tıkla';
  }

  @override
  String get noProgrammes => 'Bu kanal için program yok';

  @override
  String get watchFromStart => 'Baştan izle';

  @override
  String get watchFromArchive => 'Geçmişten izle';

  @override
  String get searchHintAll => 'Kanal, film ya da dizi ara';

  @override
  String get searchPromptTitle => 'Ne izlemek istersin?';

  @override
  String get searchPromptChannels => 'En az iki harf yaz; kanallarda aranır.';

  @override
  String get searchPromptAll =>
      'En az iki harf yaz; kanallarda, filmlerde ve dizilerde aynı anda aranır.';

  @override
  String get channels => 'Kanallar';

  @override
  String loadingSection(String section) {
    return '$section yükleniyor…';
  }

  @override
  String get noResultsTitle => 'Sonuç bulunamadı';

  @override
  String get noResultsMessage =>
      'Farklı bir yazımla dene; Türkçe harfler fark etmez.';

  @override
  String get addList => 'Liste ekle';

  @override
  String get editList => 'Listeyi düzenle';

  @override
  String get listNameOptional => 'Liste adı (isteğe bağlı)';

  @override
  String get listNameHint => 'Örn. Ev, Spor paketi';

  @override
  String get serverAddress => 'Sunucu adresi';

  @override
  String get serverAddressHint =>
      'http://sunucu:8080 veya sağlayıcının M3U linki';

  @override
  String get username => 'Kullanıcı adı';

  @override
  String get password => 'Şifre';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get m3uLocation => 'M3U listesi (URL veya dosya yolu)';

  @override
  String get add => 'Ekle';

  @override
  String get save => 'Kaydet';

  @override
  String get errServerAndUserRequired =>
      'Sunucu adresi ve kullanıcı adı gerekli.';

  @override
  String get errLocationRequired => 'Liste adresi ya da dosya yolu gerekli.';

  @override
  String errDuplicateList(String name) {
    return 'Bu liste zaten ekli: \"$name\".';
  }

  @override
  String get deleteListTitle => 'Liste silinsin mi?';

  @override
  String deleteListMessage(String name) {
    return '\"$name\", favori paketleri ve son izlenenleri silinecek. Sağlayıcıdaki hesabın etkilenmez.';
  }

  @override
  String get yourLists => 'Listelerin';

  @override
  String get welcomeTitle => 'Streamlity\'ye hoş geldin';

  @override
  String get welcomeMessage =>
      'Başlamak için bir liste ekle. İstediğin kadar liste ekleyip aralarında geçiş yapabilirsin.';

  @override
  String get xtreamDescription =>
      'Sunucu, kullanıcı adı ve şifre. Canlı TV, film, dizi.';

  @override
  String get m3uDescription => 'Bir liste adresi ya da bilgisayardaki dosya.';

  @override
  String get notOpenedYet => 'Henüz açılmadı';

  @override
  String get audioLanguage => 'Ses dili';

  @override
  String get subtitles => 'Altyazı';

  @override
  String get subtitlesOff => 'Kapalı';

  @override
  String trackNumber(String id) {
    return 'Parça $id';
  }

  @override
  String get sortProvider => 'Sağlayıcı sırası';

  @override
  String get sortName => 'Ada göre';

  @override
  String get sortRating => 'Puana göre';

  @override
  String get sortYear => 'Yıla göre';

  @override
  String get moviesFailed => 'Filmler alınamadı';

  @override
  String get seriesFailed => 'Diziler alınamadı';

  @override
  String get allMovies => 'Tüm filmler';

  @override
  String get allSeries => 'Tüm diziler';

  @override
  String get searchMovies => 'Film ara';

  @override
  String get searchSeries => 'Dizi ara';

  @override
  String get noMatchingMovies => 'Eşleşen film yok';

  @override
  String get noMatchingSeries => 'Eşleşen dizi yok';

  @override
  String get loadingMovies => 'Filmler yükleniyor…';

  @override
  String get loadingSeries => 'Diziler yükleniyor…';

  @override
  String get noDescription => 'Açıklama yok.';

  @override
  String get director => 'Yönetmen';

  @override
  String get cast => 'Oyuncular';

  @override
  String resumeAt(String position) {
    return 'Devam et · $position';
  }

  @override
  String get startOver => 'Baştan başla';

  @override
  String get seriesInfoFailed => 'Dizi bilgisi alınamadı';

  @override
  String get noEpisodes => 'Bu dizide bölüm yok';

  @override
  String seasonTab(int season, int count) {
    return '$season. sezon · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return '$season. sezon $episode. bölüm · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'S$season B$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · Oynat';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · Devam et';
  }

  @override
  String episodeFallback(int number) {
    return 'Bölüm $number';
  }

  @override
  String get watched => 'İzlendi';

  @override
  String watchedUntil(String position) {
    return '$position izlendi';
  }

  @override
  String get playbackFailed => 'Oynatılamadı';

  @override
  String errHttpStatus(int code) {
    return 'Sunucu $code döndürdü.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'Liste alınamadı: $detail';
  }

  @override
  String get errNoChannels => 'Listede kanal bulunamadı.';

  @override
  String get errNoLiveChannels => 'Hesapta canlı kanal bulunamadı.';

  @override
  String get errBadLogin => 'Kullanıcı adı veya şifre hatalı.';

  @override
  String errAccountUnavailable(String status) {
    return 'Hesap kullanılamıyor (durum: $status).';
  }

  @override
  String errConnect(String detail) {
    return 'Sunucuya bağlanılamadı: $detail';
  }

  @override
  String get errInvalidResponse =>
      'Sunucu geçerli bir Xtream Codes yanıtı vermedi.';

  @override
  String get errNoMovies => 'Hesapta film bulunamadı.';

  @override
  String get errNoSeries => 'Hesapta dizi bulunamadı.';

  @override
  String errEpg(String detail) {
    return 'Yayın akışı alınamadı: $detail';
  }

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSubtitle => 'Uygulamanın arayüz dili';

  @override
  String get systemLanguage => 'Sistem dili';

  @override
  String systemLanguageCurrent(String language) {
    return 'Şu an: $language';
  }

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsAboutText =>
      'Windows, macOS ve Linux için açık kaynak IPTV oynatıcısı.';

  @override
  String get translationNote =>
      'Çeviriler otomatik hazırlandı; hata görürsen bildir.';

  @override
  String get editCategories => 'Kategorileri düzenle';

  @override
  String get editCategoriesHint =>
      'Sürükleyerek sırala; göz simgesiyle gizle, kilit simgesiyle PIN\'e bağla.';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gizli',
      zero: 'Gizli kategori yok',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'Eşleşenleri gizle ($count)';
  }

  @override
  String showMatching(int count) {
    return 'Eşleşenleri göster ($count)';
  }

  @override
  String get moveToTop => 'En üste taşı';

  @override
  String get hideCategory => 'Gizle';

  @override
  String get showCategory => 'Göster';

  @override
  String get reset => 'Sıfırla';

  @override
  String get dragToReorder => 'Sıralamak için sürükle';

  @override
  String lockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kilitli',
    );
    return '$_temp0';
  }

  @override
  String get lockCategory => 'Kilitle';

  @override
  String get unlockCategory => 'Kilidi kaldır';

  @override
  String get lockedCategory => 'Kilitli kategori';

  @override
  String get confirm => 'Tamam';

  @override
  String get pinEnterTitle => 'PIN\'i gir';

  @override
  String get pinWrong => 'PIN yanlış';

  @override
  String get pinUnlockMessage =>
      'Bu kategori kilitli. PIN\'i girersen uygulama kapanana kadar tüm kilitli kategoriler açık kalır.';

  @override
  String get pinEditorMessage =>
      'Kategori düzenini değiştirmek için PIN gerekli.';

  @override
  String get pinCurrentMessage => 'Devam etmek için şu anki PIN\'i gir.';

  @override
  String get pinRemoveMessage => 'PIN\'i kaldırmak için şu anki PIN\'i gir.';

  @override
  String get pinNewTitle => 'Yeni PIN';

  @override
  String get pinNewMessage =>
      'Kilitli kategorileri açmak için 4 haneli bir PIN seç.';

  @override
  String get pinConfirmTitle => 'PIN\'i onayla';

  @override
  String get pinConfirmMessage => 'Aynı PIN\'i bir kez daha gir.';

  @override
  String get pinMismatch => 'PIN\'ler eşleşmedi';

  @override
  String get pinSaved => 'PIN kaydedildi';

  @override
  String get pinRemoved => 'PIN ve tüm kategori kilitleri kaldırıldı';

  @override
  String get locksClosed => 'Kilitli kategoriler yeniden kilitlendi';

  @override
  String get parentalControl => 'Ebeveyn denetimi';

  @override
  String get parentalControlSubtitle =>
      'Kilitli kategoriler PIN girilmeden açılmaz; kanalları aramada ve ana sayfada çıkmaz.';

  @override
  String get setPin => 'PIN belirle';

  @override
  String get setPinDetail =>
      'Sonra kategori düzenleyicideki kilit simgesiyle kategorileri kilitle.';

  @override
  String get lockNow => 'Kilitleri şimdi kapat';

  @override
  String get lockNowDetail =>
      'Bu oturumda açılan kilitli kategoriler yeniden PIN ister.';

  @override
  String get changePin => 'PIN\'i değiştir';

  @override
  String get removePin => 'PIN\'i kaldır';

  @override
  String get removePinDetail => 'Tüm kategori kilitleri de kaldırılır.';

  @override
  String get searchFilterAll => 'Tümü';

  @override
  String get seeAll => 'Tümünü gör';

  @override
  String get fullscreenGrid => 'Tam ekran (F)';

  @override
  String get exitFullscreenGrid => 'Tam ekrandan çık (Esc)';
}
