// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => '重试';

  @override
  String get tryAgain => '再试一次';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get goBack => '返回';

  @override
  String get backToLists => '返回列表';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get options => '选项';

  @override
  String get clear => '清除';

  @override
  String get play => '播放';

  @override
  String get liveBadge => '直播';

  @override
  String get nowBadge => '正在播出';

  @override
  String get nextLabel => '接下来';

  @override
  String get schedule => '节目单';

  @override
  String get favoritePackages => '收藏的频道包';

  @override
  String get allCategories => '所有分类';

  @override
  String get searchCategories => '搜索分类';

  @override
  String get noMatchingCategory => '没有匹配的分类';

  @override
  String get addToFavoritePackages => '加入收藏的频道包';

  @override
  String get removeFromFavoritePackages => '从收藏的频道包中移除';

  @override
  String get changeSearchOrCategory => '请更改搜索内容或分类。';

  @override
  String get scrollBack => '向后滚动';

  @override
  String get scrollForward => '向前滚动';

  @override
  String get muteShortcut => '静音 (M)';

  @override
  String get unmuteShortcut => '取消静音 (M)';

  @override
  String get ungrouped => '未分组';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 个频道',
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
      other: '$countString 部电影',
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
      other: '$countString 部剧集',
    );
    return '$_temp0';
  }

  @override
  String listCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个列表',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 季',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return '$date 到期';
  }

  @override
  String get expired => '已过期';

  @override
  String minutesLeft(int minutes) {
    return '剩余 $minutes 分钟';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get sectionHome => '首页';

  @override
  String get sectionLive => '直播电视';

  @override
  String get sectionMovies => '电影';

  @override
  String get sectionSeries => '剧集';

  @override
  String get sectionSearch => '搜索';

  @override
  String get sectionLists => '列表';

  @override
  String get sectionSettings => '设置';

  @override
  String get greetingMorning => '早上好';

  @override
  String get greetingDay => '下午好';

  @override
  String get greetingEvening => '晚上好';

  @override
  String get greetingNight => '晚安';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName 已就绪。打开一个频道或选一部电影，你看过的内容会显示在这里。';
  }

  @override
  String get homeIntro => '从上次看到的地方继续，或发现新内容。';

  @override
  String get continueWatching => '继续观看';

  @override
  String get recentChannels => '最近观看的频道';

  @override
  String get searchShortcutAll => '频道、电影、剧集';

  @override
  String get searchShortcutChannels => '在频道中';

  @override
  String maxSlotsReached(int max) {
    return '最多可同时观看 $max 个频道';
  }

  @override
  String maxSlotsShort(int max) {
    return '最多 $max 个频道';
  }

  @override
  String get watchSideBySide => '并排观看';

  @override
  String get epgUpdating => '正在更新节目单';

  @override
  String get epgFailed => '无法加载节目单';

  @override
  String get allChannels => '所有频道';

  @override
  String get recentlyWatched => '最近观看';

  @override
  String get searchChannels => '搜索频道';

  @override
  String get noRecentChannelsTitle => '还没有看过频道';

  @override
  String get noRecentChannelsMessage => '你看过的频道会显示在这里。';

  @override
  String get noChannelFound => '未找到频道';

  @override
  String get pickChannelTitle => '选择一个频道';

  @override
  String get pickChannelMessage => '点击列表中的频道。右键可查看更多选项，点击频道行上的 + 可并排观看。';

  @override
  String get hintChangeChannel => '切换频道';

  @override
  String get hintPreviousChannel => '上一个频道';

  @override
  String get hintMute => '静音 / 取消静音';

  @override
  String get hintFullscreen => '全屏';

  @override
  String get audioInThisTile => '此画面的声音';

  @override
  String get muted => '已静音';

  @override
  String get backToGrid => '返回网格';

  @override
  String get enlarge => '放大';

  @override
  String get closeTile => '关闭画面';

  @override
  String reconnecting(int attempt, int max) {
    return '直播卡住，正在重新连接（$attempt/$max）';
  }

  @override
  String get channelFailedTitle => '无法打开频道';

  @override
  String get channelFailedMessage => '服务商未发送直播流，或已达到连接数上限。';

  @override
  String get listFailedTitle => '无法打开列表';

  @override
  String get loadingChannels => '正在加载频道列表…';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get yesterday => '昨天';

  @override
  String archiveHint(int days) {
    return '可回看过去 $days 天，点击节目即可观看';
  }

  @override
  String get noProgrammes => '此频道没有节目信息';

  @override
  String get watchFromStart => '从头观看';

  @override
  String get watchFromArchive => '回看';

  @override
  String get searchHintAll => '搜索频道、电影或剧集';

  @override
  String get searchPromptTitle => '想看什么？';

  @override
  String get searchPromptChannels => '至少输入两个字符以搜索频道。';

  @override
  String get searchPromptAll => '至少输入两个字符，将同时搜索频道、电影和剧集。';

  @override
  String get channels => '频道';

  @override
  String loadingSection(String section) {
    return '正在加载$section…';
  }

  @override
  String get noResultsTitle => '没有结果';

  @override
  String get noResultsMessage => '换一种写法试试。';

  @override
  String get addList => '添加列表';

  @override
  String get editList => '编辑列表';

  @override
  String get listNameOptional => '列表名称（可选）';

  @override
  String get listNameHint => '例如：家里、体育套餐';

  @override
  String get serverAddress => '服务器地址';

  @override
  String get serverAddressHint => 'http://server:8080 或服务商提供的 M3U 链接';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get showPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get m3uLocation => 'M3U 列表（网址或文件路径）';

  @override
  String get add => '添加';

  @override
  String get save => '保存';

  @override
  String get errServerAndUserRequired => '需要填写服务器地址和用户名。';

  @override
  String get errLocationRequired => '需要填写列表网址或文件路径。';

  @override
  String errDuplicateList(String name) {
    return '此列表已添加：“$name”。';
  }

  @override
  String get deleteListTitle => '删除列表？';

  @override
  String deleteListMessage(String name) {
    return '将删除“$name”及其收藏的频道包和观看记录。你在服务商的账户不受影响。';
  }

  @override
  String get yourLists => '你的列表';

  @override
  String get welcomeTitle => '欢迎使用 Streamlity';

  @override
  String get welcomeMessage => '添加一个列表即可开始。你可以添加任意多个列表并在它们之间切换。';

  @override
  String get xtreamDescription => '服务器、用户名和密码。直播电视、电影、剧集。';

  @override
  String get m3uDescription => '列表网址或电脑上的文件。';

  @override
  String get notOpenedYet => '尚未打开';

  @override
  String get audioLanguage => '音频语言';

  @override
  String get subtitles => '字幕';

  @override
  String get subtitlesOff => '关闭';

  @override
  String trackNumber(String id) {
    return '音轨 $id';
  }

  @override
  String get sortProvider => '服务商顺序';

  @override
  String get sortName => '按名称';

  @override
  String get sortRating => '按评分';

  @override
  String get sortYear => '按年份';

  @override
  String get moviesFailed => '无法加载电影';

  @override
  String get seriesFailed => '无法加载剧集';

  @override
  String get allMovies => '所有电影';

  @override
  String get allSeries => '所有剧集';

  @override
  String get searchMovies => '搜索电影';

  @override
  String get searchSeries => '搜索剧集';

  @override
  String get noMatchingMovies => '没有匹配的电影';

  @override
  String get noMatchingSeries => '没有匹配的剧集';

  @override
  String get loadingMovies => '正在加载电影…';

  @override
  String get loadingSeries => '正在加载剧集…';

  @override
  String get noDescription => '暂无简介。';

  @override
  String get director => '导演';

  @override
  String get cast => '演员';

  @override
  String resumeAt(String position) {
    return '继续播放 · $position';
  }

  @override
  String get startOver => '从头开始';

  @override
  String get seriesInfoFailed => '无法加载剧集详情';

  @override
  String get noEpisodes => '此剧集没有分集';

  @override
  String seasonTab(int season, int count) {
    return '第 $season 季 · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return '第 $season 季第 $episode 集 · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return '第$season季第$episode集';
  }

  @override
  String playEpisode(String code) {
    return '$code · 播放';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · 继续';
  }

  @override
  String episodeFallback(int number) {
    return '第 $number 集';
  }

  @override
  String get watched => '已看完';

  @override
  String watchedUntil(String position) {
    return '已看到 $position';
  }

  @override
  String get playbackFailed => '无法播放';

  @override
  String errHttpStatus(int code) {
    return '服务器返回了 $code。';
  }

  @override
  String errFetchFailed(String detail) {
    return '无法加载列表：$detail';
  }

  @override
  String get errNoChannels => '列表中没有频道。';

  @override
  String get errNoLiveChannels => '账户中没有直播频道。';

  @override
  String get errBadLogin => '用户名或密码错误。';

  @override
  String errAccountUnavailable(String status) {
    return '账户不可用（状态：$status）。';
  }

  @override
  String errConnect(String detail) {
    return '无法连接到服务器：$detail';
  }

  @override
  String get errInvalidResponse => '服务器未返回有效的 Xtream Codes 响应。';

  @override
  String get errNoMovies => '账户中没有电影。';

  @override
  String get errNoSeries => '账户中没有剧集。';

  @override
  String errEpg(String detail) {
    return '无法加载节目单：$detail';
  }

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSubtitle => '应用界面语言';

  @override
  String get systemLanguage => '系统语言';

  @override
  String systemLanguageCurrent(String language) {
    return '当前：$language';
  }

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutText => '适用于 Windows、macOS 和 Linux 的开源 IPTV 播放器。';

  @override
  String get translationNote => '翻译由系统自动生成；如发现错误，欢迎告诉我们。';
}
