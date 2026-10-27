# 本地音剪（Audio Cut）

面向 Android 和 iOS 的纯本地音频剪辑器。应用不设账号、云同步或后端；音频由设备上的 FFmpeg 解码和处理。

## 技术栈

- Flutter / Dart：共用 Android、iOS 的界面和业务流程。
- `ffmpeg_kit_flutter_new_audio`：本地读取媒体信息、生成波形、剪切和转码导出。选用音频包，不打包视频库；其许可证为 LGPL-3.0，发布前需保留第三方许可证与声明。
- `just_audio`：只播放本地文件，供剪辑前后试听。
- `file_picker`：调用 Android Storage Access Framework 和 iOS 系统文件选择器；不申请全盘文件访问权限。
- `share_plus`：把本地生成的音频交给系统分享面板，由用户决定保存位置或下一步操作。

## 本地与隐私约束

- Android 发布清单会移除 `INTERNET` 和 `ACCESS_NETWORK_STATE` 权限；不接受 URL 输入，不访问远程音频。
- 不接入登录、云同步、崩溃上传、广告或埋点 SDK。
- 用户选择的源文件复制到应用临时目录用于处理；导出先写入本机临时目录，再通过系统分享面板交给用户选择保存位置。临时文件可在应用下次启动时清理。
- 系统文件选择器可能展示用户配置的云盘位置；只有用户主动选择后，系统才会按其文件提供方规则取回文件。本应用不把音频上传到任何服务。

## 支持格式目标

首版围绕 MP3、M4A/AAC、WAV/PCM、FLAC、OGG/Vorbis、Opus、AIFF、CAF 做本地导入和解码；导出首版提供 MP3、M4A、WAV、FLAC、OGG、Opus。格式最终以打包的 FFmpeg 编解码器和设备试听能力为准。

## 开发环境

- Flutter stable 3.47.x（Dart 3.13.x）。
- Android：Android SDK / JDK 17，最低 API 24（FFmpeg 音频插件要求）。
- iOS：Xcode，首版最低 iOS 15。

在安装 Flutter 的终端中运行：

```sh
flutter pub get
flutter run
```

将任意音频文件复制到手机或模拟器，再从系统文件选择器打开，即可验证导入、剪辑预览和导出流程。测试音频不包含在仓库中。

## 当前进度

第一阶段：单文件导入、波形展示、起止时间调整、选区试听、格式导出。后续再加入多片段拼接、淡入淡出和无损裁切。

## 许可证

本项目源代码使用 [MIT License](LICENSE)。第三方依赖及随应用分发的编解码库仍受各自许可证约束；其中 `ffmpeg_kit_flutter_new_audio` 使用 LGPL-3.0，分发应用时请同时遵守其许可证要求。

第三方组件、许可证副本和发布前复核要求见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。

## Google Play 发布

发布前材料和操作步骤见 [`docs/google-play/release-checklist.md`](docs/google-play/release-checklist.md)。首次发布需要在本机生成并安全备份 Android 上传密钥，然后构建已签名的 App Bundle。隐私政策网页位于 `docs/privacy-policy.html`；启用 GitHub Pages 后，将其公开 URL 填入 Play Console。
