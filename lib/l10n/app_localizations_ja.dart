// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ローカル音声カッター';

  @override
  String get appName => '音声カット';

  @override
  String get localOnly => 'この端末内のみ';

  @override
  String get emptyTitle => '音声を編集';

  @override
  String get emptyDescription => '端末内の音声を選び、範囲を指定して試聴し、書き出します。';

  @override
  String get chooseAudio => '音声を選択';

  @override
  String supportedFormats(String formats) {
    return '対応形式：$formats';
  }

  @override
  String get switchAudio => '変更';

  @override
  String get clipRange => '編集範囲';

  @override
  String clipDuration(String duration) {
    return '切り出し $duration';
  }

  @override
  String totalDuration(String duration) {
    return '全体 $duration';
  }

  @override
  String get dragHandlesHint => '両端のハンドルをドラッグするか、下の時刻をタップして入力';

  @override
  String get startTime => '開始';

  @override
  String get endTime => '終了';

  @override
  String get pausePreview => '試聴を一時停止';

  @override
  String get previewClip => '範囲を試聴';

  @override
  String get exporting => '書き出し中…';

  @override
  String get exportClip => '範囲を書き出す';

  @override
  String get localOnlyNote => '端末内で処理 · アップロードや自動同期はありません';

  @override
  String get activitySelectAudio => '音声ファイルを選択…';

  @override
  String get activityReadingAudio => '音声を読み込み中…';

  @override
  String get activityAnalyzingWaveform => '波形を解析中…';

  @override
  String activityExportingFormat(String format) {
    return '$format で書き出し中…';
  }

  @override
  String audioLoadFailed(String error) {
    return '音声を開けませんでした：$error';
  }

  @override
  String get errorUnableReadDuration =>
      '音声の長さを読み取れません。ファイルの破損や非対応のコーデックをご確認ください。';

  @override
  String get errorWaveformFailed =>
      '音声は読み込めましたが、波形を生成できませんでした。このコーデックはまだ対応していない可能性があります。';

  @override
  String get invalidTimeExample => '有効な時刻を入力してください（例：00:12.50）。';

  @override
  String get editStartPosition => '開始位置を設定';

  @override
  String get editEndPosition => '終了位置を設定';

  @override
  String get timePlaceholder => '例：00:12.50 または 12.5';

  @override
  String get timeInputHint => '時:分:秒、または秒数で入力';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '完了';

  @override
  String previewFailed(String error) {
    return '試聴に失敗しました：$error';
  }

  @override
  String get selectExportFormat => '書き出し形式を選択';

  @override
  String get exportLocalStorageDescription => '音声は端末内で処理されます。保存先を選択してください。';

  @override
  String get formatMp3Description => '幅広く再生でき、ファイルサイズも小さめ';

  @override
  String get formatM4aDescription => 'AAC エンコード、スマートフォン向け';

  @override
  String get formatWavDescription => '非圧縮、後から編集する場合に最適';

  @override
  String get formatFlacDescription => '可逆圧縮';

  @override
  String get formatOggDescription => 'Vorbis エンコード';

  @override
  String get formatOpusDescription => '高圧縮率、音声に最適';

  @override
  String get invalidFileName => 'パスや特殊文字を含まないファイル名を入力してください。';

  @override
  String get exportFilenameTitle => '書き出しファイル名';

  @override
  String get filenamePlaceholder => 'ファイル名を入力';

  @override
  String exportAsFormat(String format) {
    return '$format 形式で書き出します。拡張子は自動で追加されます。';
  }

  @override
  String get export => '書き出す';

  @override
  String get audioExportFailed => '音声を書き出せませんでした。';

  @override
  String get shareTitle => '編集した音声を保存';

  @override
  String get exportSuccess => '音声の準備ができました。システムの共有画面から保存できます。';

  @override
  String exportFailed(String error) {
    return '書き出しに失敗しました：$error';
  }

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get close => '閉じる';

  @override
  String get defaultAudioName => '音声';

  @override
  String get cutSuffix => '_編集';

  @override
  String get privacyPolicyBody =>
      '音声カット プライバシー通知\n\n音声カットは音声カットプロジェクトのメンテナーが開発しています。プライバシーに関するお問い合わせは、GitHub の課題ページ（github.com/ponponon/audio-cut/issues）からお願いします。公開課題に個人の音声や機密情報を添付しないでください。\n\n音声ファイル\nシステムのファイル選択画面からユーザーが選んだ音声は、この端末内での解析、試聴、編集、変換のみに使用します。作業用コピーと書き出しファイルはアプリの一時フォルダに保存され、次回起動時に削除されます。元のファイルは変更しません。\n\nネットワークとデータ収集\nアカウント、広告、クラウド同期、リモート分析、クラッシュレポートはありません。音声、ファイル名、その他の個人データを開発者やサーバーに送信しません。全ストレージやマイクへのアクセス権限は要求せず、システムのファイル選択画面で選んだファイルのみ読み取ります。\n\n書き出しと他のアプリ\n書き出し時にシステムの共有画面を開きます。ユーザーが保存先や受信アプリを選んだ場合に限り、ファイルがその宛先に渡されます。受信アプリは独自のポリシーに基づき、ファイルを保存または送信することがあります。その扱いは音声カットの管理外です。\n\n削除と保存期間\n作業ファイルはアプリの次回起動時に削除されます。システム設定でアプリのデータを消去するか、アプリをアンインストールして、アプリが端末内に保持したファイルを削除できます。他のアプリに渡したコピーは、そのアプリで管理してください。\n\nお問い合わせと更新\nプライバシーに関するお問い合わせは GitHub の課題ページからお送りください。機能やデータの取り扱いに変更があった場合、この通知を更新します。';
}
