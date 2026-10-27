// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '本地音频剪辑';

  @override
  String get appName => '本地音剪';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '应用语言';

  @override
  String get settingsLanguageHint => '选择本应用显示的语言。';

  @override
  String get systemDefaultLanguage => '跟随系统';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '한국어';

  @override
  String get settingsSaveFailed => '无法保存语言设置，请重试。';

  @override
  String get localOnly => '仅本机';

  @override
  String get emptyTitle => '剪辑一段音频';

  @override
  String get emptyDescription => '选择设备中的音频，设定起止位置后试听并导出。';

  @override
  String get chooseAudio => '选择音频';

  @override
  String supportedFormats(String formats) {
    return '支持 $formats';
  }

  @override
  String get switchAudio => '更换';

  @override
  String get clipRange => '剪辑范围';

  @override
  String clipDuration(String duration) {
    return '片段 $duration';
  }

  @override
  String totalDuration(String duration) {
    return '总长 $duration';
  }

  @override
  String get dragHandlesHint => '拖动两端手柄，或点下方时间输入';

  @override
  String get startTime => '开始';

  @override
  String get endTime => '结束';

  @override
  String get pausePreview => '暂停试听';

  @override
  String get previewClip => '试听片段';

  @override
  String get exporting => '正在导出…';

  @override
  String get exportClip => '导出片段';

  @override
  String get localOnlyNote => '仅在本机处理 · 不上传、不自动同步';

  @override
  String get activitySelectAudio => '请选择音频文件…';

  @override
  String get activityReadingAudio => '正在读取音频…';

  @override
  String get activityAnalyzingWaveform => '正在分析波形…';

  @override
  String activityExportingFormat(String format) {
    return '正在导出 $format…';
  }

  @override
  String audioLoadFailed(String error) {
    return '无法打开音频：$error';
  }

  @override
  String get errorUnableReadDuration => '无法读取音频时长。请确认文件没有损坏，且编码格式受支持。';

  @override
  String get errorWaveformFailed => '读取成功，但生成波形失败。这个文件可能包含暂不支持的音频编码。';

  @override
  String get invalidTimeExample => '请输入有效时间，例如 00:12.50。';

  @override
  String get editStartPosition => '设置开始位置';

  @override
  String get editEndPosition => '设置结束位置';

  @override
  String get timePlaceholder => '例如 00:12.50 或 12.5';

  @override
  String get timeInputHint => '可输入 时:分:秒 或秒数';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String previewFailed(String error) {
    return '试听失败：$error';
  }

  @override
  String get selectExportFormat => '选择导出格式';

  @override
  String get exportLocalStorageDescription => '文件会在本机处理，保存位置由你选择。';

  @override
  String get formatMp3Description => '通用、体积小';

  @override
  String get formatM4aDescription => 'AAC 编码，适合手机播放';

  @override
  String get formatWavDescription => '未压缩，适合后续编辑';

  @override
  String get formatFlacDescription => '无损压缩';

  @override
  String get formatOggDescription => 'Vorbis 编码';

  @override
  String get formatOpusDescription => '高压缩率，适合语音';

  @override
  String get invalidFileName => '请输入文件名，且不要包含路径或特殊字符。';

  @override
  String get exportFilenameTitle => '自定义导出文件名';

  @override
  String get filenamePlaceholder => '输入文件名';

  @override
  String exportAsFormat(String format) {
    return '将导出为 $format，扩展名会自动添加。';
  }

  @override
  String get export => '导出';

  @override
  String get audioExportFailed => '音频导出失败。';

  @override
  String get shareTitle => '保存剪辑音频';

  @override
  String get exportSuccess => '音频已生成。可在系统分享面板中保存到设备。';

  @override
  String exportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get openSourceLicenses => '开源许可';

  @override
  String get close => '关闭';

  @override
  String get defaultAudioName => '音频';

  @override
  String get cutSuffix => '_剪辑';

  @override
  String get privacyPolicyBody =>
      '本地音剪隐私说明\n\n本地音剪由本地音剪项目维护者开发。隐私联系渠道：GitHub 项目问题反馈页（github.com/ponponon/audio-cut/issues）。请勿在公开问题中附上私人音频或敏感信息。\n\n音频文件\n你通过系统文件选择器主动选中的音频，仅用于在本机分析、试听、剪切和转码。应用会将工作副本和导出文件放在应用的临时目录；应用下次启动时会清理该工作目录。原始文件不会被应用修改。\n\n网络与收集\n应用不设账号、广告、云同步、远程分析或崩溃上报服务，不会由本应用把音频、文件名或其他个人数据发送给开发者或服务器。应用不申请全盘存储或麦克风权限；仅通过系统文件选择器读取你选中的文件。\n\n导出与第三方应用\n导出时，应用会打开系统分享面板。只有在你主动选择接收应用或保存位置后，导出文件才会交给该目标。接收应用可能按照自己的服务规则保存或传输文件；这部分不由本地音剪控制。\n\n删除与保留\n工作文件会在应用下次启动时清理。你也可以通过系统设置清除本应用数据或卸载应用，删除本应用保留在设备内的文件。你主动交给其他应用的副本，需要在对应应用中单独管理。\n\n联系与更新\n如对隐私处理有疑问，可通过 GitHub 项目问题反馈页联系维护者。应用功能或处理方式变更时，本说明会同步更新。';
}
