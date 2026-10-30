// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '로컬 오디오 자르기';

  @override
  String get appName => '오디오 컷';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsLanguage => '앱 언어';

  @override
  String get settingsLanguageHint => '앱에서 사용할 언어를 선택하세요.';

  @override
  String get systemDefaultLanguage => '시스템 기본값';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '한국어';

  @override
  String get settingsSaveFailed => '언어 설정을 저장할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get localOnly => '이 기기에서만';

  @override
  String get emptyTitle => '오디오 자르기';

  @override
  String get emptyDescription => '기기에서 오디오를 선택하고 구간을 지정한 뒤 미리 듣고 내보내세요.';

  @override
  String get chooseAudio => '오디오 선택';

  @override
  String supportedFormats(String formats) {
    return '지원 형식: $formats';
  }

  @override
  String get switchAudio => '변경';

  @override
  String get clipRange => '편집 구간';

  @override
  String clipDuration(String duration) {
    return '클립 $duration';
  }

  @override
  String totalDuration(String duration) {
    return '전체 $duration';
  }

  @override
  String get dragHandlesHint => '양쪽 핸들을 끌거나 아래 시간을 눌러 입력하세요';

  @override
  String get startTime => '시작';

  @override
  String get endTime => '끝';

  @override
  String get pausePreview => '미리 듣기 일시정지';

  @override
  String get previewClip => '선택 구간 미리 듣기';

  @override
  String get exporting => '내보내는 중…';

  @override
  String get exportClip => '선택 구간 내보내기';

  @override
  String get localOnlyNote => '기기에서 처리 · 업로드 및 자동 동기화 없음';

  @override
  String get activitySelectAudio => '오디오 파일을 선택하세요…';

  @override
  String get activityReadingAudio => '오디오를 읽는 중…';

  @override
  String get activityAnalyzingWaveform => '파형을 분석하는 중…';

  @override
  String activityExportingFormat(String format) {
    return '$format 형식으로 내보내는 중…';
  }

  @override
  String audioLoadFailed(String error) {
    return '오디오를 열 수 없습니다: $error';
  }

  @override
  String get errorUnableReadDuration =>
      '오디오 길이를 읽을 수 없습니다. 파일이 손상되지 않았는지, 코덱이 지원되는지 확인하세요.';

  @override
  String get errorWaveformFailed =>
      '오디오는 읽었지만 파형을 만들지 못했습니다. 아직 지원되지 않는 코덱일 수 있습니다.';

  @override
  String get invalidTimeExample => '올바른 시간을 입력하세요. 예: 00:12.50';

  @override
  String get editStartPosition => '시작 위치 설정';

  @override
  String get editEndPosition => '끝 위치 설정';

  @override
  String get timePlaceholder => '예: 00:12.50 또는 12.5';

  @override
  String get timeInputHint => '시:분:초 또는 초 단위로 입력';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '완료';

  @override
  String previewFailed(String error) {
    return '미리 듣기에 실패했습니다: $error';
  }

  @override
  String get selectExportFormat => '내보내기 형식 선택';

  @override
  String get exportLocalStorageDescription =>
      '오디오는 이 기기에서 처리됩니다. 저장 위치를 선택하세요.';

  @override
  String get formatMp3Description => '호환성이 높고 파일 크기가 작음';

  @override
  String get formatM4aDescription => 'AAC 인코딩, 휴대폰 재생에 적합';

  @override
  String get formatWavDescription => '무압축, 후속 편집에 적합';

  @override
  String get formatFlacDescription => '무손실 압축';

  @override
  String get formatOggDescription => 'Vorbis 인코딩';

  @override
  String get formatOpusDescription => '높은 압축률, 음성에 적합';

  @override
  String get invalidFileName => '경로나 특수 문자를 제외한 파일 이름을 입력하세요.';

  @override
  String get exportFilenameTitle => '내보낼 파일 이름';

  @override
  String get filenamePlaceholder => '파일 이름 입력';

  @override
  String exportAsFormat(String format) {
    return '$format 형식으로 내보내며 확장자는 자동으로 추가됩니다.';
  }

  @override
  String get saveToDevice => '기기에 저장';

  @override
  String get shareAction => '공유';

  @override
  String get audioExportFailed => '오디오를 내보내지 못했습니다.';

  @override
  String get shareTitle => '편집한 오디오 저장';

  @override
  String get exportSuccess => '오디오가 준비되었습니다. 시스템 공유 창에서 저장할 수 있습니다.';

  @override
  String saveToDeviceSuccess(String path) {
    return '$path에 저장했습니다';
  }

  @override
  String saveToDeviceSuccessFilesApp(String path) {
    return '파일 앱의 앱 폴더에 저장했습니다: $path';
  }

  @override
  String get savePermissionFallbackShare => '저장 권한이 없어 공유 창을 열었습니다.';

  @override
  String exportFailed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get openSourceLicenses => '오픈소스 라이선스';

  @override
  String get close => '닫기';

  @override
  String get defaultAudioName => '오디오';

  @override
  String get cutSuffix => '_편집';

  @override
  String get exportCopySuffix => '_복사본';

  @override
  String get privacyPolicyBody =>
      '오디오 컷 개인정보 안내\n\n오디오 컷은 오디오 컷 프로젝트 관리자가 개발하고 유지합니다. 개인정보 문의는 GitHub 이슈 페이지(github.com/ponponon/audio-cut/issues)를 이용해 주세요. 공개 이슈에 개인 음성이나 민감한 정보를 첨부하지 마세요.\n\n오디오 파일\n시스템 파일 선택기에서 직접 선택한 오디오는 이 기기에서 분석, 미리 듣기, 자르기 및 변환에만 사용됩니다. 작업용 복사본과 내보낸 파일은 앱 임시 폴더에 저장되며 앱을 다음에 시작할 때 삭제됩니다. 원본 파일은 수정하지 않습니다.\n\n네트워크 및 데이터 수집\n계정, 광고, 클라우드 동기화, 원격 분석 또는 오류 보고를 제공하지 않습니다. 오디오, 파일 이름 및 기타 개인정보를 개발자나 서버로 전송하지 않습니다. 마이크 권한을 요청하지 않으며 시스템 파일 선택기에서 선택한 파일만 읽습니다. Android 10 이상에서는 내보낸 파일 저장에 저장소 권한이 필요하지 않습니다. Android 9 이하에서는 내보내기를 저장할 때만 저장소 권한을 요청합니다.\n\n내보내기 및 다른 앱\n내보낼 때 기기의 Music/AudioCut 폴더에 저장하거나(iPhone에서는 파일 앱의 앱 폴더에 저장), 시스템 공유 창을 열어 다른 앱에 전달할 수 있습니다. 사용자가 저장 위치나 받을 앱을 선택한 뒤에만 파일이 해당 대상으로 전달됩니다. 받는 앱은 자체 정책에 따라 파일을 저장하거나 전송할 수 있으며, 이는 오디오 컷이 관리하지 않습니다.\n\n삭제 및 보관\n작업 파일은 앱을 다음에 시작할 때 삭제됩니다. 기기의 공용 폴더에 저장한 복사본은 앱에서 삭제되지 않습니다. 시스템 설정에서 앱 데이터를 지우거나 앱을 삭제해 앱이 기기에 보관한 파일을 제거할 수도 있습니다. 다른 앱에 전달한 복사본은 해당 앱에서 관리해야 합니다.\n\n문의 및 업데이트\n개인정보 관련 문의는 GitHub 이슈 페이지로 보내 주세요. 앱 기능이나 데이터 처리 방식이 변경되면 이 안내도 업데이트됩니다.';
}
