// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'Coba lagi';

  @override
  String get tryAgain => 'Ulangi';

  @override
  String get cancel => 'Batal';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get goBack => 'Kembali';

  @override
  String get backToLists => 'Kembali ke daftar';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Ubah';

  @override
  String get options => 'Opsi';

  @override
  String get clear => 'Bersihkan';

  @override
  String get play => 'Putar';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get nowBadge => 'SEKARANG';

  @override
  String get nextLabel => 'BERIKUTNYA';

  @override
  String get schedule => 'Jadwal acara';

  @override
  String get favoritePackages => 'Paket favorit';

  @override
  String get allCategories => 'Semua kategori';

  @override
  String get searchCategories => 'Cari kategori';

  @override
  String get noMatchingCategory => 'Tidak ada kategori yang cocok';

  @override
  String get addToFavoritePackages => 'Tambahkan ke paket favorit';

  @override
  String get removeFromFavoritePackages => 'Hapus dari paket favorit';

  @override
  String get changeSearchOrCategory => 'Ubah pencarian atau kategori.';

  @override
  String get scrollBack => 'Gulir ke belakang';

  @override
  String get scrollForward => 'Gulir ke depan';

  @override
  String get muteShortcut => 'Bisukan (M)';

  @override
  String get unmuteShortcut => 'Bunyikan (M)';

  @override
  String get ungrouped => 'Tanpa grup';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString saluran',
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
      other: '$countString serial',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count daftar',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count musim',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Berakhir $date';
  }

  @override
  String get expired => 'Kedaluwarsa';

  @override
  String minutesLeft(int minutes) {
    return 'Sisa $minutes mnt';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours j $minutes mnt';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String get sectionHome => 'Beranda';

  @override
  String get sectionLive => 'TV langsung';

  @override
  String get sectionMovies => 'Film';

  @override
  String get sectionSeries => 'Serial';

  @override
  String get sectionSearch => 'Cari';

  @override
  String get sectionLists => 'Daftar';

  @override
  String get sectionSettings => 'Pengaturan';

  @override
  String get greetingMorning => 'Selamat pagi';

  @override
  String get greetingDay => 'Selamat siang';

  @override
  String get greetingEvening => 'Selamat malam';

  @override
  String get greetingNight => 'Selamat malam';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName siap. Buka saluran atau pilih film; yang kamu tonton akan muncul di sini.';
  }

  @override
  String get homeIntro => 'Lanjutkan yang tadi atau temukan sesuatu yang baru.';

  @override
  String get continueWatching => 'Lanjutkan menonton';

  @override
  String get recentChannels => 'Saluran yang baru ditonton';

  @override
  String get searchShortcutAll => 'Saluran, film, serial';

  @override
  String get searchShortcutChannels => 'Di saluran';

  @override
  String maxSlotsReached(int max) {
    return 'Kamu dapat menonton hingga $max saluran sekaligus';
  }

  @override
  String maxSlotsShort(int max) {
    return 'Hingga $max saluran';
  }

  @override
  String get watchSideBySide => 'Tonton berdampingan';

  @override
  String get epgUpdating => 'Memperbarui jadwal acara';

  @override
  String get epgFailed => 'Gagal memuat jadwal acara';

  @override
  String get allChannels => 'Semua saluran';

  @override
  String get recentlyWatched => 'Baru ditonton';

  @override
  String get searchChannels => 'Cari saluran';

  @override
  String get noRecentChannelsTitle => 'Belum ada saluran yang ditonton';

  @override
  String get noRecentChannelsMessage =>
      'Saluran yang kamu tonton akan muncul di sini.';

  @override
  String get noChannelFound => 'Saluran tidak ditemukan';

  @override
  String get pickChannelTitle => 'Pilih saluran';

  @override
  String get pickChannelMessage =>
      'Klik saluran di daftar. Klik kanan untuk opsi lain, atau + pada baris saluran untuk menonton berdampingan.';

  @override
  String get hintChangeChannel => 'Ganti saluran';

  @override
  String get hintPreviousChannel => 'Saluran sebelumnya';

  @override
  String get hintMute => 'Bisukan / bunyikan';

  @override
  String get hintFullscreen => 'Layar penuh';

  @override
  String get audioInThisTile => 'Suara di kotak ini';

  @override
  String get muted => 'Dibisukan';

  @override
  String get backToGrid => 'Kembali ke kisi';

  @override
  String get enlarge => 'Perbesar';

  @override
  String get closeTile => 'Tutup kotak';

  @override
  String reconnecting(int attempt, int max) {
    return 'Siaran macet, menyambung ulang ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'Saluran tidak dapat dibuka';

  @override
  String get channelFailedMessage =>
      'Penyedia tidak mengirim siaran atau batas koneksi sudah tercapai.';

  @override
  String get listFailedTitle => 'Daftar tidak dapat dibuka';

  @override
  String get loadingChannels => 'Memuat daftar saluran…';

  @override
  String get today => 'Hari ini';

  @override
  String get tomorrow => 'Besok';

  @override
  String get yesterday => 'Kemarin';

  @override
  String archiveHint(int days) {
    return 'Tersedia $days hari terakhir, klik sebuah acara';
  }

  @override
  String get noProgrammes => 'Tidak ada acara untuk saluran ini';

  @override
  String get watchFromStart => 'Tonton dari awal';

  @override
  String get watchFromArchive => 'Tonton dari arsip';

  @override
  String get searchHintAll => 'Cari saluran, film, atau serial';

  @override
  String get searchPromptTitle => 'Mau nonton apa?';

  @override
  String get searchPromptChannels =>
      'Ketik minimal dua huruf untuk mencari saluran.';

  @override
  String get searchPromptAll =>
      'Ketik minimal dua huruf untuk mencari saluran, film, dan serial sekaligus.';

  @override
  String get channels => 'Saluran';

  @override
  String loadingSection(String section) {
    return 'Memuat $section…';
  }

  @override
  String get noResultsTitle => 'Tidak ada hasil';

  @override
  String get noResultsMessage => 'Coba ejaan lain.';

  @override
  String get addList => 'Tambah daftar';

  @override
  String get editList => 'Ubah daftar';

  @override
  String get listNameOptional => 'Nama daftar (opsional)';

  @override
  String get listNameHint => 'mis. Rumah, Paket olahraga';

  @override
  String get serverAddress => 'Alamat server';

  @override
  String get serverAddressHint =>
      'http://server:8080 atau tautan M3U dari penyedia';

  @override
  String get username => 'Nama pengguna';

  @override
  String get password => 'Kata sandi';

  @override
  String get showPassword => 'Tampilkan kata sandi';

  @override
  String get hidePassword => 'Sembunyikan kata sandi';

  @override
  String get m3uLocation => 'Daftar M3U (URL atau lokasi file)';

  @override
  String get add => 'Tambah';

  @override
  String get save => 'Simpan';

  @override
  String get errServerAndUserRequired =>
      'Alamat server dan nama pengguna wajib diisi.';

  @override
  String get errLocationRequired => 'URL daftar atau lokasi file wajib diisi.';

  @override
  String errDuplicateList(String name) {
    return 'Daftar ini sudah ditambahkan: \"$name\".';
  }

  @override
  String get deleteListTitle => 'Hapus daftar?';

  @override
  String deleteListMessage(String name) {
    return '\"$name\" beserta paket favorit dan riwayatnya akan dihapus. Akunmu di penyedia tidak terpengaruh.';
  }

  @override
  String get yourLists => 'Daftarmu';

  @override
  String get welcomeTitle => 'Selamat datang di Streamlity';

  @override
  String get welcomeMessage =>
      'Tambahkan daftar untuk memulai. Kamu bisa menambahkan daftar sebanyak yang kamu mau dan berpindah di antaranya.';

  @override
  String get xtreamDescription =>
      'Server, nama pengguna, dan kata sandi. TV langsung, film, serial.';

  @override
  String get m3uDescription => 'URL daftar atau file di komputermu.';

  @override
  String get notOpenedYet => 'Belum dibuka';

  @override
  String get audioLanguage => 'Bahasa audio';

  @override
  String get subtitles => 'Subtitel';

  @override
  String get subtitlesOff => 'Mati';

  @override
  String trackNumber(String id) {
    return 'Trek $id';
  }

  @override
  String get sortProvider => 'Urutan penyedia';

  @override
  String get sortName => 'Menurut nama';

  @override
  String get sortRating => 'Menurut rating';

  @override
  String get sortYear => 'Menurut tahun';

  @override
  String get moviesFailed => 'Gagal memuat film';

  @override
  String get seriesFailed => 'Gagal memuat serial';

  @override
  String get allMovies => 'Semua film';

  @override
  String get allSeries => 'Semua serial';

  @override
  String get searchMovies => 'Cari film';

  @override
  String get searchSeries => 'Cari serial';

  @override
  String get noMatchingMovies => 'Tidak ada film yang cocok';

  @override
  String get noMatchingSeries => 'Tidak ada serial yang cocok';

  @override
  String get loadingMovies => 'Memuat film…';

  @override
  String get loadingSeries => 'Memuat serial…';

  @override
  String get noDescription => 'Tidak ada deskripsi.';

  @override
  String get director => 'Sutradara';

  @override
  String get cast => 'Pemeran';

  @override
  String resumeAt(String position) {
    return 'Lanjutkan · $position';
  }

  @override
  String get startOver => 'Mulai dari awal';

  @override
  String get seriesInfoFailed => 'Gagal memuat detail serial';

  @override
  String get noEpisodes => 'Serial ini tidak punya episode';

  @override
  String seasonTab(int season, int count) {
    return 'Musim $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'Musim $season, episode $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'M$season E$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · Putar';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · Lanjutkan';
  }

  @override
  String episodeFallback(int number) {
    return 'Episode $number';
  }

  @override
  String get watched => 'Sudah ditonton';

  @override
  String watchedUntil(String position) {
    return 'Ditonton sampai $position';
  }

  @override
  String get playbackFailed => 'Tidak dapat diputar';

  @override
  String errHttpStatus(int code) {
    return 'Server mengembalikan $code.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'Gagal memuat daftar: $detail';
  }

  @override
  String get errNoChannels => 'Tidak ada saluran di daftar.';

  @override
  String get errNoLiveChannels => 'Tidak ada saluran langsung di akun.';

  @override
  String get errBadLogin => 'Nama pengguna atau kata sandi salah.';

  @override
  String errAccountUnavailable(String status) {
    return 'Akun tidak tersedia (status: $status).';
  }

  @override
  String errConnect(String detail) {
    return 'Tidak dapat terhubung ke server: $detail';
  }

  @override
  String get errInvalidResponse =>
      'Server tidak memberikan respons Xtream Codes yang valid.';

  @override
  String get errNoMovies => 'Tidak ada film di akun.';

  @override
  String get errNoSeries => 'Tidak ada serial di akun.';

  @override
  String errEpg(String detail) {
    return 'Gagal memuat jadwal acara: $detail';
  }

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageSubtitle => 'Bahasa antarmuka aplikasi';

  @override
  String get systemLanguage => 'Bahasa sistem';

  @override
  String systemLanguageCurrent(String language) {
    return 'Saat ini: $language';
  }

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get settingsAboutText =>
      'Pemutar IPTV sumber terbuka untuk Windows, macOS, dan Linux.';

  @override
  String get translationNote =>
      'Terjemahan disiapkan secara otomatis; beri tahu kami jika menemukan kesalahan.';

  @override
  String get editCategories => 'Atur kategori';

  @override
  String get editCategoriesHint =>
      'Seret untuk mengurutkan, gunakan ikon mata untuk menyembunyikan.';

  @override
  String hiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tersembunyi',
      zero: 'Tidak ada kategori tersembunyi',
    );
    return '$_temp0';
  }

  @override
  String hideMatching(int count) {
    return 'Sembunyikan yang cocok ($count)';
  }

  @override
  String showMatching(int count) {
    return 'Tampilkan yang cocok ($count)';
  }

  @override
  String get moveToTop => 'Pindahkan ke atas';

  @override
  String get hideCategory => 'Sembunyikan';

  @override
  String get showCategory => 'Tampilkan';

  @override
  String get reset => 'Atur ulang';

  @override
  String get dragToReorder => 'Seret untuk mengurutkan';
}
