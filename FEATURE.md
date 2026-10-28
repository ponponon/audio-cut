# 功能说明

该文件记录已实现功能和重建项目所需的产品约定。

## 产品目标

- 提供 Android 与 iOS 共用的轻量音频剪辑器。
- 项目开源、免费、无广告；源代码使用 MIT 许可证，第三方编解码组件遵守其各自许可证。
- 默认完全在设备内处理音频，不创建账户，不提供云同步，不向网络发送用户音频。
- 让用户看到清晰波形、精确设置裁切起止时间、试听选区，并导出常见格式。

## Android 发布架构

- Android 官方 APK 仅打包并支持 `arm64-v8a`；构建配置需排除 ARM32、x86 和 x86_64 原生库。
- 包名固定为 `cn.quniv.audio_cut`。跨官网、应用商店和直装版本升级时保持同一应用签名密钥。
- 上传密钥或应用签名私钥、密码不得提交 Git、公开网站或 R2；R2 可存放公开 APK 和真实应用截图。

## 官网与下载

- 官网地址为 `https://audio-cut.quniv.cn`，使用静态页面介绍开源、免费、纯本地、无广告的产品定位，并提供隐私政策、真实应用截图和 arm64 Android APK。官网页面由 OpenResty 提供；APK 存储在 Cloudflare R2 `audio-cut-releases`，通过 `https://audio-cut-releases.quniv.cn` 自定义域名下载，官网 `/download` 只负责重定向，不从小带宽源站传输 APK。
- GitHub Release 发布后，`publish_r2` 任务把已签名 APK、版本化清单和 latest 清单上传到 R2，并刷新稳定 latest APK 对象。latest 下载与清单通过 Cloudflare Cache Rule 设置 60 秒 Browser TTL，版本化对象保持一年不可变缓存。R2 凭据单独存放在 `r2-release` GitHub Actions 环境，只授予 `audio-cut-releases` 桶的对象读写权限，不与 Android 签名密钥共用环境。
- 官网不加载第三方统计、广告、字体或脚本，不接收音频文件，也不提供云端音频处理。
- 真实截图从实际运行的 Android 应用捕获；商店截图需满足目标商店的尺寸和长宽比要求。

## 首版范围

- 通过系统文件选择器导入单个音频文件。
- 支持常见输入格式：MP3、M4A/AAC、WAV/PCM、FLAC、OGG/Vorbis、Opus、AIFF、CAF。
- 展示文件名、时长和波形。
- 以时间输入和波形选区设置开始、结束位置。
- 试听原音频和裁切选区。
- 本地导出 MP3、M4A、WAV、FLAC、OGG、Opus。
- 导出前可编辑文件名；所选格式的扩展名自动添加，取消命名会中止本次导出。
- UI 参考 iOS「语音备忘录」：跟随系统浅色/深色外观，支持系统动态字号，波形与剪辑范围优先呈现；使用柔和的森林绿强调色。
- 编辑页底部导出栏使用轻量磨砂玻璃效果；以 Flutter 内置背景模糊近似液态玻璃，不引入额外渲染插件。
- 导出先写入本机临时目录，再打开系统分享面板，让用户保存到 Files、系统文件提供方或其他目标。

## 多语言

- 界面与应用名称支持简体中文、英语、日语、韩语四种语言；顶栏齿轮打开应用内语言设置，可选择跟随系统或固定一种语言。
- 应用语言选择保存在设备应用支持目录的本地偏好文件中，不增加登录、网络请求或云端配置。
- 主界面、导入/试听/剪辑/导出提示、隐私说明、许可入口和格式说明均使用本地化资源。
- Android 通过 locale config 声明四种应用语言；iOS 在 Info.plist 中声明支持的本地化，并提供对应的应用显示名称。
- 翻译源文件为 `lib/l10n/app_*.arb`，Flutter 生成代码放在 `lib/l10n/app_localizations*.dart`；修改文案后运行 `flutter gen-l10n`。
- 界面继续遵循系统动态字号；较长翻译应换行或由滚动区域承载，不通过缩小字体裁切内容。

## 隐私与存储约定

- Flutter 仅负责界面与状态；FFmpeg 在端内执行解码、波形提取、剪切和编码。
- 试听只使用本机文件路径。代码不接受远程 URL。
- Android 发布包不保留 `INTERNET`、`ACCESS_NETWORK_STATE`、全盘存储或麦克风权限。
- 临时副本放在应用沙盒；导出文件由系统分享面板交给用户选择目的地；临时副本可在下次启动时清理。
- 系统文件提供方可能是用户自己配置的云盘；本应用不发起上传或同步。

## Google Play 发布准备

- 顶栏“仅本机”可打开完整的应用内隐私说明；同时提供 Flutter 依赖开源许可列表。
- 商店资料草稿、Data safety 草稿和逐项发布清单位于 `docs/google-play/`。
- `docs/` 包含轻量项目主页和中英文隐私政策，供 GitHub Pages 发布；公开的隐私政策链接是 Play Console 必填项。
- Google Play 图标和 feature graphic 由 `tooling/generate_google_play_assets.swift` 生成；Android/iOS 启动图标由 `tooling/update_launcher_icons.sh` 导出。统一使用浅薄荷底 `#EAF7EF`、微信绿 `#07C160` 和选区浅绿 `#B4ECCE`。
- Android release 固定使用 target API 36；release 构建必须使用本机上传密钥，不使用 debug 签名。
- 本机处理的音频不应被描述为上传数据；用户主动通过系统分享面板选择的目标由该目标的隐私规则负责。

## 后续候选

- 多片段拼接、片段排序、撤销/重做。
- 淡入淡出、音量调整、静音段裁剪。
- 针对 MP3 等压缩格式提供快速无损裁切选项，并清楚说明采样精度差异。
- 本地最近项目列表与用户可控的临时文件清理。
