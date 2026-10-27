# 第三方组件与许可证

本项目应用代码采用 MIT License，见 [LICENSE](LICENSE)。随应用分发的 Flutter 与 Android/iOS 原生依赖各自保留其许可证和版权声明。

## 音频处理组件

- `ffmpeg_kit_flutter_new_audio` 2.5.7，Android Maven 组件 `com.antonkarpenko:ffmpeg-kit-audio` 2.2.3。
- 插件声明使用 GNU LGPL 3.0；本项目随仓库提供完整许可证文本：[LGPL-3.0](licenses/ffmpeg_kit_flutter_new_audio-LGPL-3.0.txt)。
- 当前选择 audio 变体；插件文档说明该变体不含 `x264`、`x265`、`xvidcore`、`vid.stab` 等 GPL 组件。
- 插件及预编译 FFmpeg/音频库源码和版本信息：[插件源码](https://github.com/sk3llo/ffmpeg_kit_flutter/tree/audio)、[插件发布说明](https://pub.dev/packages/ffmpeg_kit_flutter_new_audio)。FFmpeg 与各链接库还可能附带自己的许可证和版权声明。

Flutter 的“开源许可”页面可从应用内“仅本机”隐私说明打开，用于展示 Flutter 注册的依赖许可证。每次升级音频插件或原生二进制包后，发布前都要复核其精确版本、附带的库清单和 LGPL 对应源代码/可替换链接库等要求；不要把本文件当成对所有二进制分发义务的自动证明。
