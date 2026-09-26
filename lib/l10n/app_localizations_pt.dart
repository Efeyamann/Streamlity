// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Streamlity';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get tryAgain => 'Repetir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get goBack => 'Voltar';

  @override
  String get backToLists => 'Voltar às listas';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get options => 'Opções';

  @override
  String get clear => 'Limpar';

  @override
  String get play => 'Reproduzir';

  @override
  String get liveBadge => 'AO VIVO';

  @override
  String get nowBadge => 'AGORA';

  @override
  String get nextLabel => 'A SEGUIR';

  @override
  String get schedule => 'Guia de TV';

  @override
  String get favoritePackages => 'Pacotes favoritos';

  @override
  String get allCategories => 'Todas as categorias';

  @override
  String get searchCategories => 'Buscar categorias';

  @override
  String get noMatchingCategory => 'Nenhuma categoria corresponde';

  @override
  String get addToFavoritePackages => 'Adicionar aos pacotes favoritos';

  @override
  String get removeFromFavoritePackages => 'Remover dos pacotes favoritos';

  @override
  String get changeSearchOrCategory => 'Altere a busca ou a categoria.';

  @override
  String get scrollBack => 'Rolar para trás';

  @override
  String get scrollForward => 'Rolar para frente';

  @override
  String get muteShortcut => 'Silenciar (M)';

  @override
  String get unmuteShortcut => 'Ativar som (M)';

  @override
  String get ungrouped => 'Sem grupo';

  @override
  String channelCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString canais',
      one: '1 canal',
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
      other: '$countString filmes',
      one: '1 filme',
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
      other: '$count listas',
      one: '1 lista',
    );
    return '$_temp0';
  }

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temporadas',
      one: '1 temporada',
    );
    return '$_temp0';
  }

  @override
  String expiresOn(String date) {
    return 'Expira em $date';
  }

  @override
  String get expired => 'Expirada';

  @override
  String minutesLeft(int minutes) {
    return 'Faltam $minutes min';
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
  String get sectionHome => 'Início';

  @override
  String get sectionLive => 'TV ao vivo';

  @override
  String get sectionMovies => 'Filmes';

  @override
  String get sectionSeries => 'Séries';

  @override
  String get sectionSearch => 'Buscar';

  @override
  String get sectionLists => 'Listas';

  @override
  String get sectionSettings => 'Configurações';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingDay => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get greetingNight => 'Boa noite';

  @override
  String homeIntroEmpty(String listName) {
    return '$listName está pronta. Abra um canal ou escolha um filme; o que você assistir aparecerá aqui.';
  }

  @override
  String get homeIntro => 'Continue de onde parou ou descubra algo novo.';

  @override
  String get continueWatching => 'Continuar assistindo';

  @override
  String get recentChannels => 'Canais assistidos recentemente';

  @override
  String get searchShortcutAll => 'Canais, filmes, séries';

  @override
  String get searchShortcutChannels => 'Nos canais';

  @override
  String maxSlotsReached(int max) {
    return 'Você pode assistir até $max canais ao mesmo tempo';
  }

  @override
  String maxSlotsShort(int max) {
    return 'Até $max canais';
  }

  @override
  String get watchSideBySide => 'Assistir lado a lado';

  @override
  String get epgUpdating => 'Atualizando o guia';

  @override
  String get epgFailed => 'Não foi possível carregar o guia';

  @override
  String get allChannels => 'Todos os canais';

  @override
  String get recentlyWatched => 'Assistidos recentemente';

  @override
  String get searchChannels => 'Buscar canais';

  @override
  String get noRecentChannelsTitle => 'Nenhum canal assistido ainda';

  @override
  String get noRecentChannelsMessage =>
      'Os canais que você assistir aparecerão aqui.';

  @override
  String get noChannelFound => 'Nenhum canal encontrado';

  @override
  String get pickChannelTitle => 'Escolha um canal';

  @override
  String get pickChannelMessage =>
      'Clique em um canal da lista. Clique com o botão direito para mais opções, ou use + na linha do canal para assistir lado a lado.';

  @override
  String get hintChangeChannel => 'Trocar de canal';

  @override
  String get hintPreviousChannel => 'Canal anterior';

  @override
  String get hintMute => 'Silenciar / ativar som';

  @override
  String get hintFullscreen => 'Tela cheia';

  @override
  String get audioInThisTile => 'Som neste quadro';

  @override
  String get muted => 'Sem som';

  @override
  String get backToGrid => 'Voltar à grade';

  @override
  String get enlarge => 'Ampliar';

  @override
  String get closeTile => 'Fechar quadro';

  @override
  String reconnecting(int attempt, int max) {
    return 'Transmissão travou, reconectando ($attempt/$max)';
  }

  @override
  String get channelFailedTitle => 'Não foi possível abrir o canal';

  @override
  String get channelFailedMessage =>
      'O provedor não está enviando a transmissão ou o limite de conexões foi atingido.';

  @override
  String get listFailedTitle => 'Não foi possível abrir a lista';

  @override
  String get loadingChannels => 'Carregando a lista de canais…';

  @override
  String get today => 'Hoje';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get yesterday => 'Ontem';

  @override
  String archiveHint(int days) {
    return 'Últimos $days dias disponíveis, clique em um programa';
  }

  @override
  String get noProgrammes => 'Nenhum programa para este canal';

  @override
  String get watchFromStart => 'Assistir do início';

  @override
  String get watchFromArchive => 'Assistir do arquivo';

  @override
  String get searchHintAll => 'Buscar canais, filmes ou séries';

  @override
  String get searchPromptTitle => 'O que você quer assistir?';

  @override
  String get searchPromptChannels =>
      'Digite pelo menos duas letras para buscar canais.';

  @override
  String get searchPromptAll =>
      'Digite pelo menos duas letras para buscar em canais, filmes e séries ao mesmo tempo.';

  @override
  String get channels => 'Canais';

  @override
  String loadingSection(String section) {
    return 'Carregando $section…';
  }

  @override
  String get noResultsTitle => 'Nenhum resultado';

  @override
  String get noResultsMessage => 'Tente outra grafia.';

  @override
  String get addList => 'Adicionar lista';

  @override
  String get editList => 'Editar lista';

  @override
  String get listNameOptional => 'Nome da lista (opcional)';

  @override
  String get listNameHint => 'ex.: Casa, Pacote de esportes';

  @override
  String get serverAddress => 'Endereço do servidor';

  @override
  String get serverAddressHint =>
      'http://servidor:8080 ou o link M3U do seu provedor';

  @override
  String get username => 'Usuário';

  @override
  String get password => 'Senha';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get m3uLocation => 'Lista M3U (URL ou caminho do arquivo)';

  @override
  String get add => 'Adicionar';

  @override
  String get save => 'Salvar';

  @override
  String get errServerAndUserRequired =>
      'O endereço do servidor e o usuário são obrigatórios.';

  @override
  String get errLocationRequired =>
      'É necessário um URL de lista ou um caminho de arquivo.';

  @override
  String errDuplicateList(String name) {
    return 'Esta lista já foi adicionada: \"$name\".';
  }

  @override
  String get deleteListTitle => 'Excluir a lista?';

  @override
  String deleteListMessage(String name) {
    return '\"$name\", seus pacotes favoritos e seu histórico serão excluídos. Sua conta no provedor não é afetada.';
  }

  @override
  String get yourLists => 'Suas listas';

  @override
  String get welcomeTitle => 'Boas-vindas ao Streamlity';

  @override
  String get welcomeMessage =>
      'Adicione uma lista para começar. Você pode adicionar quantas listas quiser e alternar entre elas.';

  @override
  String get xtreamDescription =>
      'Servidor, usuário e senha. TV ao vivo, filmes, séries.';

  @override
  String get m3uDescription =>
      'Um URL de lista ou um arquivo no seu computador.';

  @override
  String get notOpenedYet => 'Ainda não aberta';

  @override
  String get audioLanguage => 'Idioma do áudio';

  @override
  String get subtitles => 'Legendas';

  @override
  String get subtitlesOff => 'Desativadas';

  @override
  String trackNumber(String id) {
    return 'Faixa $id';
  }

  @override
  String get sortProvider => 'Ordem do provedor';

  @override
  String get sortName => 'Por nome';

  @override
  String get sortRating => 'Por avaliação';

  @override
  String get sortYear => 'Por ano';

  @override
  String get moviesFailed => 'Não foi possível carregar os filmes';

  @override
  String get seriesFailed => 'Não foi possível carregar as séries';

  @override
  String get allMovies => 'Todos os filmes';

  @override
  String get allSeries => 'Todas as séries';

  @override
  String get searchMovies => 'Buscar filmes';

  @override
  String get searchSeries => 'Buscar séries';

  @override
  String get noMatchingMovies => 'Nenhum filme corresponde';

  @override
  String get noMatchingSeries => 'Nenhuma série corresponde';

  @override
  String get loadingMovies => 'Carregando filmes…';

  @override
  String get loadingSeries => 'Carregando séries…';

  @override
  String get noDescription => 'Sem descrição.';

  @override
  String get director => 'Direção';

  @override
  String get cast => 'Elenco';

  @override
  String resumeAt(String position) {
    return 'Continuar · $position';
  }

  @override
  String get startOver => 'Recomeçar';

  @override
  String get seriesInfoFailed =>
      'Não foi possível carregar os detalhes da série';

  @override
  String get noEpisodes => 'Esta série não tem episódios';

  @override
  String seasonTab(int season, int count) {
    return 'Temporada $season · $count';
  }

  @override
  String episodeLong(int season, int episode, String title) {
    return 'Temporada $season, episódio $episode · $title';
  }

  @override
  String episodeCode(int season, int episode) {
    return 'T$season E$episode';
  }

  @override
  String playEpisode(String code) {
    return '$code · Reproduzir';
  }

  @override
  String resumeEpisode(String code) {
    return '$code · Continuar';
  }

  @override
  String episodeFallback(int number) {
    return 'Episódio $number';
  }

  @override
  String get watched => 'Assistido';

  @override
  String watchedUntil(String position) {
    return 'Assistido até $position';
  }

  @override
  String get playbackFailed => 'Não foi possível reproduzir';

  @override
  String errHttpStatus(int code) {
    return 'O servidor retornou $code.';
  }

  @override
  String errFetchFailed(String detail) {
    return 'Não foi possível carregar a lista: $detail';
  }

  @override
  String get errNoChannels => 'Nenhum canal encontrado na lista.';

  @override
  String get errNoLiveChannels => 'Nenhum canal ao vivo encontrado na conta.';

  @override
  String get errBadLogin => 'Usuário ou senha incorretos.';

  @override
  String errAccountUnavailable(String status) {
    return 'Conta indisponível (status: $status).';
  }

  @override
  String errConnect(String detail) {
    return 'Não foi possível conectar ao servidor: $detail';
  }

  @override
  String get errInvalidResponse =>
      'O servidor não retornou uma resposta Xtream Codes válida.';

  @override
  String get errNoMovies => 'Nenhum filme encontrado na conta.';

  @override
  String get errNoSeries => 'Nenhuma série encontrada na conta.';

  @override
  String errEpg(String detail) {
    return 'Não foi possível carregar o guia: $detail';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Idioma da interface do aplicativo';

  @override
  String get systemLanguage => 'Idioma do sistema';

  @override
  String systemLanguageCurrent(String language) {
    return 'Atual: $language';
  }

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsAboutText =>
      'Player de IPTV de código aberto para Windows, macOS e Linux.';

  @override
  String get translationNote =>
      'As traduções foram preparadas automaticamente; avise-nos se encontrar algum erro.';
}
