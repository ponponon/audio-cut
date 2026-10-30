// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Local Audio Cutter';

  @override
  String get appName => 'Audio Cut';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsLanguageHint => 'Choose the language used in this app.';

  @override
  String get systemDefaultLanguage => 'System default';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '한국어';

  @override
  String get settingsSaveFailed =>
      'Could not save your language preference. Try again.';

  @override
  String get localOnly => 'On this device';

  @override
  String get emptyTitle => 'Trim an audio file';

  @override
  String get emptyDescription =>
      'Choose audio on your device, set the range, preview it, and export.';

  @override
  String get chooseAudio => 'Choose audio';

  @override
  String supportedFormats(String formats) {
    return 'Supports $formats';
  }

  @override
  String get switchAudio => 'Change';

  @override
  String get clipRange => 'Selection';

  @override
  String clipDuration(String duration) {
    return 'Clip $duration';
  }

  @override
  String totalDuration(String duration) {
    return 'Total $duration';
  }

  @override
  String get dragHandlesHint =>
      'Drag either handle, or tap a time below to enter it';

  @override
  String get startTime => 'Start';

  @override
  String get endTime => 'End';

  @override
  String get pausePreview => 'Pause preview';

  @override
  String get previewClip => 'Preview selection';

  @override
  String get exporting => 'Exporting…';

  @override
  String get exportClip => 'Export selection';

  @override
  String get localOnlyNote =>
      'Processed on this device · Never uploaded or synced';

  @override
  String get activitySelectAudio => 'Choose an audio file…';

  @override
  String get activityReadingAudio => 'Reading audio…';

  @override
  String get activityAnalyzingWaveform => 'Analyzing waveform…';

  @override
  String activityExportingFormat(String format) {
    return 'Exporting $format…';
  }

  @override
  String audioLoadFailed(String error) {
    return 'Unable to open audio: $error';
  }

  @override
  String get errorUnableReadDuration =>
      'Could not read the audio duration. Check that the file is not damaged and its codec is supported.';

  @override
  String get errorWaveformFailed =>
      'Audio was read, but its waveform could not be generated. This audio codec may not be supported yet.';

  @override
  String get invalidTimeExample => 'Enter a valid time, such as 00:12.50.';

  @override
  String get editStartPosition => 'Set start time';

  @override
  String get editEndPosition => 'Set end time';

  @override
  String get timePlaceholder => 'For example, 00:12.50 or 12.5';

  @override
  String get timeInputHint => 'Enter hours:minutes:seconds or seconds';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Done';

  @override
  String previewFailed(String error) {
    return 'Preview failed: $error';
  }

  @override
  String get selectExportFormat => 'Choose an export format';

  @override
  String get exportLocalStorageDescription =>
      'Audio is processed on this device. Choose where to save it.';

  @override
  String get formatMp3Description => 'Widely compatible, small file size';

  @override
  String get formatM4aDescription => 'AAC encoding, great for phones';

  @override
  String get formatWavDescription => 'Uncompressed, ideal for further editing';

  @override
  String get formatFlacDescription => 'Lossless compression';

  @override
  String get formatOggDescription => 'Vorbis encoding';

  @override
  String get formatOpusDescription => 'High compression, great for voice';

  @override
  String get invalidFileName =>
      'Enter a file name without a path or special characters.';

  @override
  String get exportFilenameTitle => 'Name your export';

  @override
  String get filenamePlaceholder => 'File name';

  @override
  String exportAsFormat(String format) {
    return 'The file will be exported as $format; its extension is added automatically.';
  }

  @override
  String get saveToDevice => 'Save to Device';

  @override
  String get shareAction => 'Share';

  @override
  String get audioExportFailed => 'Audio export failed.';

  @override
  String get shareTitle => 'Save trimmed audio';

  @override
  String get exportSuccess =>
      'Audio is ready. Save it from the system share sheet.';

  @override
  String saveToDeviceSuccess(String path) {
    return 'Saved to $path';
  }

  @override
  String saveToDeviceSuccessFilesApp(String path) {
    return 'Saved to the app folder in the Files app: $path';
  }

  @override
  String get savePermissionFallbackShare =>
      'Storage permission was declined, so the share sheet was opened instead.';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get close => 'Close';

  @override
  String get defaultAudioName => 'audio';

  @override
  String get cutSuffix => '_cut';

  @override
  String get exportCopySuffix => '_copy';

  @override
  String get privacyPolicyBody =>
      'Audio Cut Privacy Notice\n\nAudio Cut is maintained by the Audio Cut project. For privacy questions, contact the maintainers through the GitHub issue tracker at github.com/ponponon/audio-cut/issues. Do not include private audio or sensitive information in public issues.\n\nAudio files\nAudio that you choose through the system file picker is used only for analysis, preview, trimming, and conversion on this device. Working copies and exports are kept in the app\'s temporary directory, which is cleared when the app next starts. The original file is never modified.\n\nNetwork and data collection\nThe app has no accounts, ads, cloud sync, remote analytics, or crash reporting. It does not send audio, file names, or other personal data to the developer or any server. The app does not request microphone access; it reads only files you select through the system picker. On Android 10 and later, saving an export needs no storage permission at all. On Android 9 and earlier, a storage permission is requested only when you save an export.\n\nExports and other apps\nWhen you export, you can save the file to this device\'s Music/AudioCut folder (on iPhone, to the app folder in the Files app), or open the system share sheet to hand it to another app. The file is handed to another app or save location only after you choose that destination. A receiving app may store or transmit the file under its own policies; Audio Cut does not control that.\n\nDeletion and retention\nWorking files are cleared the next time the app starts. Copies saved to the device\'s public folder are not cleared by the app. You can also clear the app\'s data in system settings or uninstall it to remove files retained by the app. Copies you share with other apps must be managed in those apps.\n\nContact and updates\nFor privacy questions, contact the maintainers through the GitHub issue tracker. This notice will be updated if the app\'s features or data handling change.';
}
