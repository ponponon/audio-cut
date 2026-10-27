import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
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
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Audio Cutter'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Audio Cut'**
  String get appName;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used in this app.'**
  String get settingsLanguageHint;

  /// No description provided for @systemDefaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefaultLanguage;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChineseSimplified;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your language preference. Try again.'**
  String get settingsSaveFailed;

  /// No description provided for @localOnly.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get localOnly;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Trim an audio file'**
  String get emptyTitle;

  /// No description provided for @emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose audio on your device, set the range, preview it, and export.'**
  String get emptyDescription;

  /// No description provided for @chooseAudio.
  ///
  /// In en, this message translates to:
  /// **'Choose audio'**
  String get chooseAudio;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supports {formats}'**
  String supportedFormats(String formats);

  /// No description provided for @switchAudio.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get switchAudio;

  /// No description provided for @clipRange.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get clipRange;

  /// No description provided for @clipDuration.
  ///
  /// In en, this message translates to:
  /// **'Clip {duration}'**
  String clipDuration(String duration);

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total {duration}'**
  String totalDuration(String duration);

  /// No description provided for @dragHandlesHint.
  ///
  /// In en, this message translates to:
  /// **'Drag either handle, or tap a time below to enter it'**
  String get dragHandlesHint;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endTime;

  /// No description provided for @pausePreview.
  ///
  /// In en, this message translates to:
  /// **'Pause preview'**
  String get pausePreview;

  /// No description provided for @previewClip.
  ///
  /// In en, this message translates to:
  /// **'Preview selection'**
  String get previewClip;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get exporting;

  /// No description provided for @exportClip.
  ///
  /// In en, this message translates to:
  /// **'Export selection'**
  String get exportClip;

  /// No description provided for @localOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Processed on this device · Never uploaded or synced'**
  String get localOnlyNote;

  /// No description provided for @activitySelectAudio.
  ///
  /// In en, this message translates to:
  /// **'Choose an audio file…'**
  String get activitySelectAudio;

  /// No description provided for @activityReadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Reading audio…'**
  String get activityReadingAudio;

  /// No description provided for @activityAnalyzingWaveform.
  ///
  /// In en, this message translates to:
  /// **'Analyzing waveform…'**
  String get activityAnalyzingWaveform;

  /// No description provided for @activityExportingFormat.
  ///
  /// In en, this message translates to:
  /// **'Exporting {format}…'**
  String activityExportingFormat(String format);

  /// No description provided for @audioLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open audio: {error}'**
  String audioLoadFailed(String error);

  /// No description provided for @errorUnableReadDuration.
  ///
  /// In en, this message translates to:
  /// **'Could not read the audio duration. Check that the file is not damaged and its codec is supported.'**
  String get errorUnableReadDuration;

  /// No description provided for @errorWaveformFailed.
  ///
  /// In en, this message translates to:
  /// **'Audio was read, but its waveform could not be generated. This audio codec may not be supported yet.'**
  String get errorWaveformFailed;

  /// No description provided for @invalidTimeExample.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time, such as 00:12.50.'**
  String get invalidTimeExample;

  /// No description provided for @editStartPosition.
  ///
  /// In en, this message translates to:
  /// **'Set start time'**
  String get editStartPosition;

  /// No description provided for @editEndPosition.
  ///
  /// In en, this message translates to:
  /// **'Set end time'**
  String get editEndPosition;

  /// No description provided for @timePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'For example, 00:12.50 or 12.5'**
  String get timePlaceholder;

  /// No description provided for @timeInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter hours:minutes:seconds or seconds'**
  String get timeInputHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get confirm;

  /// No description provided for @previewFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview failed: {error}'**
  String previewFailed(String error);

  /// No description provided for @selectExportFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose an export format'**
  String get selectExportFormat;

  /// No description provided for @exportLocalStorageDescription.
  ///
  /// In en, this message translates to:
  /// **'Audio is processed on this device. Choose where to save it.'**
  String get exportLocalStorageDescription;

  /// No description provided for @formatMp3Description.
  ///
  /// In en, this message translates to:
  /// **'Widely compatible, small file size'**
  String get formatMp3Description;

  /// No description provided for @formatM4aDescription.
  ///
  /// In en, this message translates to:
  /// **'AAC encoding, great for phones'**
  String get formatM4aDescription;

  /// No description provided for @formatWavDescription.
  ///
  /// In en, this message translates to:
  /// **'Uncompressed, ideal for further editing'**
  String get formatWavDescription;

  /// No description provided for @formatFlacDescription.
  ///
  /// In en, this message translates to:
  /// **'Lossless compression'**
  String get formatFlacDescription;

  /// No description provided for @formatOggDescription.
  ///
  /// In en, this message translates to:
  /// **'Vorbis encoding'**
  String get formatOggDescription;

  /// No description provided for @formatOpusDescription.
  ///
  /// In en, this message translates to:
  /// **'High compression, great for voice'**
  String get formatOpusDescription;

  /// No description provided for @invalidFileName.
  ///
  /// In en, this message translates to:
  /// **'Enter a file name without a path or special characters.'**
  String get invalidFileName;

  /// No description provided for @exportFilenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your export'**
  String get exportFilenameTitle;

  /// No description provided for @filenamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get filenamePlaceholder;

  /// No description provided for @exportAsFormat.
  ///
  /// In en, this message translates to:
  /// **'The file will be exported as {format}; its extension is added automatically.'**
  String exportAsFormat(String format);

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @audioExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Audio export failed.'**
  String get audioExportFailed;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Save trimmed audio'**
  String get shareTitle;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Audio is ready. Save it from the system share sheet.'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @defaultAudioName.
  ///
  /// In en, this message translates to:
  /// **'audio'**
  String get defaultAudioName;

  /// No description provided for @cutSuffix.
  ///
  /// In en, this message translates to:
  /// **'_cut'**
  String get cutSuffix;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'Audio Cut Privacy Notice\n\nAudio Cut is maintained by the Audio Cut project. For privacy questions, contact the maintainers through the GitHub issue tracker at github.com/ponponon/audio-cut/issues. Do not include private audio or sensitive information in public issues.\n\nAudio files\nAudio that you choose through the system file picker is used only for analysis, preview, trimming, and conversion on this device. Working copies and exports are kept in the app\'s temporary directory, which is cleared when the app next starts. The original file is never modified.\n\nNetwork and data collection\nThe app has no accounts, ads, cloud sync, remote analytics, or crash reporting. It does not send audio, file names, or other personal data to the developer or any server. The app does not request broad storage or microphone access; it reads only files you select through the system picker.\n\nExports and other apps\nWhen you export, the app opens the system share sheet. The file is handed to another app or save location only after you choose that destination. A receiving app may store or transmit the file under its own policies; Audio Cut does not control that.\n\nDeletion and retention\nWorking files are cleared the next time the app starts. You can also clear the app\'s data in system settings or uninstall it to remove files retained by the app. Copies you share with other apps must be managed in those apps.\n\nContact and updates\nFor privacy questions, contact the maintainers through the GitHub issue tracker. This notice will be updated if the app\'s features or data handling change.'**
  String get privacyPolicyBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
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
