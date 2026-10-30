import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const LocalAudioCutApp());
}

class _EditorPalette {
  const _EditorPalette({
    required this.canvas,
    required this.surface,
    required this.secondarySurface,
    required this.ink,
    required this.secondaryInk,
    required this.separator,
    required this.accent,
    required this.onAccent,
    required this.glassSurface,
    required this.waveformTrack,
  });

  final Color canvas;
  final Color surface;
  final Color secondarySurface;
  final Color ink;
  final Color secondaryInk;
  final Color separator;
  final Color accent;
  final Color onAccent;
  final Color glassSurface;
  final Color waveformTrack;

  static const light = _EditorPalette(
    canvas: Color(0xFFF4F7F4),
    surface: Color(0xFFFFFFFF),
    secondarySurface: Color(0xFFE6EFE7),
    ink: Color(0xFF1C271F),
    secondaryInk: Color(0xFF58675C),
    separator: Color(0xFFD0DBD2),
    accent: Color(0xFF167A4B),
    onAccent: Color(0xFFFFFFFF),
    glassSurface: Color(0xE8FFFFFF),
    waveformTrack: Color(0xFFF2F7F3),
  );

  static const dark = _EditorPalette(
    canvas: Color(0xFF0D1510),
    surface: Color(0xFF19221B),
    secondarySurface: Color(0xFF253128),
    ink: Color(0xFFEEF5EF),
    secondaryInk: Color(0xFFA8B7AB),
    separator: Color(0xFF3A493E),
    accent: Color(0xFF63CC90),
    onAccent: Color(0xFF102719),
    glassSurface: Color(0xD9151E18),
    waveformTrack: Color(0xFF111A14),
  );

  static _EditorPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

ThemeData _buildTheme(_EditorPalette palette, Brightness brightness) {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: palette.accent,
        brightness: brightness,
        surface: palette.surface,
      ).copyWith(
        primary: palette.accent,
        onPrimary: palette.onAccent,
        secondary: palette.accent,
        onSecondary: palette.onAccent,
        surface: palette.surface,
        onSurface: palette.ink,
        outline: palette.separator,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.canvas,
    dividerColor: palette.separator,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.canvas,
      foregroundColor: palette.ink,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: palette.ink,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: palette.onAccent,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.secondarySurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.accent, width: 2),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: palette.separator,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.ink,
      contentTextStyle: TextStyle(color: palette.canvas),
    ),
  );
}

const _formats = <_ExportFormat>[
  _ExportFormat('MP3', 'mp3', ['-c:a', 'libmp3lame', '-q:a', '2']),
  _ExportFormat('M4A', 'm4a', ['-c:a', 'aac', '-b:a', '192k', '-f', 'ipod']),
  _ExportFormat('WAV', 'wav', ['-c:a', 'pcm_s16le', '-f', 'wav']),
  _ExportFormat('FLAC', 'flac', ['-c:a', 'flac', '-compression_level', '5']),
  _ExportFormat('OGG', 'ogg', ['-c:a', 'libvorbis', '-q:a', '5', '-f', 'ogg']),
  _ExportFormat('Opus', 'opus', [
    '-c:a',
    'libopus',
    '-b:a',
    '128k',
    '-f',
    'opus',
  ]),
];

class LocalAudioCutApp extends StatefulWidget {
  const LocalAudioCutApp({super.key});

  @override
  State<LocalAudioCutApp> createState() => _LocalAudioCutAppState();
}

class _LocalAudioCutAppState extends State<LocalAudioCutApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreLocalePreference());
  }

  Future<void> _restoreLocalePreference() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final preferenceFile = File(p.join(directory.path, 'locale.preference'));
      if (!await preferenceFile.exists()) return;
      final languageCode = (await preferenceFile.readAsString()).trim();
      final locale = _localeForLanguageCode(languageCode);
      if (mounted && locale != null) setState(() => _locale = locale);
    } catch (_) {
      // Keep following the system language if the local preference is unreadable.
    }
  }

  Future<void> _setLocale(Locale? locale) async {
    if (locale != null && !AppLocalizations.supportedLocales.contains(locale)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported app locale');
    }
    final directory = await getApplicationSupportDirectory();
    final preferenceFile = File(p.join(directory.path, 'locale.preference'));
    if (locale == null) {
      if (await preferenceFile.exists()) await preferenceFile.delete();
    } else {
      await preferenceFile.writeAsString(locale.languageCode, flush: true);
    }
    if (mounted) setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(_EditorPalette.light, Brightness.light),
      darkTheme: _buildTheme(_EditorPalette.dark, Brightness.dark),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _EditorScreen(locale: _locale, onLocaleChanged: _setLocale),
    );
  }
}

class _EditorScreen extends StatefulWidget {
  const _EditorScreen({required this.locale, required this.onLocaleChanged});

  final Locale? locale;
  final Future<void> Function(Locale?) onLocaleChanged;

  @override
  State<_EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<_EditorScreen> {
  final AudioPlayer _player = AudioPlayer();

  AppLocalizations get _l10n => AppLocalizations.of(context);

  late final Future<Directory> _workDirectoryFuture;
  Directory? _workDirectory;
  String? _sourcePath;
  String? _waveformPath;
  String _sourceName = '';
  String _sourceFormat = '';
  Duration _duration = Duration.zero;
  Duration _cutStart = Duration.zero;
  Duration _cutEnd = Duration.zero;
  bool _loading = false;
  bool _exporting = false;
  String _activity = '';

  static const _inputExtensions = <String>[
    'mp3',
    'm4a',
    'aac',
    'wav',
    'wave',
    'flac',
    'ogg',
    'opus',
    'aiff',
    'aif',
    'caf',
    'amr',
    'wma',
    'ape',
  ];

  @override
  void initState() {
    super.initState();
    _workDirectoryFuture = _preparePrivateWorkDirectory();
  }

  Future<Directory> _preparePrivateWorkDirectory() async {
    final temporary = await getTemporaryDirectory();
    final directory = Directory(p.join(temporary.path, 'audio_cut_private'));
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await directory.create(recursive: true);
    _workDirectory = directory;
    return directory;
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _pickAudio() async {
    if (_loading || _exporting) return;
    setState(() {
      _loading = true;
      _activity = _l10n.activitySelectAudio;
    });
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: _inputExtensions,
      );
      if (picked == null) {
        if (mounted) {
          setState(() {
            _loading = false;
            _activity = '';
          });
        }
        return;
      }
      if (!mounted) return;
      setState(() => _activity = _l10n.activityReadingAudio);
      final directory = _workDirectory ?? await _workDirectoryFuture;
      final extension = p
          .extension(picked.name)
          .replaceFirst('.', '')
          .toLowerCase();
      final source = File(
        p.join(
          directory.path,
          'source_${DateTime.now().microsecondsSinceEpoch}.${extension.isEmpty ? 'audio' : extension}',
        ),
      );
      final sourceSink = source.openWrite();
      try {
        await sourceSink.addStream(picked.readAsByteStream());
      } finally {
        await sourceSink.close();
      }

      setState(() => _activity = _l10n.activityAnalyzingWaveform);
      final probeSession = await FFprobeKit.getMediaInformation(source.path);
      final media = probeSession.getMediaInformation();
      final seconds = double.tryParse(media?.getDuration() ?? '');
      if (seconds == null || !seconds.isFinite || seconds <= 0) {
        throw FormatException(_l10n.errorUnableReadDuration);
      }
      final duration = Duration(
        microseconds: (seconds * Duration.microsecondsPerSecond).round(),
      );

      final waveform = File(
        p.join(
          directory.path,
          'waveform_${DateTime.now().microsecondsSinceEpoch}.png',
        ),
      );
      final waveformSession = await FFmpegKit.executeWithArguments([
        '-hide_banner',
        '-nostdin',
        '-y',
        '-i',
        source.path,
        '-vn',
        '-filter_complex',
        'aformat=channel_layouts=mono,showwavespic=s=1800x220:colors=white:scale=sqrt',
        '-frames:v',
        '1',
        waveform.path,
      ]);
      final waveformCode = await waveformSession.getReturnCode();
      if (!ReturnCode.isSuccess(waveformCode) || !await waveform.exists()) {
        throw FormatException(_l10n.errorWaveformFailed);
      }

      await _player.stop();
      try {
        await _player.setFilePath(source.path);
      } catch (_) {
        // Some device decoders support fewer formats than FFmpeg. Make a private
        // AAC preview copy so importing and exporting can still work.
        final preview = File(
          p.join(
            directory.path,
            'preview_${DateTime.now().microsecondsSinceEpoch}.m4a',
          ),
        );
        final previewSession = await FFmpegKit.executeWithArguments([
          '-hide_banner',
          '-nostdin',
          '-y',
          '-i',
          source.path,
          '-vn',
          '-c:a',
          'aac',
          '-b:a',
          '192k',
          '-f',
          'ipod',
          preview.path,
        ]);
        if (ReturnCode.isSuccess(await previewSession.getReturnCode()) &&
            await preview.exists()) {
          await _player.setFilePath(preview.path);
        }
      }

      if (!mounted) return;
      setState(() {
        _sourcePath = source.path;
        _waveformPath = waveform.path;
        _sourceName = picked.name;
        _sourceFormat = extension.isEmpty
            ? _l10n.defaultAudioName
            : extension.toUpperCase();
        _duration = duration;
        _cutStart = Duration.zero;
        _cutEnd = duration;
        _loading = false;
        _activity = '';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _activity = '';
      });
      _showMessage(_l10n.audioLoadFailed(_friendlyError(error)));
    }
  }

  Future<void> _editTime({required bool editStart}) async {
    final palette = _EditorPalette.of(context);
    final controller = TextEditingController(
      text: _durationText(editStart ? _cutStart : _cutEnd),
    );
    final value = await showCupertinoDialog<Duration>(
      context: context,
      builder: (dialogContext) {
        void submit() {
          final parsed = _parseDuration(controller.text);
          if (parsed == null) {
            _showMessage(_l10n.invalidTimeExample);
            return;
          }
          Navigator.pop(dialogContext, parsed);
        }

        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Theme.of(dialogContext).brightness,
            primaryColor: palette.accent,
          ),
          child: CupertinoAlertDialog(
            title: Text(
              editStart ? _l10n.editStartPosition : _l10n.editEndPosition,
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: palette.ink, fontSize: 17),
                    placeholder: _l10n.timePlaceholder,
                    placeholderStyle: TextStyle(
                      color: palette.secondaryInk,
                      fontSize: 15,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: palette.secondarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSubmitted: (_) => submit(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _l10n.timeInputHint,
                    style: TextStyle(color: palette.secondaryInk, fontSize: 13),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(_l10n.cancel),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: submit,
                child: Text(_l10n.confirm),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (value == null) return;
    _updateRange(editStart ? value : _cutStart, editStart ? _cutEnd : value);
  }

  Duration? _parseDuration(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final parts = value.split(':');
    double seconds;
    if (parts.length == 1) {
      seconds = double.tryParse(parts.single) ?? double.nan;
    } else if (parts.length == 2) {
      seconds =
          (double.tryParse(parts[0]) ?? double.nan) * 60 +
          (double.tryParse(parts[1]) ?? double.nan);
    } else if (parts.length == 3) {
      seconds =
          (double.tryParse(parts[0]) ?? double.nan) * 3600 +
          (double.tryParse(parts[1]) ?? double.nan) * 60 +
          (double.tryParse(parts[2]) ?? double.nan);
    } else {
      return null;
    }
    if (!seconds.isFinite ||
        seconds < 0 ||
        seconds > _duration.inMicroseconds / 1e6) {
      return null;
    }
    return Duration(
      microseconds: (seconds * Duration.microsecondsPerSecond).round(),
    );
  }

  void _updateRange(Duration start, Duration end) {
    final totalMicros = _duration.inMicroseconds;
    if (totalMicros <= 0) return;
    final gap = math
        .min(totalMicros, const Duration(milliseconds: 100).inMicroseconds)
        .toInt();
    var startMicros = start.inMicroseconds.clamp(0, totalMicros - gap).toInt();
    var endMicros = end.inMicroseconds.clamp(gap, totalMicros).toInt();
    if (startMicros >= endMicros) {
      if (startMicros == start.inMicroseconds) {
        endMicros = math.min(totalMicros, startMicros + gap);
      } else {
        startMicros = math.max(0, endMicros - gap);
      }
    }
    setState(() {
      _cutStart = Duration(microseconds: startMicros);
      _cutEnd = Duration(microseconds: endMicros);
    });
  }

  Future<void> _togglePreview() async {
    if (_sourcePath == null || _duration == Duration.zero) return;
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.setClip(start: _cutStart, end: _cutEnd);
        await _player.seek(_cutStart);
        unawaited(_player.play());
      }
    } catch (error) {
      _showMessage(_l10n.previewFailed(_friendlyError(error)));
    }
  }

  Future<void> _showExportFormats() async {
    if (_sourcePath == null || _exporting) return;
    final palette = _EditorPalette.of(context);
    final selected = await showModalBottomSheet<_ExportFormat>(
      context: context,
      backgroundColor: palette.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final maxSheetHeight = MediaQuery.of(context).size.height * 0.9;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectExportFormat,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.exportLocalStorageDescription,
                    style: TextStyle(color: palette.secondaryInk, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  for (var index = 0; index < _formats.length; index++) ...[
                    if (index > 0) Divider(height: 1, color: palette.separator),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 14,
                      title: Text(
                        _formats[index].label,
                        style: TextStyle(
                          color: palette.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _formatDescription(l10n, _formats[index]),
                        style: TextStyle(color: palette.secondaryInk),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: palette.secondaryInk,
                      ),
                      onTap: () => Navigator.pop(context, _formats[index]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    final request = await _requestExportBaseName(selected);
    if (request == null || !mounted) return;
    final (exportBaseName, exportAction) = request;
    await _export(selected, exportBaseName, exportAction);
  }

  String _suggestedExportBaseName() {
    var baseName = p
        .basenameWithoutExtension(_sourceName)
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim()
        .replaceAll(RegExp(r'[. ]+$'), '');
    if (baseName.isEmpty) baseName = _l10n.defaultAudioName;
    final suffix = _l10n.cutSuffix;
    final alreadyHasCutSuffix = baseName.toLowerCase().endsWith(
      suffix.toLowerCase(),
    );
    baseName = alreadyHasCutSuffix
        ? '$baseName${_l10n.exportCopySuffix}'
        : '$baseName$suffix';
    return baseName;
  }

  String _formatDescription(AppLocalizations l10n, _ExportFormat format) =>
      switch (format.extension) {
        'mp3' => l10n.formatMp3Description,
        'm4a' => l10n.formatM4aDescription,
        'wav' => l10n.formatWavDescription,
        'flac' => l10n.formatFlacDescription,
        'ogg' => l10n.formatOggDescription,
        'opus' => l10n.formatOpusDescription,
        _ => '',
      };

  String? _normalizeExportBaseName(String raw) {
    var baseName = raw.trim();
    final extension = p.extension(baseName).toLowerCase();
    if (_formats.any((format) => extension == '.${format.extension}')) {
      baseName = baseName.substring(0, baseName.length - extension.length);
    }
    baseName = baseName.trim().replaceAll(RegExp(r'[. ]+$'), '');
    if (baseName.isEmpty || RegExp(r'[\\/:*?"<>|]').hasMatch(baseName)) {
      return null;
    }
    return baseName;
  }

  Future<(String, _ExportAction)?> _requestExportBaseName(
    _ExportFormat format,
  ) async {
    final palette = _EditorPalette.of(context);
    final controller = TextEditingController(text: _suggestedExportBaseName());
    String? validationMessage;
    final result = await showCupertinoDialog<(String, _ExportAction)>(
      context: context,
      builder: (dialogContext) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(dialogContext).brightness,
          primaryColor: palette.accent,
        ),
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void submit(_ExportAction action) {
              final baseName = _normalizeExportBaseName(controller.text);
              if (baseName == null) {
                setDialogState(() {
                  validationMessage = _l10n.invalidFileName;
                });
                return;
              }
              Navigator.pop(dialogContext, (baseName, action));
            }

            return CupertinoAlertDialog(
              title: Text(_l10n.exportFilenameTitle),
              content: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextField(
                      controller: controller,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(color: palette.ink, fontSize: 17),
                      placeholder: _l10n.filenamePlaceholder,
                      placeholderStyle: TextStyle(
                        color: palette.secondaryInk,
                        fontSize: 15,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: palette.secondarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          '.${format.extension}',
                          style: TextStyle(
                            color: palette.secondaryInk,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        if (validationMessage != null) {
                          setDialogState(() => validationMessage = null);
                        }
                      },
                      onSubmitted: (_) => submit(_ExportAction.save),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _l10n.exportAsFormat(format.label),
                      style: TextStyle(
                        color: palette.secondaryInk,
                        fontSize: 13,
                      ),
                    ),
                    if (validationMessage != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          validationMessage ?? '',
                          style: TextStyle(color: palette.accent, fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => submit(_ExportAction.save),
                  child: Text(_l10n.saveToDevice),
                ),
                CupertinoDialogAction(
                  onPressed: () => submit(_ExportAction.share),
                  child: Text(_l10n.shareAction),
                ),
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(_l10n.cancel),
                ),
              ],
            );
          },
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _export(
    _ExportFormat format,
    String exportBaseName,
    _ExportAction action,
  ) async {
    final source = _sourcePath;
    if (source == null) return;
    final exportName = '$exportBaseName.${format.extension}';
    if (!mounted) return;

    setState(() {
      _exporting = true;
      _activity = _l10n.activityExportingFormat(format.label);
    });
    try {
      final directory = _workDirectory ?? await _workDirectoryFuture;
      final exportDirectory = Directory(
        p.join(
          directory.path,
          'export_${DateTime.now().microsecondsSinceEpoch}',
        ),
      );
      await exportDirectory.create(recursive: true);
      final output = File(p.join(exportDirectory.path, exportName));
      final outputPath = output.path;

      final arguments = <String>[
        '-hide_banner',
        '-nostdin',
        '-y',
        '-i',
        source,
        '-ss',
        (_cutStart.inMicroseconds / Duration.microsecondsPerSecond)
            .toStringAsFixed(3),
        '-t',
        ((_cutEnd - _cutStart).inMicroseconds / Duration.microsecondsPerSecond)
            .toStringAsFixed(3),
        '-vn',
        ...format.codecArguments,
        outputPath,
      ];
      final session = await FFmpegKit.executeWithArguments(arguments);
      if (!ReturnCode.isSuccess(await session.getReturnCode())) {
        final output = await session.getOutput();
        throw FileSystemException(
          output?.trim().isNotEmpty == true
              ? output!.trim()
              : _l10n.audioExportFailed,
        );
      }
      if (action == _ExportAction.save) {
        await _saveToDevice(outputPath, exportName, format);
      } else {
        await _shareExport(outputPath, exportName, format);
        if (!mounted) return;
        _showMessage(_l10n.exportSuccess);
      }
    } catch (error) {
      if (mounted) _showMessage(_l10n.exportFailed(_friendlyError(error)));
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _activity = '';
        });
      }
    }
  }

  Future<void> _shareExport(
    String outputPath,
    String exportName,
    _ExportFormat format,
  ) {
    return SharePlus.instance.share(
      ShareParams(
        title: _l10n.shareTitle,
        subject: exportName,
        files: [XFile(outputPath, mimeType: _mimeType(format.extension))],
      ),
    );
  }

  Future<void> _saveToDevice(
    String outputPath,
    String exportName,
    _ExportFormat format,
  ) async {
    try {
      final displayPath = await _DeviceSaver.saveAudio(
        sourcePath: outputPath,
        fileName: exportName,
        mimeType: _mimeType(format.extension),
      );
      if (!mounted) return;
      _showMessage(
        Platform.isIOS
            ? _l10n.saveToDeviceSuccessFilesApp(displayPath)
            : _l10n.saveToDeviceSuccess(displayPath),
      );
    } on PlatformException catch (error) {
      if (error.code != 'permission_denied') rethrow;
      if (!mounted) return;
      _showMessage(_l10n.savePermissionFallbackShare);
      await _shareExport(outputPath, exportName, format);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPrivacyPolicy() {
    final palette = _EditorPalette.of(context);
    final maxContentHeight = math.min(
      MediaQuery.sizeOf(context).height * .56,
      440.0,
    );
    unawaited(
      showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Theme.of(dialogContext).brightness,
            primaryColor: palette.accent,
          ),
          child: CupertinoAlertDialog(
            title: Text(_l10n.privacyPolicy),
            content: SizedBox(
              height: maxContentHeight,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  _l10n.privacyPolicyBody,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: palette.secondaryInk,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showLicensePage(
                    context: context,
                    applicationName: _l10n.appName,
                  );
                },
                child: Text(_l10n.openSourceLicenses),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(_l10n.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSettings() async {
    final palette = _EditorPalette.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        final maxSheetHeight = MediaQuery.sizeOf(sheetContext).height * .82;
        final options = <_LanguageOption>[
          _LanguageOption(null, l10n.systemDefaultLanguage),
          _LanguageOption(const Locale('zh'), l10n.languageChineseSimplified),
          _LanguageOption(const Locale('en'), l10n.languageEnglish),
          _LanguageOption(const Locale('ja'), l10n.languageJapanese),
          _LanguageOption(const Locale('ko'), l10n.languageKorean),
        ];
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsTitle,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.settingsLanguage,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.settingsLanguageHint,
                    style: TextStyle(color: palette.secondaryInk),
                  ),
                  const SizedBox(height: 8),
                  for (final option in options)
                    _languageOptionTile(option, l10n, palette, sheetContext),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _languageOptionTile(
    _LanguageOption option,
    AppLocalizations l10n,
    _EditorPalette palette,
    BuildContext sheetContext,
  ) {
    final selected = widget.locale == option.locale;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 10,
      selected: selected,
      title: Text(
        option.label,
        style: TextStyle(
          color: selected ? palette.accent : palette.ink,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: Icon(
        selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        color: selected ? palette.accent : palette.secondaryInk,
      ),
      onTap: () async {
        try {
          await widget.onLocaleChanged(option.locale);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        } catch (_) {
          if (mounted) _showMessage(l10n.settingsSaveFailed);
        }
      },
    );
  }

  String _friendlyError(Object error) {
    if (error is FormatException) return error.message;
    if (error is FileSystemException && error.message.isNotEmpty) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  String _mimeType(String extension) => switch (extension) {
    'mp3' => 'audio/mpeg',
    'm4a' => 'audio/mp4',
    'wav' => 'audio/wav',
    'flac' => 'audio/flac',
    'ogg' => 'audio/ogg',
    'opus' => 'audio/opus',
    _ => 'application/octet-stream',
  };

  @override
  Widget build(BuildContext context) {
    final palette = _EditorPalette.of(context);
    final hasAudio = _sourcePath != null;
    return Scaffold(
      extendBody: hasAudio,
      appBar: AppBar(
        title: Text(_l10n.appName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _showPrivacyPolicy,
              icon: Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: palette.secondaryInk,
              ),
              label: Text(
                _l10n.localOnly,
                style: TextStyle(
                  color: palette.secondaryInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          IconButton(
            tooltip: _l10n.settingsTitle,
            onPressed: _showSettings,
            icon: const Icon(Icons.settings_outlined),
            color: palette.secondaryInk,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: hasAudio ? _editorBody(palette) : _emptyState(palette),
      ),
      bottomNavigationBar: hasAudio ? _bottomAction(palette) : null,
    );
  }

  Widget _emptyState(_EditorPalette palette) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      children: [
        Center(
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.graphic_eq_rounded,
              color: palette.accent,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _l10n.emptyTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.ink,
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _l10n.emptyDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.secondaryInk,
            fontSize: 16,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _loading ? null : _pickAudio,
            icon: const Icon(Icons.folder_open_rounded),
            label: Text(_l10n.chooseAudio),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _l10n.supportedFormats('MP3 · M4A · WAV · FLAC · OGG · Opus'),
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.secondaryInk, fontSize: 14),
        ),
        if (_activity.isNotEmpty) ...[
          const SizedBox(height: 24),
          _activityIndicator(palette),
        ],
        const SizedBox(height: 34),
        _privacyNote(palette),
      ],
    );
  }

  Widget _editorBody(_EditorPalette palette) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewPaddingOf(context).bottom + 96,
      ),
      children: [
        _fileHeader(palette),
        const SizedBox(height: 22),
        _waveformCard(palette),
        const SizedBox(height: 12),
        _timeControls(palette),
        const SizedBox(height: 22),
        _playbackCard(palette),
        if (_activity.isNotEmpty) ...[
          const SizedBox(height: 18),
          _activityIndicator(palette),
        ],
        const SizedBox(height: 22),
        _privacyNote(palette),
      ],
    );
  }

  Widget _fileHeader(_EditorPalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _sourceName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 21,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$_sourceFormat  ·  ${_durationText(_duration)}',
                style: TextStyle(color: palette.secondaryInk, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: _loading || _exporting ? null : _pickAudio,
          icon: const Icon(Icons.swap_horiz_rounded, size: 18),
          label: Text(_l10n.switchAudio),
          style: TextButton.styleFrom(
            foregroundColor: palette.accent,
            minimumSize: const Size(48, 48),
          ),
        ),
      ],
    );
  }

  Widget _waveformCard(_EditorPalette palette) {
    final clipLength = _cutEnd - _cutStart;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.clipRange,
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _l10n.clipDuration(_durationText(clipLength)),
                    style: TextStyle(
                      color: palette.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _l10n.totalDuration(_durationText(_duration)),
                    style: TextStyle(color: palette.secondaryInk, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final total = math.max(1, _duration.inMicroseconds).toDouble();
              final startRatio = (_cutStart.inMicroseconds / total)
                  .clamp(0.0, 1.0)
                  .toDouble();
              final endRatio = (_cutEnd.inMicroseconds / total)
                  .clamp(0.0, 1.0)
                  .toDouble();
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) => _startWaveDrag(
                  details.localPosition.dx,
                  width,
                  startRatio,
                  endRatio,
                ),
                onPanUpdate: (details) =>
                    _moveWaveHandle(details.localPosition.dx, width),
                onTapDown: (details) => _startWaveDrag(
                  details.localPosition.dx,
                  width,
                  startRatio,
                  endRatio,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: SizedBox(
                    width: width,
                    height: 142,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: palette.waveformTrack),
                        if (_waveformPath != null)
                          Image.file(
                            File(_waveformPath!),
                            fit: BoxFit.fill,
                            color: palette.accent,
                            colorBlendMode: BlendMode.srcIn,
                          )
                        else
                          Center(
                            child: Icon(
                              Icons.graphic_eq_rounded,
                              color: palette.accent,
                              size: 42,
                            ),
                          ),
                        IgnorePointer(
                          child: CustomPaint(
                            painter: _SelectionPainter(
                              startRatio: startRatio,
                              endRatio: endRatio,
                              dimColor: palette.waveformTrack,
                              accentColor: palette.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _durationText(_cutStart),
                style: TextStyle(color: palette.secondaryInk, fontSize: 12),
              ),
              const Spacer(),
              Text(
                _durationText(_cutEnd),
                style: TextStyle(color: palette.secondaryInk, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              _l10n.dragHandlesHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.secondaryInk, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  bool _draggingStart = true;

  void _startWaveDrag(
    double x,
    double width,
    double startRatio,
    double endRatio,
  ) {
    if (_duration == Duration.zero || width <= 0) return;
    final ratio = (x / width).clamp(0.0, 1.0);
    _draggingStart = (ratio - startRatio).abs() <= (ratio - endRatio).abs();
    _moveWaveHandle(x, width);
  }

  void _moveWaveHandle(double x, double width) {
    if (_duration == Duration.zero || width <= 0) return;
    final ratio = (x / width).clamp(0.0, 1.0);
    final selected = Duration(
      microseconds: (_duration.inMicroseconds * ratio).round(),
    );
    if (_draggingStart) {
      _updateRange(selected, _cutEnd);
    } else {
      _updateRange(_cutStart, selected);
    }
  }

  Widget _timeControls(_EditorPalette palette) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.2;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = largeText || constraints.maxWidth < 350;
        return Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: stacked
              ? Column(
                  children: [
                    _timeButton(_l10n.startTime, _cutStart, palette, true),
                    Divider(height: 1, color: palette.separator),
                    _timeButton(_l10n.endTime, _cutEnd, palette, false),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _timeButton(
                        _l10n.startTime,
                        _cutStart,
                        palette,
                        true,
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: palette.separator,
                      ),
                    ),
                    Expanded(
                      child: _timeButton(
                        _l10n.endTime,
                        _cutEnd,
                        palette,
                        false,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _timeButton(
    String title,
    Duration time,
    _EditorPalette palette,
    bool editStart,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _editTime(editStart: editStart),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: palette.secondaryInk, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _durationText(time),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: palette.secondaryInk,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playbackCard(_EditorPalette palette) {
    final clipLength = _cutEnd - _cutStart;
    return Row(
      children: [
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            return IconButton.filled(
              tooltip: playing ? _l10n.pausePreview : _l10n.previewClip,
              onPressed: _loading || _exporting ? null : _togglePreview,
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              style: IconButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.onAccent,
                minimumSize: const Size(52, 52),
              ),
            );
          },
        ),
        const SizedBox(width: 14),
        Expanded(
          child: StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final relativeMicros =
                  (position.inMicroseconds - _cutStart.inMicroseconds)
                      .clamp(0, math.max(0, clipLength.inMicroseconds))
                      .toInt();
              final relativePosition = Duration(microseconds: relativeMicros);
              final progress = clipLength.inMicroseconds == 0
                  ? 0.0
                  : (relativeMicros / clipLength.inMicroseconds)
                        .clamp(0.0, 1.0)
                        .toDouble();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _l10n.previewClip,
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${_durationText(relativePosition)} / ${_durationText(clipLength)}',
                        style: TextStyle(
                          color: palette.secondaryInk,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: palette.secondarySurface,
                      color: palette.accent,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _bottomAction(_EditorPalette palette) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: palette.glassSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: palette.separator.withValues(alpha: .72),
                  width: .8,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exporting || _loading
                        ? null
                        : _showExportFormats,
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(
                      _exporting ? _l10n.exporting : _l10n.exportClip,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityIndicator(_EditorPalette palette) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _activity,
            style: TextStyle(color: palette.secondaryInk, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _privacyNote(_EditorPalette palette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.lock_outline_rounded,
            color: palette.secondaryInk,
            size: 16,
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            _l10n.localOnlyNote,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.secondaryInk,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionPainter extends CustomPainter {
  const _SelectionPainter({
    required this.startRatio,
    required this.endRatio,
    required this.dimColor,
    required this.accentColor,
  });

  final double startRatio;
  final double endRatio;
  final Color dimColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * startRatio;
    final right = size.width * endRatio;
    final dim = Paint()..color = dimColor.withValues(alpha: .78);
    canvas.drawRect(Rect.fromLTWH(0, 0, left, size.height), dim);
    canvas.drawRect(
      Rect.fromLTWH(right, 0, size.width - right, size.height),
      dim,
    );

    final selected = Paint()..color = accentColor.withValues(alpha: .06);
    canvas.drawRect(Rect.fromLTRB(left, 0, right, size.height), selected);

    final edge = Paint()
      ..color = accentColor
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(left, 0), Offset(left, size.height), edge);
    canvas.drawLine(Offset(right, 0), Offset(right, size.height), edge);

    final handle = Paint()..color = accentColor;
    for (final x in [left, right]) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, size.height / 2),
          width: 5,
          height: 42,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, handle);
    }
  }

  @override
  bool shouldRepaint(covariant _SelectionPainter oldDelegate) =>
      oldDelegate.startRatio != startRatio ||
      oldDelegate.endRatio != endRatio ||
      oldDelegate.dimColor != dimColor ||
      oldDelegate.accentColor != accentColor;
}

class _ExportFormat {
  const _ExportFormat(this.label, this.extension, this.codecArguments);

  final String label;
  final String extension;
  final List<String> codecArguments;
}

enum _ExportAction { save, share }

class _DeviceSaver {
  static const MethodChannel _channel = MethodChannel(
    'cn.quniv.audio_cut/device_saver',
  );

  static Future<String> saveAudio({
    required String sourcePath,
    required String fileName,
    required String mimeType,
  }) async {
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'saveAudio',
      {
        'sourcePath': sourcePath,
        'fileName': fileName,
        'mimeType': mimeType,
      },
    );
    final displayPath = result?['displayPath'];
    return displayPath is String && displayPath.isNotEmpty
        ? displayPath
        : fileName;
  }
}

class _LanguageOption {
  const _LanguageOption(this.locale, this.label);

  final Locale? locale;
  final String label;
}

Locale? _localeForLanguageCode(String languageCode) => switch (languageCode) {
  'zh' => const Locale('zh'),
  'en' => const Locale('en'),
  'ja' => const Locale('ja'),
  'ko' => const Locale('ko'),
  _ => null,
};

String _durationText(Duration duration) {
  final totalMilliseconds = duration.inMilliseconds;
  final hours = totalMilliseconds ~/ 3600000;
  final minutes = (totalMilliseconds ~/ 60000) % 60;
  final seconds = (totalMilliseconds ~/ 1000) % 60;
  final centiseconds = (totalMilliseconds % 1000) ~/ 10;
  final clock = hours > 0
      ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
      : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  return '$clock.${centiseconds.toString().padLeft(2, '0')}';
}
