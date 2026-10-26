import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    required this.waveformTrack,
  });

  final Color canvas;
  final Color surface;
  final Color secondarySurface;
  final Color ink;
  final Color secondaryInk;
  final Color separator;
  final Color accent;
  final Color waveformTrack;

  static const light = _EditorPalette(
    canvas: Color(0xFFF2F2F7),
    surface: Color(0xFFFFFFFF),
    secondarySurface: Color(0xFFE5E5EA),
    ink: Color(0xFF1C1C1E),
    secondaryInk: Color(0xFF636366),
    separator: Color(0xFFD1D1D6),
    accent: Color(0xFFC64025),
    waveformTrack: Color(0xFFF7F7F9),
  );

  static const dark = _EditorPalette(
    canvas: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    secondarySurface: Color(0xFF2C2C2E),
    ink: Color(0xFFF5F5F7),
    secondaryInk: Color(0xFFAEAEB2),
    separator: Color(0xFF38383A),
    accent: Color(0xFFFF896B),
    waveformTrack: Color(0xFF121214),
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
        onPrimary: Colors.white,
        secondary: palette.accent,
        onSecondary: Colors.white,
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
        foregroundColor: Colors.white,
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
  _ExportFormat('MP3', 'mp3', '通用、体积小', ['-c:a', 'libmp3lame', '-q:a', '2']),
  _ExportFormat('M4A', 'm4a', 'AAC 编码，适合手机播放', [
    '-c:a',
    'aac',
    '-b:a',
    '192k',
    '-f',
    'ipod',
  ]),
  _ExportFormat('WAV', 'wav', '未压缩，适合后续编辑', ['-c:a', 'pcm_s16le', '-f', 'wav']),
  _ExportFormat('FLAC', 'flac', '无损压缩', [
    '-c:a',
    'flac',
    '-compression_level',
    '5',
  ]),
  _ExportFormat('OGG', 'ogg', 'Vorbis 编码', [
    '-c:a',
    'libvorbis',
    '-q:a',
    '5',
    '-f',
    'ogg',
  ]),
  _ExportFormat('Opus', 'opus', '高压缩率，适合语音', [
    '-c:a',
    'libopus',
    '-b:a',
    '128k',
    '-f',
    'opus',
  ]),
];

class LocalAudioCutApp extends StatelessWidget {
  const LocalAudioCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '本地音频剪辑',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(_EditorPalette.light, Brightness.light),
      darkTheme: _buildTheme(_EditorPalette.dark, Brightness.dark),
      home: const _EditorScreen(),
    );
  }
}

class _EditorScreen extends StatefulWidget {
  const _EditorScreen();

  @override
  State<_EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<_EditorScreen> {
  final AudioPlayer _player = AudioPlayer();

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
      _activity = '请选择音频文件…';
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
      setState(() => _activity = '正在读取音频…');
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

      setState(() => _activity = '正在分析波形…');
      final probeSession = await FFprobeKit.getMediaInformation(source.path);
      final media = probeSession.getMediaInformation();
      final seconds = double.tryParse(media?.getDuration() ?? '');
      if (seconds == null || !seconds.isFinite || seconds <= 0) {
        throw const FormatException('无法读取音频时长。请确认文件没有损坏，且编码格式受支持。');
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
        throw const FormatException('读取成功，但生成波形失败。这个文件可能包含暂不支持的音频编码。');
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
        _sourceFormat = extension.isEmpty ? '音频' : extension.toUpperCase();
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
      _showMessage(_friendlyError(error));
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
            _showMessage('请输入有效时间，例如 00:12.50。');
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
            title: Text(editStart ? '设置开始位置' : '设置结束位置'),
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
                    placeholder: '例如 00:12.50 或 12.5',
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
                    '可输入 时:分:秒 或秒数',
                    style: TextStyle(color: palette.secondaryInk, fontSize: 13),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: submit,
                child: const Text('确定'),
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
      _showMessage('试听失败：${_friendlyError(error)}');
    }
  }

  Future<void> _showExportFormats() async {
    if (_sourcePath == null || _exporting) return;
    final palette = _EditorPalette.of(context);
    final selected = await showModalBottomSheet<_ExportFormat>(
      context: context,
      backgroundColor: palette.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择导出格式',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '文件会在本机处理，保存位置由你选择。',
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
                    _formats[index].description,
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
    if (selected != null) await _export(selected);
  }

  Future<void> _export(_ExportFormat format) async {
    final source = _sourcePath;
    if (source == null) return;
    final baseName = p
        .basenameWithoutExtension(_sourceName)
        .replaceAll(RegExp(r'[^\p{L}\p{N}._ -]', unicode: true), '_');
    final suggestedName = '${baseName}_cut.${format.extension}';
    if (!mounted) return;

    setState(() {
      _exporting = true;
      _activity = '正在导出 ${format.label}…';
    });
    try {
      final directory = _workDirectory ?? await _workDirectoryFuture;
      final output = File(
        p.join(
          directory.path,
          '${DateTime.now().microsecondsSinceEpoch}_$suggestedName',
        ),
      );
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
          output?.trim().isNotEmpty == true ? output!.trim() : '音频导出失败。',
        );
      }
      await SharePlus.instance.share(
        ShareParams(
          title: '保存剪辑音频',
          subject: suggestedName,
          files: [XFile(outputPath, mimeType: _mimeType(format.extension))],
        ),
      );
      if (!mounted) return;
      _showMessage('音频已生成。可在系统分享面板中保存到设备。');
    } catch (error) {
      if (mounted) _showMessage('导出失败：${_friendlyError(error)}');
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _activity = '';
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
      appBar: AppBar(
        title: const Text('本地音剪'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: palette.secondaryInk,
                ),
                const SizedBox(width: 5),
                Text(
                  '仅本机',
                  style: TextStyle(
                    color: palette.secondaryInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
          '剪辑一段音频',
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
          '选择设备中的音频，设定起止位置后试听并导出。',
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
            label: const Text('选择音频'),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'MP3 · M4A · WAV · FLAC · OGG · Opus',
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
          label: const Text('更换'),
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
                '剪辑范围',
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
                    '片段 ${_durationText(clipLength)}',
                    style: TextStyle(
                      color: palette.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '总长 ${_durationText(_duration)}',
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
              '拖动两端手柄，或点下方时间输入',
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
                    _timeButton('开始', _cutStart, palette, true),
                    Divider(height: 1, color: palette.separator),
                    _timeButton('结束', _cutEnd, palette, false),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _timeButton('开始', _cutStart, palette, true),
                    ),
                    SizedBox(
                      height: 48,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: palette.separator,
                      ),
                    ),
                    Expanded(child: _timeButton('结束', _cutEnd, palette, false)),
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
              tooltip: playing ? '暂停试听' : '试听片段',
              onPressed: _loading || _exporting ? null : _togglePreview,
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              style: IconButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: Colors.white,
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
                          '试听片段',
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
    return Container(
      decoration: BoxDecoration(
        color: palette.canvas,
        border: Border(top: BorderSide(color: palette.separator)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _exporting || _loading ? null : _showExportFormats,
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(_exporting ? '正在导出…' : '导出片段'),
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
            '仅在本机处理 · 不上传、不自动同步',
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
  const _ExportFormat(
    this.label,
    this.extension,
    this.description,
    this.codecArguments,
  );

  final String label;
  final String extension;
  final String description;
  final List<String> codecArguments;
}

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
